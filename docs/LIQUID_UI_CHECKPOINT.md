# Liquid UI preview checkpoint

UI-only branch: `liquid-ui`. Functional baseline: `1e625482bc9e4d3d86007334bb632fe0faa5d2ad` (Manual Build 21). Do not merge into master or restore discarded customizations.

## Implemented
- Shared SwiftUI/AppKit navigation glass: genuine macOS 26 APIs, native macOS 12 materials, opaque accessibility fallbacks and dynamic appearance refresh. Existing helper source is already included in the Xcode target.
- Unified main/Settings toolbars, system fonts and settings symbols; Settings uses NavigationSplitView on macOS 13+ with a macOS 12 fallback and unchanged selection keys.
- Collection views include native symbol/text empty and search states. Host sidebar includes textual states and computer symbols. Game artwork uses restrained hover/selection scale and honors Reduce Motion.
- Streaming/offline workspace controls use navigation glass; offline animations honor Reduce Motion. Floating handle and titlebar controls use native glass with existing callbacks, drag and hit-test behavior.
- Diagnostics use semantic colors and native settings buttons; connection detail cards refresh dynamic appearance. About identifies the preview and retains the manual update notice.
- Native alerts, pairing sheets, connection editor, computer cards, game library and all five Settings panes retain their controllers, outlets and standard controls. Readable content and streaming video are not wrapped in glass.

## Validation and preview
Validated application commit: `ede92a8dd00b24f6a442b6f62b4759f1a4b2e8c2`.
Both full x86_64 and Universal jobs passed in [run 37569705649](https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/actions/runs/37569705649). Checks include common-c ASAN/UBSAN tests, native host XML security/compatibility, credential redaction, full Xcode builds, packaged English/manual-update audits and application/AWDL helper architecture verification.
Local English/LAN and update-isolation audits, storyboard/XIB XML parsing and diff whitespace checks passed. No changes to project references, settings keys/defaults, bundle identity, signing, Local Network permissions, networking, common-c, decoding, input capture or renderer architecture.

Actual hosted Tahoe captures were reviewed: main window light/dark, Stream/Video/Audio/Input/App Settings and dark App Settings. Settings fits the display, pane navigation and native selection contrast work, and “Match System” follows OS appearance. See [actual screenshots](../readme-assets/liquid-ui-actual/). The earlier chat concept image is a mockup. Captures do not establish exhaustive lower-content, host-dependent or physical Intel testing.

Liquid UI Preview 7 publishes only artifacts from the successful run above, as a prerelease, without replacing Manual Build 21. Preview 3 is superseded after correcting Settings placement and empty-state alignment found during screenshot review. Publication metadata and screenshots do not alter the validated application sources.

## Physical Intel Tahoe checklist
- Pair/stream with Sunshine or Vibepollo; confirm Local Network authorization, H.264/HEVC, VideoToolbox, optional HDR, audio/microphone and clipboard.
- Inspect host/game states, every Settings pane, manual-address/pairing sheets, connection editor/details, About, diagnostics and overlays at minimum/large sizes, light/dark appearances.
- Toggle Reduce Transparency, Reduce Motion and Increase Contrast while open; verify selections, keyboard/controller focus, Return/Escape and callbacks.
- Change settings and reopen to confirm persistence; verify manual updates only.
- Resize, fullscreen and move across displays; check floating handle/menu interactions and mouse capture.
- Compare CPU/GPU/frame pacing with Manual Build 21, overlays hidden/visible. Compilation does not verify Intel runtime performance or working pairing/streaming.

Next: perform the physical checklist above. No live pairing/streaming, CPU/GPU/frame-pacing comparison, multiple-display testing or physical Intel runtime testing was available. Future publication must update the validated run/SHA and review new captures after relevant source changes.

## Physical testing follow-up — October 7
User's Intel MacBookPro14,1 reports Finder-launched requests blocked as Local network prohibited. Installed Preview 7 executable is unsigned; Terminal launch restores host access. This is a separate release signing/permission issue, with no signing or backend changes in this UI fix. Pairing persisted and the app list loaded after Terminal launch. Stream start then crashed in MLEdgeMenuHandleView.layout: resizing NSImageView caused AppKit window constraint invalidation during display. Icon geometry now uses declarative constraints with no layout override. A native regression harness exercises production handle/material code over 200 display cycles, rectangular sizes and light/dark appearances. Full revalidation and corrected preview publication pending. Physical streaming is still unverified.
