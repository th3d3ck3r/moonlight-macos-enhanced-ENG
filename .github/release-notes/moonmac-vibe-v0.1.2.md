# 🌙 moonmac-vibe v0.1.2

This release addresses a likely cause of VibePollo hosts not appearing on macOS 15: the app now declares its local-network purpose and the `_nvstream._tcp` Bonjour service it browses. The English interface, Black & Crimson theme, VibePollo stats window and five-minute graphs remain included. 🔴📈

Manual-add errors now identify the VibePollo/Sunshine streaming connection rather than incorrectly mentioning GeForce Experience, and include the underlying connection detail.

**Intel Mac:** download `moonmac-vibe-x86_64.dmg`. Apple Silicon and universal DMGs are also attached. Drag `moonmac-vibe.app` to Applications, open it and allow local-network access if macOS asks.

**Still no host?** In **System Settings → Privacy & Security → Local Network**, allow MoonMac Vibe if listed. Check that VibePollo streaming and discovery are enabled, then try **+ → Add Host Manually** with the host's LAN IP address (for example, `192.168.1.10`). The Web UI port `47990` is for stats, not for adding a streaming host. See the [troubleshooting guide](https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/blob/master/README.md#-cant-see-your-host).

These DMGs are unsigned and not notarized. CI verifies architecture and packaging, but host discovery must still be checked on a real Mac and VibePollo installation.
