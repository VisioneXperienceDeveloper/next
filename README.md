# Next

One vision. One next step. Keep moving.

Native SwiftUI + SwiftData iPhone app. iOS 17+, Swift 6. No accounts, backend, analytics, or external dependencies.

## Implemented MVP

Welcome → create one Vision → create one Next Step → Home → complete Step → optional Reflection → choose next Step. Journey shows completed Steps by completion month, newest first. Vision and active Step text can be edited. Deleting a Vision requires confirmation and cascades through its Journey. About provides privacy and support links.

Open **Next.xcodeproj**, select **Next**, and run on an iPhone simulator. For a physical device or distribution, select your Developer Team. Bundle ID: `com.visionexperiencedeveloper.next`. Release candidate: **1.0.0 (1)**.

The committed Xcode project runs without project generators. To regenerate after adding source files, use `ruby scripts/generate-project.rb` with the xcodeproj gem installed. Do not regenerate after applying personal signing changes without preserving those changes in the generator.

## Documents and assets

- [Product and UX](docs/Product.md)
- [Architecture and schema](docs/Architecture.md)
- [Design system](docs/Design.md)
- [Verification and limits](docs/Verification.md)
- [App Store release package](release/app-store/README.md)
- [Visual asset index](release/app-store/index.html)

The App Store package contains English/Korean metadata, published policy/support links, review notes, eight final screenshots, two App Preview videos, and three icon variants. Build 2 is signed, uploaded, and attached in App Store Connect. Free pricing and Korea/Australia availability are saved. Apple preview processing currently blocks submission; see release/app-store/readiness.md for the latest state. Physical-device and TestFlight manual QA have not been performed.

Widgets, reminders, iCloud sync, multiple Visions, AI, accounts, and subscriptions are not part of this build.

## Repository contents

App source, tests, project configuration, documentation, and App Store creative materials are included. Build products, signing credentials, local execution evidence, generated ZIP packages, and the separate website checkout are excluded. Verification documents describe past runs; referenced local logs and result bundles are not included in the repository.
