# 📝 Changelog

Changes specific to moonmac-vibe. The [upstream Moonlight macOS Enhanced project](https://github.com/skyhua0224/moonlight-macos-enhanced) has its own history; inherited features are described in [README.en.md](README.en.md).

## [v0.1.1] — 2026-09-25

### Fixed

- Made English the default language on new installations while retaining existing user language choices.
- Replaced hard-coded Chinese labels in the stream menu, connection editor, timeout and reconnect overlays, microphone authorization messages, and log viewer with natural English wording.
- Translated curated log categories and summaries; preserved Chinese error phrases where they are needed to recognize older host or system logs.

### Verification

- Checked the macOS storyboard, English strings table, runtime language map and source strings for untranslated UI copy. The CI build still verifies Intel, Apple Silicon and universal packages. Physical Mac playback remains to be tested.

## [v0.1.0] — 2026-09-25

First VibePollo-focused moonmac-vibe release. 🌙

### Added

- App-wide Black & Crimson appearance for the host browser, settings, streaming controls and stats window, with a persistent appearance preference.
- A VibePollo Host Stats window using read-only `GET /api/host/stats` access, macOS Keychain token storage and explicit certificate fingerprint approval when needed.
- Host CPU, GPU, encoder, RAM, VRAM, temperature and network measurements where available, plus approximately five minutes of history at a two-second polling interval.
- Client FPS, network loss, jitter, video bitrate, decode and render measurements alongside host stats for the selected streaming host. FPS and loss have five-minute graphs.
- HTTPS-only stats endpoint and redirect blocking so the token is not forwarded.
- Branded Intel, Apple Silicon and universal DMGs built by GitHub Actions, including architecture checks for the main executable and bundled helper.

### Inherited from upstream

- Native AppKit/SwiftUI Moonlight client, renderers and codec negotiation, host pairing, streaming settings, input and controller controls, audio paths and diagnostics. Some advanced paths require compatible host implementations.

### Known limitations

- The DMGs are unsigned and not notarized by Apple. macOS may require **Open Anyway** on first launch.
- VibePollo host stats require the Web UI to be reachable and a token scoped to `GET /api/host/stats`. Missing sensors report N/A; network conditions can vary the sampling interval.
- CI compiles Intel and Apple Silicon variants and verifies executable slices. Streaming and the stats display have not yet been exercised on a physical Mac and VibePollo host.

[v0.1.0]: https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/releases/tag/moonmac-vibe-v0.1.0
[v0.1.1]: https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/releases/tag/moonmac-vibe-v0.1.1
