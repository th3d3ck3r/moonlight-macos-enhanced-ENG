# Native Moonlight Enhanced code review — October 6, 2026

## Scope and outcome

Reviewed every changed file in the native rebuild and customized common-c merge, plus critical host parsing, connection lifecycle, keyboard capture, decoding/render selection and diagnostic output paths. This is a source review with automated regression tests, not a guarantee that every inherited application path is bug-free. No live streaming host or physical Intel Mac was available.

The native AppKit/SwiftUI/VideoToolbox/Metal design remains intact. The English and Local Network changes are preserved. No discarded customization was restored. See [the integration report](MOONLIGHT_6_2_REBUILD.md) for all 19 exact common-c commits, Qt 6.2 classifications, merge conflict resolutions and the Intel Tahoe test checklist.

## Problems found and corrected

| Problem | Correction | Verification |
| --- | --- | --- |
| An inherited RTSP parser reads beyond its allocated buffer when a truncated header ends at the terminal NUL. | Bounds-check the header token before testing the remaining data; reject invalid input/length and use a size_t allocation. Maintained common-c commit `4a2c0d3b09ace7c3aba81837bc2e8a3197916177`. | Reproduced with AddressSanitizer before the fix. Debug ASan/UBSan and Release tests pass after the fix, covering valid responses, truncations, invalid arguments and 20,000 deterministic malformed inputs. |
| NSString numeric conversion accepts partial status codes and app IDs, including query suffixes and oversized values. An unexpected XML root was also accepted. | Shared complete ASCII decimal parser, INT_MAX bound, positive app IDs and required root element. Preserve valid whitespace and empty app titles. | Production HttpResponse/AppListResponse regression cases cover prefixes, overflow, negative values, wrong root, query suffix IDs and valid boundaries, alongside prior entity/parser-reuse tests. |
| Ordinary held keys can remain pressed when mouse capture exits and subsequent key-up events are suppressed. | Release the tracked ordinary keys and modifiers at the central uncapture point before disabling input. | Source review and full application builds; physical input behavior remains untested. |
| Pairing PIN/salted PIN and protocol credential fields appear in raw XML, URLs and dictionary diagnostics. | Remove PIN logging and redact known credential fields before raw/curated files, overlay and console output. Route common-c logging through the same redaction before its direct sinks. | Production Logger/LogBuffer tests use dummy secrets and check overlay, raw/curated files and captured console output. Existing log files are not retroactively scrubbed. |

The English audit now includes XIB files as well as storyboards and source. One full-width colon in a diagnostics string was corrected. The submodule remains pinned to an exact tested commit; branch metadata names the maintained Enhanced branch for deliberate future updates.

## Common-c merge review

All 19 official commits through `f900dd4767759c7b9d0e93bcea666b55c69ea62f` remain ancestors of the maintained fork. Reviewed conflict regions and checked that the upstream crypto implementation matches the official endpoint. Enhanced microphone, text/image clipboard, HDR range, 7.1.4 negotiation and connection-context extensions remain in the source. Their live interoperability is not proven by compilation.

Linux x86_64 builds of the complete customized common-c library passed in Debug with ASan/UBSan and Release with warnings-as-errors. Both integration and RTSP parser CTests pass. LeakSanitizer could not run in the traced local environment, so leak checks are explicitly disabled; ASan bounds and UBSan checks remain enabled. GCC analyzer produced two buffer-initialization warnings in receive/RTSP paths that use external writes/context initialization; reviewed as likely modeling limitations, not demonstrated runtime defects. Those warnings are not represented as a clean analyzer run. MbedTLS PSA and non-macOS platform backends remain untested.

## Full macOS builds and remaining limits

The previous published master completed native Intel Tahoe, arm64 and Universal jobs in [run 37530567839](https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/actions/runs/37530567839). Intel job `112498586027` ran on `macos-26-intel` and passed the full app/helper build, architecture checks and packaging; arm64 job `112498586461` and Universal job `112507526397` passed too. This supersedes the earlier stalled Intel-runner attempt described in the original report.

The corrected source must pass fresh full x86_64 and Universal Release application builds for both editions before its release is published. CI also runs common-c and actual native XML/logger tests under ASan/UBSan, English/LAN bundle checks, executable/helper architecture checks, and the manual-update guard for that edition. Exact corrected build/release revisions and results will be recorded after completion.

Known previous build warnings: ENet command/flag enum mixing, an empty platform-guarded win32.o, unavailable helper signing identity and skipped unused AppIntents metadata. Packages are not Developer ID signed or notarized; the helper is ad-hoc signed and authorization is untested.

Live discovery, first-launch Local Network prompt/privacy listing, pairing, app lists, stream startup/shutdown/reconnect, keyboard/mouse/controllers, H.264/HEVC hardware decoding, HDR/SDR color and pacing, audio/microphone, clipboard, renderer selection/settings persistence and helper authorization must still be tested on the user's Intel Tahoe Mac. The source and bundle checks verify declarations, not OS permission behavior. Liquid Glass is planned, not implemented.
