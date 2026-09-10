# Next App Store media — 10 September 2026

Original artwork based on the user's [Easlo Experiments visual reference](https://screensdesign.com/apps/easlo-experiments/?id=1936).
White background, editorial serif opening, bold black captions, generous whitespace
and a large upright device. All UI is captured from Next 1.0.0 (1), Release configuration.

## Delivery

- Four [Korean screenshots](../screenshots/editorial/ko), four [English screenshots](../screenshots/editorial/en-US).
- Contact sheets: [Korean](../screenshots/editorial/Contact-ko.png), [English](../screenshots/editorial/Contact-en-US.png).
- App Previews: [Korean MP4](../videos/Next-App-Preview-ko.mp4), [English MP4](../videos/Next-App-Preview-en-US.mp4).
- Screenshots: 1320 × 2868 PNG, opaque RGB, iPhone 6.9-inch upload slot.
- Videos: 886 × 1920, 28 seconds, 30 fps, H.264 High Level 4.0, approximately 11 Mbps,
  BT.709, silent AAC stereo 48 kHz. Silence is intentional; the captions explain the footage.

Order: 01 Vision → 02 Focus → 03 Reflect → 04 Journey. App Store Connect can reorder
concurrent uploads; check the visible order after uploading. The 6.5-inch slot inherits
the 6.9-inch assets. The Korean captions do not imply a Korean app interface: version
1.0.0's interface is English, as disclosed in the store description.

## Source and verification

[DESIGN.md](DESIGN.md) records the design decisions and provenance. Screenshots are
laid out in [store-art.html](store-art.html) and rendered with
[render-store-art.cjs](../scripts/render-store-art.cjs). Use Node + Playwright on macOS
to reproduce system-font rendering. No font files or third-party reference imagery
are redistributed.

The video projects are [English](next-editorial/index.html) and
[Korean](next-editorial-ko/index.html), rendered with HyperFrames 0.8.33. Each has
`npm run check` and `npm run render`. [The edit decision list](../evidence/preview-edit-decision-list.json)
records real source clips, normal playback speed and trim points. The source recording
contains fictional portfolio example entries on an isolated simulator.

Final technical checks are in [media-verification.json](../evidence/media-verification.json).
Visual review covered every poster and the video scene holds/transitions. The initial
reflection AutoFill menu was removed by selecting a clean part of the recording.
The plugin's standalone animation-map script could not resolve its legacy producer
dependency; HyperFrames' current built-in motion check and visual review were used.

Apple references: [screenshots](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/),
[preview specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/app-preview-specifications/),
[preview content guidance](https://developer.apple.com/app-store/app-previews/).
