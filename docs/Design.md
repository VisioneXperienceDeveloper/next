# Next — Small UI System

- Meaning before counts. Typography and whitespace identify the current Step, direction, and Journey.
- System text styles: largeTitle for primary questions and Step, title/title2 for supporting hierarchy, body for reading, caption for month and eyebrow labels. No fixed heights for text.
- Spacing: 8/12 for related copy, 16/24 for component content, 32 between Home sections. Main content padding 24; readable width capped at 560 points.
- Radius: 16 for editors, 32 for the single active Step surface, capsules for actions. No custom shadows. Navigation and sheets use the system appearance.
- Surfaces: system background, secondarySystemBackground for editable fields and current Step. Avoid a card for every element.
- Accent: restrained forest green in Light Mode, sage in Dark Mode. Primary button text uses an explicit adaptive OnAccentColor to retain contrast.
- Primary action: full-width native glassProminent button on iOS 26 and later, including iOS 27. Secondary actions use native glass capsules. Earlier systems retain bordered styles. Destructive deletion lives in Vision editing and requires native confirmation.
- Motion: 0.18-second completion phase change; removed with Reduce Motion. A quiet checkmark and soft haptic indicate completion. Save Reflection and create Step use the same restrained haptic vocabulary.
- Input: multiline native TextField, focused after presentation, tap outside the input to dismiss the keyboard, interactive keyboard dismissal, whitespace trimming, no arbitrary content length cap. Editors remain scrollable at larger system text sizes.
- Accessibility: native semantic controls and labels, headers for hierarchy, user text verbatim, minimum comfortable controls, scrollable text, decorative symbols hidden. Automatic contrast/hit-region/description audits supplement manual VoiceOver and device review; they do not replace them.

Shared action styling remains in Components/PrimaryButton.swift; it is not a separate design framework. Full-loop screenshots, large Dynamic Type captures, and in-memory previews are the visual review artifacts. No empty Settings, badges, productivity numbers, or celebratory mechanics were added.

## Liquid Glass adoption

- Glass belongs to controls: primary actions, Journey navigation, the Home completion affordance, and secondary editing/reflection actions. Vision statements, input fields, and historical entries retain opaque semantic surfaces.
- Native `safeAreaBar` positions editing actions over the scroll edge on iOS 26+. `safeAreaInset` preserves the earlier-iOS layout. `GlassEffectContainer` groups nearby controls; no extra glass background is layered behind glass buttons.
- Reduce Transparency and Increased Contrast select bordered controls and an opaque completion affordance. System Liquid Glass handles the native motion preference; no custom glass morphing animation is introduced.
- Runtime and toolchain: iOS 26.5 Simulator with stable Xcode 26.6. The visual direction takes inspiration from iOS 27; it does not require an iOS 27 runtime, beta SDK, or iOS 27-only API. Retain the existing iOS 17 minimum and guarded older-system fallbacks. Do not switch the machine-wide Xcode selection.
- Design foundation: [Apple — Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass) and [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views).
