# Native Moonlight 6.2 integration review

This rebuild retains the native macOS Enhanced application. It does not turn it into Moonlight Qt. The application version remains Enhanced 1.3.8; “6.2” identifies the upstream protocol/features reviewed, not an assertion that this is the Qt application.

## Sources and maintained branches

- Main: `th3d3ck3r/moonlight-macos-enhanced-ENG`, `rebuild-moonlight-6.2-english`.
- Clean Enhanced baseline: `a9f20cc28b8932fb55788144c700e964fbbefa26`. Existing English/local-network commits through `1f9624bbfe394f681394f22abc0435de303f4b43` remain ancestors.
- Customized common-c baseline: `f262d597f41c2c6cbccf2c034191d14b62a1f043`.
- Official Qt review: `v6.1.0..v6.2.0`, endpoint `de2467e433821664cdd2224aad8c89a625be1ad9`.
- Official common-c endpoint: `f900dd4767759c7b9d0e93bcea666b55c69ea62f`.
- Maintained common-c: `th3d3ck3r/moonlight-common-c`, `rebuild-moonlight-6.2-enhanced`.
- Common-c merge: `593193e2b7ccce75947d922c6e64ca9e3eed0489`; tests/main gitlink: `5b10cda18d896eb309ac03b453004f2856ae1c77`.

No earlier discarded customization was restored. Master was fast-forwarded to this rebuild only after the full Intel-only and Universal application builds and automated checks passed. Release tags remain pinned to their validated source commits.

## Native rebuild commits

| Commit | Purpose |
|---|---|
| `85fa098a94264c52d3b0d3ebdcdf23223199ccfb` | Integrate customized common-c with official Moonlight 6.2 protocol core |
| `317600335a2f48a0c581ed5ac454de3416c7cb44` | Keep Intel hardware decoding and add native fallback controls for Tahoe |
| `c35680813d7db08263f857cff0d7c81c7dea6615` | Port 6.2 extended keys, Sunshine identity and host response hardening |
| `8bc195f77f98a3d61d8aad93d36e830fe8e41af0` | Make macOS diagnostics and remaining UI English-only |
| `0341388703093c7b7a0946b88a6f23963cc374ae` | Validate full Intel and Universal native applications on Tahoe runners |
| `6918fadd6c8f82389db989f428064c5c981affaa` | Fix serverinfo response import for native identity handling |
| `f70e85a34ed6053c66754142a16d08d4310b2eca` | Fall back to SDR when Intel hardware or host cannot supply HDR |
| `a5020149c4d09e589786653442240ff8b35fe65a` | Publish opt-in prereleases only after both native build validations pass |
| `41e69bc0fc592377595b33c119e72bf21514d10b` | Test native XML parsers against malformed and entity-bearing host responses |
| `8720ad5d74973b03a541b32a2ce032f2247a6e54` | Fix clipboard block ownership warnings and group decoder fallback with renderer settings |
| `ab511153ccd7e1cbf0552ab935f125ec2841bc97` | Correct lipo architecture validation argument order |
| `2053116ab3c02d71f9855a544949559aa0ced499` | Record integration review and enable tested prerelease publication |
| `5e3bf0575505f8257b27cdf0fd7faafd5a8e4d77` | Build explicit x86_64 targets on the working Tahoe runner |

## Common-c integration

A true merge preserves Enhanced history and upstream ancestry. The last shared base is `62687809b1f7410c3db4be2527503a54ae408d70`; that ENet update was already present. All 19 subsequent upstream commits are integrated, including platform-only changes, with native Xcode source references adjusted for nanors.

| Exact upstream commit | Change |
|---|---|
| `7022b337a9a682f1d974aed69f6065fa57b4164f` | Refactor BSD socket errors for Win32 and add EMSGSIZE |
| `7b026e77be62175104640e7e722b758df6d3d0d7` | Harden RTSP handling for malformed Session headers and oversized responses |
| `2600beaf13f18bfa43453609cf5e3b84a4227760` | Add support for controllers with dual touchpads |
| `40d87314d05b87b623cf62b50c8cd471209beaeb` | Add NXDK (Xbox) support |
| `47b4d338b15d27f0f9d7644ce330ad162e2490f8` | Skip Reed-Solomon SIMD variants for NXDK |
| `1fddbcb7c66ff3c2202d32f245c63d7e829b2578` | Don't leak rswrapper into our headers |
| `99c45d35ad5f9f5d00f3230b167faa611503c279` | Fix compatibility with GCC versions that lack __has_builtin() |
| `1f764276e848ae2ec7815ef90d1c1748272e074a` | Switch to upstream nanors with native SIMD and GFNI runtime dispatching |
| `2ea47752c3051d72a64bcca190024e8b354fa1ef` | Bump nanors from `c3529fd` to `17fc7d6` |
| `82e25148549d249a80aaf4afc68e2abb07072edf` | Fix compilation for 3DS (#140) |
| `703a06946861ff82cd33e5e13c59c1b017f7ded9` | Bump enet from `0eb84dc` to `aca8784` (#144) |
| `e41355ea01670fd4c830b384009d31dd0339a705` | Bump nanors from `17fc7d6` to `b1e3c22` (#145) |
| `518b244152ab791e604227bd27319789279660f4` | Rewrite MbedTLS codepaths to use the modern PSA APIs |
| `874ac9548f1bd6f095ef2b435c42cdde460e7821` | Add LI_CTYPE_STEAM controller type |
| `d85371cd8cb6304e66ef90a02e2e1609a8621906` | Fix RFI after a multi-block frame loss |
| `be438856af5bf5b87cc43715b82eb7b503f9c3a6` | Fix handling of a partially dropped IDR frame |
| `62e066388f1a1b133e0bee947b9a374311a3354b` | Don't speculatively report losses if RFI is disabled |
| `5a2632990f5d77f6090cfb6f70797c1e16a630e0` | Add section 7 exception for app store distribution |
| `f900dd4767759c7b9d0e93bcea666b55c69ea62f` | Add MODIFIER_EXTENDED flag to indicate extended keys |

### Conflict resolutions

| Area | Resolution |
|---|---|
| Build/RS | Adopt upstream nanors and oblas sources, retain Enhanced build platform logic; replace old private parity matrix field with nanors `p` while retaining NVIDIA audio parity coefficients. |
| Input protocol | Retain context-based APIs. Add dual-touchpad context API and legacy touchpad-zero wrapper; preserve packet layout. Apply extended-key flag and NVIDIA compatibility stripping. |
| Initialization | Keep reference-counted platform initialization/cleanup and Enhanced session contexts, incorporating upstream platform guards. |
| RTSP | Retain microphone setup/session contexts; incorporate response-size and malformed/empty Session-token validation. |
| RTP video/depacketizer | Adapt upstream frame-loss fixes to context APIs, including the new frame index, RFI-disabled guard, and context frame-type check for partial IDRs. |
| SDP | Preserve Enhanced microphone encryption, clipboard feature bits, HDR range and 7.1.4 negotiation; incorporate upstream formatting changes. |
| Crypto | Adopt upstream modern MbedTLS PSA codepaths; retain null-safe context destruction. macOS uses OpenSSL. PSA has not been executed in this validation. |

Microphone, clipboard text/image, dynamic-range, compatibility audio, multichannel audio and connection/buffer extensions remain in the customized core. Retaining source/API behavior is not evidence of successful live end-to-end operation.

## Qt 6.1 to 6.2 classification

A = compatible configuration/core improvement; B = native reimplementation or equivalent native behavior; C = architecture/platform-specific implementation not copied. IDs below identify the reviewed source commits, not cherry-picks into the native repository. Native implementations have their own commits.

| Classification | Qt source commits | Native decision |
|---|---|---|
| A | `ae1c65805c2e7bd659477b05ec59d537c4b56d44` | Add both Game Mode plist declarations. Actual Game Mode activation, particularly Intel behavior, requires device testing. |
| A | `131cb270` | Bonjour `_nvstream._tcp` declaration already present; preserve Local Network description and English localization. |
| A | common-c series above | Full merged protocol/security/input/FEC core, preserving Enhanced extensions. |
| B | `c0f62ad64e974b392903aa8d0c262fa9075c0205` | Native NSEvent extended-key handling, keypad Enter distinction, physical-key held-state tracking and release on capture loss. |
| B | `170801ba9f1e516f6d1f420a294a1564c4f2107e`, `1be234e9` | Use real client identity after valid non-GFE serverinfo; retain legacy shared ID for MJOLNIR/GFE. Quit retrieves host identity too. Per-client ID is already loaded at HttpManager initialization. |
| B | `63c48be6d425a62097cce97c64d001feb07e89e8`, `cdacb3d2` | Reject malformed/empty/oversized XML, network entity loading and DTD responses; skip invalid values/app IDs. Preserve acceptance of empty app titles. |
| B | `4453e4ae` | Existing Auto/Native/Metal/Compatibility renderer UI already supplies choice. Improve it with persistent software decoder fallback rather than duplicate renderer controls. |
| B | `ccaca68570c0858caa64016854c88c0a0e57b342`, `57db20016a2edfaad540693cf57a7621bd5815f2`, `9cbba106`, `7d6ce0b4` | Preserve CVDisplayLink/native timing and renderer fallback. No CAMetalDisplayLink is introduced on Intel. Qt VTMetal scheduling/probing cannot be copied into native MTKView/sample-buffer queues; do not force a new default without timing measurements. |
| B | `200cab9d17ef63048a0d9f7a184bed604376b25b` | Existing native CAEDRMetadata/HDR10/HLG and tone-map choices retained. Add SDR safety when the negotiated format is not 10-bit. |
| B/C | `c1623ff4`, `b2f0828d`, `2bea406f`, `a903c5ce`, `4570fba8`, `3f26217d` | Existing native pixel-format range and color metadata handling retained. SDL/DRM plane handling does not apply; do not globally change stream range without host/color-bar verification. |
| B | `2c12ad29`, `9b305051`, `181dba58`, `af37002a`, `7fab5007`, `229f5e4c`, `93dc6d6b` | Native renderer has its own precision, matrices, pixel-format and metadata paths. No wholesale Qt shader/FP16 rewrite; requires visual accuracy and GPU timing tests first. |
| B/C | `53a7680a`, `85ea2828`, `88b4a17f`, `83262232`, `a6f8901a` | Native HEVC/AV1 selection already checks hardware support; H.264 remains baseline. Explicitly request optional hardware VideoToolbox acceleration and log actual decoder choice. FFmpeg probing/reuse and reinit workarounds are not native VideoToolbox lifecycle code. |
| B | `4cf498b0`, `c7bc7632` | Native ring buffer already derives frame count from samples/sample-rate and a duration target. SDL audio queue/platform workaround does not apply; preserve Enhanced CoreAudio modes/7.1.4. |
| B/C | `8fe279c9`, `d2f6990b`, controller database bumps | Common core supports dual pads and Steam controller type. Native GameController/HID adapters are retained. No SDL mapping/database import; native two-pad/Steam-device detection has not been implemented or tested. |
| B/C | `534ce027`, `29294553`, `b75fe0d9`, `7f7f2c26`, `bba2faa6`, `2e9fbecf`, `dedb0c03` | Native input/capture/settings already control grab and shortcuts. Preserve Cocoa/CoreHID paths; SDL grab, hotplug, text input and scroll fixes cannot be transplanted. New extended keys are the selected native keyboard port. |
| B/C | `54283ce0`, `700655c0`, `d2fa4889`, `e4be57db`, `dbcc6a90`, `bdfadb1c`, `5034a324` | Native connection/context ownership and Cocoa asynchronous UI retained; Qt event-loop, CLI, Vulkan and QML loading changes are not copied. Reconnect/start/stop need host stress testing. |
| C | `1eb76bbd`, `8ec57251`, `e785be03` | QSslKey BIO ownership, Windows CFG and OpenSSL-4 Qt build adaptations are not the native Security/NSURLSession paths. Core RTSP/security fixes are integrated separately. |
| C | `e223bf9a`, `8c6b4220`, `ec75f0d8`, `ca7d61f5`, `a9ad0482`, `d997a0d0`, `6e231778`, `06bd8a73`, `50364fd5`, `51cc5a85` | Do not add libplacebo, Vulkan/MoltenVK swapchains or Qt default-selection changes. Preserve native VideoToolbox, Metal and sample-buffer architecture. |
| C | `b108684e`, `2fc0d84a`, `fba7c411`, `2328713f`, `acea86de` | Qt h264bitstream SPS rewriting/debug checks are not native CMVideoFormatDescription construction; avoid introducing another parser without a native decoding reproduction. |
| A/C | `b0ac3713`, dependency/build-requirement series, `5ac25421` | Validate native target on Tahoe Intel/ARM runners. Keep native dependency stack and deployment floor; Qt 6.11/SDL3/prebuilt requirements and minimum OS bump are not native requirements. |
| C | Remaining QML/translations, Windows D3D/DRM/Linux/Steam Link/Android platform work | No compatible native macOS behavior change; not imported. |

### Issue #1696 and Intel/Tahoe decisions

Reviewed [Moonlight Qt issue #1696](https://github.com/moonlight-stream/moonlight-qt/issues/1696) and its renderer discussion. Intel Tahoe latency reports motivated retaining selectable native/compatibility rendering and avoiding a forced Metal default. The native client does not share the Qt renderer implementation, so this rebuild does not claim that issue #1696 is fixed or that Qt environment-variable workarounds apply here.

- Explicit optional hardware VideoToolbox decoding stays enabled by default on Intel. Software decoding is a global persistent option applied at the next connection for Native/Metal; Compatibility uses the system's decoder selection.
- No forced hardware-only requirement: unsupported format paths can fall back.
- HEVC and AV1 are gated by hardware capability rather than CPU architecture. H.264 remains advertised.
- HDR can promote HEVC negotiation. When no available HDR codec path exists, the session falls back to SDR; an 8-bit negotiated stream uses SDR presentation.
- MetalFX availability queries the actual MTLDevice, in both Settings and renderer, rather than assuming all macOS 13+ GPUs support it.
- Universal helper build correctly splits Xcode's space-separated ARCHS list in zsh.
- Native timing/renderer selection, SDR/HDR metadata, controller, microphone, clipboard and audio settings remain intact.

## English and Local Network

Remaining menus, host editor, diagnostics, overlays, microphone messages and logging strings were converted to English. LanguageManager always selects English and removes the Chinese translation dictionary. The target contains only English/Base localization. `scripts/audit_english.py` verifies source literals, project resource references, plist declarations and the built bundle's localizations.

Recognition-only Chinese literals remain internally for detecting OS error messages and audio device names; they are not UI labels/messages. Source comments retain upstream language where appropriate.

`NSLocalNetworkUsageDescription` and `_nvstream._tcp` remain declared. Discovery still uses NSNetServiceBrowser and manual addresses still use existing direct network requests. No sandbox entitlements were changed. Permission-prompt display, Privacy & Security registration, denied-permission behavior and actual LAN discovery have not been exercised on a physical Tahoe Mac.

## Validation status

- Linux x86_64: complete customized common-c Debug and Release libraries built with warnings-as-errors; integration tests passed in both configurations.
- Test coverage: NVIDIA 4+2 audio FEC recovery, 8+4 video FEC recovery, AES-GCM round trip and tamper rejection, null-safe crypto cleanup, uninitialized context rejection and touchpad packet layout.
- Tahoe Intel and Apple Silicon runners: native host XML regression tests passed using the actual production HttpResponse/AppListResponse sources with only model/database/logging boundaries stubbed. Cases cover malformed input, DTD/internal/external entities, parser reuse/status reset, empty app titles and invalid/missing IDs.
- Fresh recursive clone from the public maintained repositories passed; common-c, ENet and nanors checked out their expected gitlinks.
- Source English/Local Network audit passed. The Universal build and its main/helper x86_64 + arm64 architecture checks passed in [run 37525760627](https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/actions/runs/37525760627). Final [run 37528656903](https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/actions/runs/37528656903) passed both complete Release application builds, common-c/production XML tests, English/LAN source and bundle audits, and main/helper architecture checks. Release source commit: `5e3bf0575505f8257b27cdf0fd7faafd5a8e4d77`; tag: [`native-6.2-rebuild-5`](https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/releases/tag/native-6.2-rebuild-5).
- The native Intel Tahoe runner passed common-c and XML tests, but its full application build stopped progressing at Interface Builder compilation and was canceled after more than 20 minutes. The release workflow now uses an Apple Silicon Tahoe runner with an explicit x86_64 target for the Intel-only package. This is cross-compilation, not a successful full build on an Intel runner or physical Intel streaming test.
- **Actually built:** Intel-only `ARCHS=x86_64` and Universal `ARCHS="x86_64 arm64"`, both with `ONLY_ACTIVE_ARCH=NO`, Xcode 26.6 (17F113), macOS 26.6.2 runner and SDK 26.5. Both main executable and AWDL helper have the expected slices. Deployment target remains macOS 12.
- Remaining warnings: upstream ENet mixes command/flag enum types at `host.c:247/467`; the platform-guarded `win32.o` has no symbols; no signing identity is available for the AWDL helper; AppIntents metadata extraction is skipped because no AppIntents framework is used. Native clipboard ownership and bitmap enum warnings were fixed.
- Released applications are not Developer ID signed or notarized. The AWDL helper is ad-hoc signed by its build script; installation/authorization remains untested.
- No live host tests have yet been performed. Discovery, pairing, app lists from a real host, stream start/stop/reconnect, input/controller, codecs/hardware decoding, audio, microphone, clipboard, pacing/HDR/color fidelity and settings persistence remain unverified at runtime.
- MbedTLS PSA, NXDK/3DS, other operating systems, signing/notarization and privileged-helper authorization were not tested.

## Intel Tahoe test checklist

1. First launch: allow Local Network; check the app under Privacy & Security > Local Network. Verify automatic discovery and manual IP, including discovery after relaunch.
2. Pair, reload app list, launch an app, stop, reconnect repeatedly; test Foundation Sunshine and ordinary Sunshine. Check GFE separately if available.
3. H.264 SDR then HEVC SDR: confirm hardware decoder in logs, image colors/full-range blacks/whites, 60/120 Hz pacing and CPU usage. Test Auto, Native, Metal and Compatibility without duplicate controls.
4. Enable software decoding, reconnect, verify decoder log; disable it, restart app, confirm persistence and hardware preference restoration.
5. Optional HEVC HDR on supported display/host; return to SDR. Verify unsupported GPU/HDR paths fall back without crash or washed-out SDR.
6. Main Enter vs keypad Enter; right Ctrl/Alt, arrows/navigation and key held during capture/focus loss. Test mouse buttons, horizontal/vertical scrolling and controller input/rumble. Steam type and dual pad behavior are unverified.
7. Stereo and supported surround/7.1.4/compatibility modes; monitor latency across 5/10 ms host packets and device switching. Test microphone permission/uplink and mute.
8. Clipboard text and image in both directions with compatible Enhanced/Foundation Sunshine; reconnect and repeat.
9. Change renderer, decoder, codec, HDR, host profiles and input/audio settings; relaunch and verify persistence. Check menu, alerts, overlays and logs for clear English.
10. Stress startup/shutdown/reconnect and window/fullscreen transitions; record errors and timing logs before changing defaults.

## Separate manual-update-only release

- Branch: `rebuild-moonlight-6.2-english-manual`; validated release source `bbe2973bb5ac3225a3a0023386dc4cd347c3414c`.
- [Run 37530026373](https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/actions/runs/37530026373): complete x86_64 and Universal Release builds passed; main/helper slices, common-c tests, native XML regression tests, English/LAN bundle audits and manual-update source/bundle audits all passed. Same remaining upstream/signing/AppIntents warnings as the primary release.
- [Separate downloads](https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/releases/tag/native-6.2-manual-1): `Moonlight-manual-x86_64.zip` and `Moonlight-manual-universal.zip`.
- The baseline already contained no app updater. This variant labels manual updates in About, points About/welcome links to the maintained fork, and rejects known updater/feed components during packaging. Debug-log polling remains enabled. This does not remove or replace the maintained common-c dependency.
- Native application differences from the primary release are limited to About/welcome links and the manual-update notice. Bundle identity/settings are retained; this is an alternative Moonlight.app package, not a side-by-side app. Quit and replace the installed app when switching variants.
- The first manual packaging audit missed Unicode NSString text; its byte scan was corrected to recognize UTF-16 as well as UTF-8. Both final package audits passed. Live streaming/permission/helper tests remain unperformed.
