# 🌙 moonmac-vibe v0.1.1

**VibePollo-focused macOS streaming, now with a complete English UI pass.** Stream menus, connection editing, diagnostics and log labels use natural English; English is the default for new installs. Existing language preferences remain intact. The Black & Crimson theme, VibePollo host stats window and five-minute host and stream graphs are included. 🎮📊

**Download:** `moonmac-vibe-x86_64.dmg` for Intel Macs, `moonmac-vibe-arm64.dmg` for Apple Silicon, or `moonmac-vibe-universal.dmg` for either. Drag `moonmac-vibe.app` from the DMG to Applications.

**VibePollo stats:** Pair your host normally. Create a read-only VibePollo Web UI API token scoped to `GET /api/host/stats`, then add the host HTTPS address and token in **Window → VibePollo Host Stats** (⇧⌘H). The window samples at roughly two-second intervals while open and shows client streaming metrics alongside host health when streaming to the same host. Verify a self-signed certificate fingerprint against your host before trusting it.

[**Setup guide**](https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/blob/master/README.md) · [**Changelog**](https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/blob/master/CHANGELOG.md)

Community builds are unsigned and not Apple notarized. CI verifies app and bundled helper architectures; physical Mac/VibePollo streaming still needs hands-on testing. macOS may require **Open Anyway** under Privacy & Security.
