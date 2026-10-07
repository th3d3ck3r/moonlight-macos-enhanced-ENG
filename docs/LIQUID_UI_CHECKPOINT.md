# Liquid UI Preview 13 checkpoint

Branch: `liquid-ui` only. Manual Build 21 / `master` baseline: `1e625482bc9e4d3d86007334bb632fe0faa5d2ad`, unchanged. Do not merge UI changes into master or restore discarded customizations.

## Corrected application
Validated application/test commit: `b36e9b181d2adb21f9bc45f44a28718243225d0f`. The release tag includes subsequent publication metadata; its application sources are verified identical to this commit.
- Floating streaming handle uses declarative icon constraints instead of resizing NSImageView inside layout(), which caused the reported Tahoe AppKit display-cycle exception.
- Collection count callbacks only return counts; empty-state view updates occur in controller refresh paths.
- Offline overlays fully honor Reduce Motion.
- Native glass remains limited to navigation/controls, guarded for macOS 26+, with native macOS 12 fallbacks and system appearance/accessibility support.
- System toolbars, Settings controls/sidebar, host statuses, game selection, diagnostics, connection details and About retain existing controllers and actions.

Preview 7's physical stream-start crash is confirmed and that release is superseded. Preview 13 is a prerelease; it does not replace the latest English Manual release.

## Three review passes
1. Reviewed every UI source diff against the baseline: lifecycle/layout, availability guards, observers, material ownership, Objective-C bridges, responder/callback behavior and persistence. Networking, common-c, renderer/decoder/video/input sources, settings keys/defaults, signing, identity and permissions remain unchanged.
2. Local English/LAN and manual-update audits, whitespace checks and parsing of all seven storyboard/XIB resources passed. Project/resource references and outlets remain unchanged.
3. [Full CI run 37577092663](https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/actions/runs/37577092663) passed both x86_64 and Universal builds, common-c ASAN/UBSAN tests, host XML/security compatibility, credential-redaction tests, packaged-app audits and app/AWDL helper slice checks. A native test using production handle/material implementations passed 200 display cycles with resizing/appearance changes and 50 empty-state create/update/remove cycles. Hosted runtime tests do not establish physical Intel streaming performance.

All eight fresh [actual Tahoe captures](https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/actions/runs/37577092663/artifacts/11462453527) were reviewed: main light/dark, five Settings panes and dark App Settings. Main text/icons, native selection, window placement and Match System appearance are visible. Lower scrolled content and host-dependent surfaces still need physical inspection. Earlier chat concept imagery is a mockup; repository screenshots under readme-assets/liquid-ui-actual are from Preview 7.

## Unresolved signing/permission issue
Packages retain the existing unsigned build configuration. The user's Finder-launched copy reports Local network prohibited despite enabled switches. Direct executable launch from Terminal restores access; pairing persisted and the app list loaded. This is a temporary diagnostic workaround, not a permanent permission fix. Reliable release signing/permission handling requires separate work; this UI correction does not solve it.

## Physical Intel Tahoe retest
- Launch/resume/stop repeatedly; check H.264/HEVC hardware decoding, optional HDR, audio, microphone and clipboard.
- Show/hide/drag the floating handle; open menus/diagnostics during streaming. Check keyboard/controller focus and mouse capture.
- Resize, fullscreen and move across displays; inspect secondary sheets/windows and all scrolled Settings content in light/dark.
- Toggle Reduce Motion, Reduce Transparency and increased contrast; change settings and reopen to confirm persistence.
- Compare CPU/GPU/frame pacing with Manual Build 21, with overlays hidden/visible.

Next: physical streaming retest and separate signing investigation. Future publication must validate new sources, update the pinned run/SHA and review relevant captures before release.
