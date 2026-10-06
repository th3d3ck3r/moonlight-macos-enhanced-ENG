**Manual updates only.** This separate variant has no automatic updater or upstream feed. About/welcome links point to the maintained fork, and source/bundle audits enforce the manual-update policy. The baseline already had no automatic updater.

Reviewed native Moonlight Enhanced English release for Intel macOS Tahoe. Full Intel-only and Universal builds, executable/helper architecture checks, native host-XML tests, common-c protocol tests, and English/Local Network bundle audits must pass before publication.

This update fixes an inherited RTSP parser bounds error with truncated headers, validates complete bounded host status codes and app IDs, releases held keyboard keys on every capture exit, and redacts known pairing/stream credentials before diagnostic output. The customized common-c fork still retains Enhanced microphone, clipboard, dynamic-range and multichannel audio features.

Common-c Debug tests passed under AddressSanitizer/UndefinedBehaviorSanitizer on Linux; Release tests also passed, including RTSP truncations and 20,000 deterministic malformed inputs. LeakSanitizer was unavailable in the local traced environment. The native macOS CI regression tests also run with ASan/UBSan.

The native AppKit/SwiftUI/VideoToolbox/Metal architecture remains intact. No Qt, MoltenVK or libplacebo conversion. These packages are not Developer ID signed or notarized; live discovery, permissions, streaming, codec/color/pacing, microphone, clipboard and helper authorization remain untested on a physical Intel Mac.

Downloads: `Moonlight-manual-x86_64.zip` for Intel; `Moonlight-manual-universal.zip` for Intel and Apple Silicon. Choose one Moonlight.app package.

See [the code-review report and physical Mac checklist](https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/blob/master/docs/CODE_REVIEW_2026_10_06.md) for the review scope, fixes, exact revisions and remaining limits.
