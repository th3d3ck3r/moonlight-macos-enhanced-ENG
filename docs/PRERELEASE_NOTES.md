Native Moonlight macOS Enhanced English rebuild with the official Moonlight 6.2 protocol core merged into the customized Enhanced core.

**Downloads:** `Moonlight-x86_64.zip` for Intel Macs; `Moonlight-universal.zip` contains Intel and Apple Silicon slices. Unzip and move Moonlight.app to Applications.

This is a **prerelease for Intel Tahoe testing**. Full application builds, architecture checks, native host-XML regression tests, common-c integration tests and English/Local Network bundle checks must pass before this release is published. These are build and automated-test results, not live streaming certification.

Changes include RTSP/security and FEC fixes, extended keyboard keys/keypad Enter, Sunshine client identity handling, explicit hardware VideoToolbox preference with a software fallback setting, optional HDR/SDR safety, device-based MetalFX availability, English UI/diagnostics and preserved Local Network support. Enhanced microphone, clipboard, HDR negotiation and multichannel audio extensions remain in the maintained core.

Native rendering is retained. No Qt, MoltenVK or libplacebo conversion; no merge into master.

The app is **not Developer ID signed or notarized**. Gatekeeper may require an explicit local allow action. The privileged AWDL helper has an ad-hoc signature; its installation/authorization is not validated with a Developer ID signature in this release.

Please test discovery, Local Network permission, pairing/app list, H.264/HEVC SDR, optional HDR, renderers/decoder fallback, input/audio, reconnect, microphone and clipboard against your host. See [the integration review and Intel Tahoe checklist](https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/blob/master/docs/MOONLIGHT_6_2_REBUILD.md) for exact upstream commits, conflict resolutions, exclusions and untested behavior.
