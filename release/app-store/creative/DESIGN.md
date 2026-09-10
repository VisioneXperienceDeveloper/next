# Next — editorial App Store artwork

The user's reference is the public App Store screenshot set at
https://screensdesign.com/apps/easlo-experiments/?id=1936, inspected on 10 September 2026.
Its restraint, type hierarchy, whitespace and front-facing device placement guide this
original layout. No reference app imagery, text, logo or device asset is reused.

## Style Prompt

A quiet editorial introduction to one personal vision and one next step. Warm white
posters, near-black type, a human italic serif opening and confident compact sans-serif
headlines. A large upright iPhone carries an unmodified screenshot from the shipping
Next build. Green belongs to the actual app. Four posters tell the story: vision,
focus, reflection, journey. Korean and English use the same composition.

## Colors

- `#fafaf9`: poster and video background
- `#121312`: main typography
- `#626661`: functional labels
- `#2d5948`: existing Next app accent, preserved in captures
- `#aaa9a5`: restrained metal edge on the code-drawn device shell

## Typography

English: local Baskerville Italic for the opening statement; Helvetica Neue Bold for
headlines. Korean: AppleMyungjo for the opening statement; Apple SD Gothic Neo Bold
for headlines. Final exports bake in the font rendering; font files are not redistributed.
Editable sources use system-font fallbacks and should be rendered on macOS for an exact match.

Screenshot canvas: 1320 × 2868. Header top 300 px, device top 884 px, centered device
width 1092 px. The bottom of the device is deliberately cropped, like the reference.
App Preview canvas: 886 × 1920. Use full recorded UI inside a smaller complete device,
with a brief caption above it so the bottom controls stay visible.

## Motion

28 seconds, silent by design, with an AAC stereo silent track for predictable delivery.
Actual captured interaction remains at normal speed. Remove waiting between actions.
Gentle 0.5-second transitions and small upward text/device entrances, with long readable
holds. Keep screen content sharp and undistorted. The last scene holds on the journey.

## What NOT to Do

- No gradients, decorative particles, noisy textures, bright new accent colors or 3D rotations.
- No invented interface, reconstructed app text, awards, testimonials or unsupported features.
- No reference-app screenshots or copied headline language.
- No phone bezel in the underlying raw evidence; hardware framing is a separate code layer.
- No implied Korean app UI: Korean is the store caption language; version 1.0.0 runs in English.

## Provenance

All app screenshots and video were captured from the Release simulator build on a
dedicated iPhone 17 Pro Max simulator. The portfolio scenario is fictional sample data.
Sources are under `../evidence/release-capture` and `../videos/source`.


Final App Preview uses full-frame real app footage without an exterior device frame; short captions sit in empty UI areas. The screenshot posters use the upright device frame.
