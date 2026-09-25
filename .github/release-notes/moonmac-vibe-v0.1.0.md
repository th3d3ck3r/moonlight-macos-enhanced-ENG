# 🌙 moonmac-vibe v0.1.0

The first VibePollo-focused build of this native macOS Moonlight client. **Black & Crimson** appearance, a VibePollo host health window, five-minute graphs and combined stream statistics are included. 🎮📊

**Download:** `moonmac-vibe-x86_64.dmg` for Intel Macs, `moonmac-vibe-arm64.dmg` for Apple Silicon, or `moonmac-vibe-universal.dmg` for either. Open the DMG and drag `moonmac-vibe.app` to Applications.

**Get started:** Pair your VibePollo host normally. For host stats, create a read-only API token scoped to `GET /api/host/stats`, then enter your VibePollo Web UI HTTPS address and token in **Window → VibePollo Host Stats** (⇧⌘H). Polling runs about every two seconds while the window is open. If the host has a self-signed certificate, verify its fingerprint before trusting it. See the [project README](https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/blob/codex/crimson-vibepollo-stats/README.md) for setup and troubleshooting.

**Changes:** [Full changelog](https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/blob/codex/crimson-vibepollo-stats/CHANGELOG.md).

This community build is unsigned and not notarized. CI verifies app and helper architectures; physical Mac/VibePollo streaming remains to be tested. macOS may require **Open Anyway** under Privacy & Security.
