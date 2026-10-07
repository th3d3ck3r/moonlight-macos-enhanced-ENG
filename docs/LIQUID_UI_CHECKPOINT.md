# Liquid UI preview checkpoint

UI-only branch: `liquid-ui`. Functional baseline: `1e625482bc9e4d3d86007334bb632fe0faa5d2ad` (Manual Build 21). Do not merge into master or restore discarded customizations.

## Implemented
- Shared SwiftUI/AppKit navigation glass: genuine macOS 26 APIs, native macOS 12 materials, opaque accessibility fallbacks and dynamic appearance refresh. Existing helper source is already included in the Xcode target.
- Unified main/Settings toolbars, system fonts and settings symbols; Settings uses NavigationSplitView on macOS 13+ with a macOS 12 fallback and unchanged selection keys.
- Host sidebar includes textual states and computer symbols. Game artwork uses restrained hover/selection scale and honors Reduce Motion.
- Streaming/offline workspace controls use navigation glass; offline animations honor Reduce Motion. Floating handle and titlebar controls use native glass with existing callbacks, drag and hit-test behavior.
- Diagnostics use semantic colors and native settings buttons; connection detail cards refresh dynamic appearance. About identifies the preview and retains the manual update notice.
- Native alerts, pairing sheets, connection editor, computer cards, game library and all five Settings panes retain their controllers, outlets and standard controls. Readable content and streaming video are not wrapped in glass.

## Validation
Foundation commit: `68d9b280d2e49cf6b956bc66826d79fbfa897e42`.
Local English/LAN and update-isolation audits pass; storyboard/XIB XML parses and diff whitespace checks pass. No new project references, settings keys, bundle identity, signing or permission changes. No networking, common-c, decoding, input capture or renderer changes.
Dedicated branch CI builds full x86_64 and Universal apps, runs common-c sanitizer, host-response and credential-redaction tests, audits packaged apps and verifies application/helper binary slices. Publication is a prerelease and cannot replace the latest Manual release.
Runner screenshots are attempted separately and may be blocked by GUI permissions. Smoke captures do not establish comprehensive physical testing. Chat concept imagery is a mockup.

## Physical Intel Tahoe checklist
- Pair/stream with Sunshine or Vibepollo; confirm Local Network authorization, H.264/HEVC, VideoToolbox, optional HDR, audio/microphone and clipboard.
- Inspect host/game states, every Settings pane, manual-address/pairing sheets, connection editor/details, About, diagnostics and overlays at minimum/large sizes, light/dark appearances.
- Toggle Reduce Transparency, Reduce Motion and Increase Contrast while open; verify selections, keyboard/controller focus, Return/Escape and callbacks.
- Change settings and reopen to confirm persistence; verify manual updates only.
- Resize, fullscreen and move across displays; check floating handle/menu interactions and mouse capture.
- Compare CPU/GPU/frame pacing with Manual Build 21, overlays hidden/visible. Compilation does not verify Intel runtime performance or working pairing/streaming.

Next: resolve build failures, inspect captured screens where available and publish after mandatory automated checks pass. Exhaustive visual inspection and live-host performance remain physical testing tasks.
