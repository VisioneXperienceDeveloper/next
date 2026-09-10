# Next — Architecture

## Platform and structure

iOS 17 is the minimum because SwiftData and the chosen SwiftUI APIs are available there. The project uses Swift 6 complete concurrency checking and builds with installed Xcode 26.6 / Swift 6.3.3. Current App Store SDK requirements do not force the deployment minimum to match the SDK.

```
Next/
  App/              NextApp, StoreView, RootView
  Models/           NextSchema (Vision, Step, Reflection)
  Services/         Persistence, VisionActions, Diagnostics
  Features/
    Onboarding/     Welcome, Vision setup
    Home/           current Step and Vision
    Step/           Step editor and single-sheet CompletionFlow
    Journey/        targeted query, completion ordering, month grouping
    Vision/         statement editing and confirmed deletion
    About/          privacy and support
  Components/       PrimaryButton, Eyebrow, StatementEditor
  Resources/        Copy, String Catalog, asset catalog, privacy manifest
  PreviewContent/   in-memory fixtures
NextTests/          domain and persistence tests
NextUITests/        first-flow and full-loop UI tests
release/app-store/  metadata, documents, images, validation scripts
```

## Final schema v1.0.0

Vision: UUID, title, createdAt, updatedAt, owned Steps. Step: UUID, title, createdAt, completedAt?, parent Vision?, owned Reflection?. Reflection: UUID, content, createdAt, parent Step?. UUIDs are unique attributes. Explicit inverse relationships and cascade deletion run from Vision → Steps → Reflection; child deletion does not cascade to its parent.

`isCompleted` derives from `completedAt != nil`, avoiding contradictory stored flags. `Vision.activeStep` is the only domain read for current Step and deterministically selects the earliest if a damaged store violates the invariant. Application actions prevent creating that invalid state.

The schema is versioned. No schema change was needed between first flow and full MVP because completion/reflection fields were already present. Future schema changes require a deliberate migration plan; no speculative migration infrastructure exists now.

## State and persistence ownership

StoreView owns one ModelContainer for the scene and shows load/retry states. It injects a main-context container with autosave disabled and CloudKit explicitly disabled. RootView queries Vision and derives onboarding from its existence. Views own plain String drafts; SwiftData models are edited only on successful domain actions.

VisionActions is a small main-actor mutation boundary: create/update/delete Vision, create/update/complete Step, add Reflection. It validates non-empty trimmed text, one Vision, one active Step, attached context ownership, writable store, completion eligibility, and one Reflection per completed Step. Validation and save do not suspend.

Saves use ModelContext.transaction. Errors call rollback; scalar editor values are restored where necessary and insertion failures clean up candidate objects. Read-only stores are rejected before observed models are mutated. Tests cover that preflight failure and retry behavior. Disk-full/corrupt-store save recovery has not been fault-injected; rollback is not claimed to prove all I/O failure modes.

## Query and navigation

Home queries the single Vision and derives activeStep through its owned relationship. Journey filters completed Steps for that Vision and sorts by completion date; a deterministic UUID tie-breaker and Calendar-based month grouping live in JourneyOrder. The expected local dataset is small; no unrelated fetches or analytics aggregation are introduced.

RootView owns sheet selection with stable model UUIDs. CompletionFlow owns an ephemeral phase enum and commits each meaningful phase. Dismissing a sheet clears temporary work while persisted domain state determines Home. Journey and About use native NavigationStack destinations.

## Privacy, concurrency, and future boundaries

No network calls, credentials, analytics SDK, global service singleton, repository layer, DI framework, or external package. DEBUG diagnostics log error domain/code, never private user text. DEBUG UI tests choose UUID-isolated disk stores, never reset the user store; these arguments do not exist in Release.

Widget architecture is deferred: when requested, use a read-only current-Step projection in an App Group and WidgetKit timeline invalidation after successful mutations, plus a deep link into Home/creation. Do not share a writable SwiftData container across processes by accident. No widget extension, App Group entitlement, or sync code is included now.
