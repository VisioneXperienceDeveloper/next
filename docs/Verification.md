# Next verification

The full MVP is implemented. See [current release QA](../release/app-store/qa/verification.md) for exact executions and limits, and [release readiness](../release/app-store/readiness.md) for remaining distribution gates.

Current automated evidence: 16 domain/persistence tests and 7 UI tests passed across iOS 18.4 and 26.5 simulators. Persistence is verified by disk container recreation and terminate/relaunch UI flows. Completion, optional Reflection, next Step continuity, Journey, edits, and confirmed deletion are included.

The earlier first-increment screenshots under docs/screenshots are retained as historical evidence. Final App Store artwork is under release/app-store/screenshots/editorial; iphone-6.9 is retained as older evidence.

Review: mutations are centralized; no force unwraps/fatalError in app code, no external SDK/networking/global service singleton, no analytics or roadmap feature expansion. Navigation is Home-centric with one completion sheet. iOS 17 deployment compilation is enabled, but no iOS 17 runtime/device result is claimed.

## Keyboard dismissal — 2026-09-10

Removed the Done keyboard toolbar. A native tap observer dismisses focus outside text inputs without consuming text selection or button actions; it detaches when the editing view leaves the window.

`CoreLoopUITests.testOutsideTapDismissesKeyboardWithoutConsumingEditingOrSave` passed on iPhone 17 Pro Max / iOS 26.5, with an isolated test store. It covers Vision setup, first Step, Vision editing, Step editing, Reflection, and subsequent Step creation. Each screen verifies internal taps preserve the keyboard, outside taps dismiss it without changing the draft, and Save/Continue works while the keyboard is open.

Result: `test_sim_2026-09-10T00-07-22-695Z_pid31601_b327b347.xcresult` in the XcodeBuildMCP workspace. The first SwiftUI-only gesture failed the dismissal assertion and was replaced. A duplicate background heading in the test selector was fixed. iOS 18.4 runner launch failed with Mach error -308; no new iOS 18 result is claimed. The same-name simulator selection was pinned by UDID for the successful run.

The updated Release app was built, installed and launched on the same simulator. Build log: `build_run_sim_2026-09-10T00-10-49-738Z_pid31601_b4fdaa10.log`. The live browser mirror showed the existing user store after launch.

## Liquid Glass styling — iOS 26 runtime

User clarification: keep iOS 26 as the execution environment and apply the iOS 27 visual direction only. Use stable Xcode 26.6 / iOS 26.5 Simulator. All added glass and safeAreaBar APIs are available from iOS 26 with existing iOS 17 fallbacks. No domain/schema changes.

Stable Release build passed: `build_sim_2026-09-10T00-18-00-229Z_pid31601_697a13b1.log` and `build_run_sim_2026-09-10T00-31-05-898Z_pid31601_b6bf2b38.log` both contain BUILD SUCCEEDED. The latter tool timed out during simulator execution, so this does not prove launch. A harmless AppIntents metadata-extraction warning reports that no AppIntents dependency exists.

An unnecessary Xcode 27 beta trial compiled the app and test targets but could not execute tests after simulator Mach error -308 and severe host load. Both beta test commands were stopped; iOS 27 is shut down. No new UI test pass or screenshot refresh is claimed yet. Existing stored screenshots precede this styling change. The user store remains on the iOS 26 simulator, with an integrity-checked backup under build/preview-data excluded from release packages.

## Journey layout — 2026-09-10

Kept completion-date descending ordering for entries and months, explicitly anchored the scroll view to the top, and removed the connector beneath the final entry across all month groups. Release build passed (`build_sim_2026-09-10T00-44-43-111Z_pid31601_35d0f4e8.log`). Installation and launch now succeeded on the pinned iOS 26.5 simulator. Live browser inspection verified the updated Home and Journey: entries begin at the top, the first entry retains its connector, and the last entry has none. Existing user data was preserved. This confirms these screens visually; the complete UI suite and App Store screenshot refresh remain outstanding after the glass change.


## App Store build 2 and canonical URLs — 2026-09-10

About now uses the owner-provided https://www.visionexperiencedeveloper.com/en/policies/next and https://www.visionexperiencedeveloper.com/en/supports/next. Build number increased to 2 in the Xcode project and generator. Archive and automatic App Store export succeeded. Strict codesign validation passed; the exported executable contains both new URLs and no old /politics/next URL. Assets.car contains the same three opaque 1024×1024 AppIcon variants. Upload completed at 15:51:28 AEST, TestFlight lists build 2 Ready to Submit, and the distribution version has build 2 attached. No UI layout or persistence change was made in build 2; the Release screenshots and footage from build 1 still match.

The owner-provided EN/KO public policy and support pages loaded successfully after a separate website deployment fixed support registration. Detailed release evidence is in release/app-store/evidence/build2-verification.json. A new full simulator test suite was not run for the two constant URL changes; distribution compilation, signature/embedded asset inspection, and live destination verification were performed. Physical-device and TestFlight manual QA remain not run.
