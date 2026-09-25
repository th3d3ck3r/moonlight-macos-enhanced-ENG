# 🌙🖤 moonmac-vibe 🔴✨

### Your Mac. Your VibePollo host. One crimson command center. 🎮📊

**moonmac-vibe** is a native macOS Moonlight streaming client built primarily for [VibePollo](https://github.com/Nonary/Vibepollo). It brings an app-wide **Black & Crimson** look, a live host stats window, five-minute graphs, an English-first interface, and the full streaming foundation of [Moonlight macOS Enhanced](https://github.com/skyhua0224/moonlight-macos-enhanced).

[**⬇️ Grab a release**](https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/releases) · [**📝 Changelog**](CHANGELOG.md) · [**🧰 Inherited feature guide**](README.en.md) · [**🙏 Credits**](ACKNOWLEDGEMENTS.md)

## ✨ The good stuff

| | Feature | What it does |
| --- | --- | --- |
| 🎨 | **Black & Crimson everywhere** | Styles the host browser, settings, streaming controls and stats window. Choose **Settings → App → Appearance → Black & Crimson** or **View → Appearance → Black & Crimson**. Your choice persists. |
| 🗣️ | **English-first UI** | English is the default on new installs, including stream menus, connection editing, diagnostics and log labels. An existing language preference still takes precedence. |
| 🖥️ | **VibePollo host health** | Open **Window → VibePollo Host Stats** (⇧⌘H) for CPU, GPU, encoder, memory, temperature and network measurements the host exposes. Missing sensors show N/A. |
| 📈 | **Five-minute graphs** | About 150 samples at roughly two-second intervals while the window is open; see host trends and, while streaming to the selected host, client FPS and network loss. |
| 🚀 | **Streaming telemetry** | Client FPS, loss, jitter, video bitrate, decode and render time appear beside host measurements during the matching stream. |
| 🎮 | **Full streaming foundation** | Native AppKit/SwiftUI client with Intel and Apple Silicon builds, pairing, VideoToolbox/Metal renderers, H.264/HEVC/AV1 negotiation, HDR, audio, input, controller and connectivity settings inherited from upstream. Host support controls what is available. |

Host stats use VibePollo's Web UI API, separate from the GameStream connection. **You can stream without setting up a stats token.** 💡

## 📦 Download & launch

1. Head to [**Releases**](https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/releases). For an Intel Mac choose `moonmac-vibe-x86_64.dmg` 🧱; for Apple Silicon choose `moonmac-vibe-arm64.dmg` 🍎; or grab `moonmac-vibe-universal.dmg` for either.
2. Open the DMG and drag **`moonmac-vibe.app`** into Applications.
3. Launch the app, add your VibePollo host and pair with the PIN displayed by the client. 🎯
4. If macOS blocks this unsigned, unnotarized community build, right-click the app and select **Open**, or use **System Settings → Privacy & Security → Open Anyway**. After verifying your download, if it is still blocked, run `xattr -dr com.apple.quarantine /Applications/moonmac-vibe.app` in Terminal.

The project targets macOS 12 or later, including an Intel build intended for macOS 15. GitHub Actions compiles the release and checks the architecture of the app and its bundled helper. Physical Mac playback and VibePollo integration still need hands-on testing.

## 🔎 Can't see your host?

1. In macOS **System Settings → Privacy & Security → Local Network**, allow **MoonMac Vibe** if it appears. Version 0.1.2 declares local-network access and the `_nvstream._tcp` Bonjour service used for host discovery. Relaunch the app after changing access.
2. Make sure VibePollo is running with streaming and `enable_discovery` enabled. Put the Mac and host on the same local network; guest Wi-Fi isolation and some VPNs can prevent Bonjour discovery.
3. Use **+ → Add Host Manually** in the host browser and enter the host computer's LAN IP address, such as `192.168.1.10`. **Do not enter the stats Web UI URL or its port `47990` here.** The streaming client contacts VibePollo's GameStream service, normally on port `47989`; the Web UI address belongs in the separate stats window.
4. If manual add fails too, verify the host's streaming service and firewall allow connections from the Mac. Include the exact error and a sanitized **Settings → App → Debug Log** when reporting the problem.

## 📊 Plug in VibePollo stats

1. Enable the VibePollo Web UI and make its **HTTPS** address reachable from your Mac. Its usual HTTPS port is `47990`.
2. In VibePollo's Web UI, create an API token scoped only to **GET `/api/host/stats`**. This is a metrics token, separate from streaming pairing. 🔑
3. In moonmac-vibe choose **Window → VibePollo Host Stats** (⇧⌘H). Enter an address such as `192.168.1.10` or `https://192.168.1.10:47990`, paste the token and click **Save Token**. The token lives in your macOS Keychain.
4. If VibePollo uses a self-signed HTTPS certificate, compare the SHA-256 fingerprint shown in the app against the certificate on your host **before** trusting it. A changed certificate needs fresh approval. 🔐
5. Start streaming to that host. Host measurements and client stream metrics now share the window. 📉📈

**What if it looks empty?** Check that the Web UI is reachable, the token allows `GET /api/host/stats`, and the selected address matches the streaming host. A 401/403 means VibePollo rejected the token. Missing sensors display N/A. Polling is roughly every two seconds while the stats window is visible; network delays can change the timing. The token is sent only over HTTPS and is never forwarded on redirects.

## 🧩 Compatibility & honest limits

**VibePollo is the main intended host.** Standard Sunshine and compatible GameStream hosts can still use the streaming client; VibePollo's host graphs require its own stats API. Some inherited microphone, clipboard, HDR and audio paths depend on host support. See the [detailed upstream feature guide](README.en.md) for those options. You do not need Foundation Sunshine to display VibePollo metrics.

Finder shows **`moonmac-vibe.app`** and macOS displays **MoonMac Vibe**. The internal `Moonlight` executable and upstream bundle identifiers are retained for integration with the bundled helper. Release builds are unsigned and not notarized by Apple.

## 🛠️ Want to build it yourself?

**No local dev setup is needed to use a release DMG.** For source builds, use a Mac with Xcode:

```bash
git clone --recursive https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG.git
cd moonlight-macos-enhanced-ENG
curl -L -o xcframeworks.zip https://github.com/coofdy/moonlight-mobile-deps/releases/download/latest/moonlight-apple-xcframeworks.zip
unzip -o xcframeworks.zip -d xcframeworks/
open Moonlight.xcodeproj
```

Choose the **Moonlight for macOS** scheme and configure your signing team if you want to sign your own build. [GitHub Actions](.github/workflows/build.yml) produces Intel, Apple Silicon and universal DMGs, checking the architecture of both the main binary and the privileged helper.

## 🐛 Found a bug? Join the party.

Open an [issue](https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/issues) with your Mac model, macOS version, VibePollo version, reproduction steps and useful diagnostics from **Settings → App → Debug Log**. Please keep API tokens and credentials out of screenshots and logs. Contributions should preserve upstream attribution and check the Intel build. 🤝

## 🙏 Credits & license

Built on [Moonlight macOS Enhanced](https://github.com/skyhua0224/moonlight-macos-enhanced) and its Moonlight foundations. [VibePollo](https://github.com/Nonary/Vibepollo) is a separate host project; moonmac-vibe is not its official client. See [ACKNOWLEDGEMENTS.md](ACKNOWLEDGEMENTS.md) for upstream contributors and related projects. The code remains under [GPL-3.0](LICENSE.txt). 🌙
