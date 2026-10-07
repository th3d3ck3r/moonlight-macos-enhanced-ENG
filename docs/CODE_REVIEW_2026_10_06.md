# Native Moonlight Enhanced code review — October 6, 2026

## Scope and outcome

Reviewed every changed file in the native rebuild and customized common-c merge, plus critical host parsing, connection lifecycle, keyboard capture, decoding/render selection and diagnostic output paths. This is a source review with automated regression tests, not a guarantee that every inherited application path is bug-free. No live streaming host or physical Intel Mac was available.

The native AppKit/SwiftUI/VideoToolbox/Metal design remains intact. The English and Local Network changes are preserved. No discarded customization was restored. See [the integration report](MOONLIGHT_6_2_REBUILD.md) for all 19 exact common-c commits, Qt 6.2 classifications, merge conflict resolutions and the Intel Tahoe test checklist.

## Problems found and corrected

| Problem | Correction | Verification |
| --- | --- | --- |
| An inherited RTSP parser reads beyond its allocated buffer when a truncated header ends at the terminal NUL. | Bounds-check the header token before testing the remaining data; reject invalid input/length and use a size_t allocation. Maintained common-c commit `4a2c0d3b09ace7c3aba81837bc2e8a3197916177`. | Reproduced with AddressSanitizer before the fix. Debug ASan/UBSan and Release tests pass after the fix, covering valid responses, truncations, invalid arguments and 20,000 deterministic malformed inputs. |
| NSString numeric conversion accepts partial status codes, pairing status and app IDs, including query suffixes and oversized values. An unexpected XML root was also accepted. | Shared complete ASCII decimal parser, INT_MAX bound, strict integer-tag parsing, positive app IDs and required root element. Preserve valid whitespace and empty app titles. | Production HttpResponse/AppListResponse regression cases cover prefixes, overflow, negative values, wrong root, query suffix IDs and valid boundaries, alongside prior entity/parser-reuse tests. |
| Ordinary held keys can remain pressed when mouse capture exits and subsequent key-up events are suppressed. | Release the tracked ordinary keys and modifiers at the central uncapture point before disabling input. | Source review and full application builds; physical input behavior remains untested. |
| Pairing PIN/salted PIN and protocol credential fields appear in raw XML, URLs and dictionary diagnostics. | Remove PIN logging and redact known credential fields before raw/curated files, overlay and console output. Route common-c logging through the same redaction before its direct sinks. | Production Logger/LogBuffer tests use dummy secrets and check overlay, raw/curated files and captured console output. Existing log files are not retroactively scrubbed. |

Pairing review also gave the selected server certificate an explicit retained reference until its DER data is copied, rather than depending on a borrowed chain element after releasing the copied array. Both API paths balance the reference. The pinned-certificate check and existing PIN/certificate handshake are preserved; no live host pairing was available.

The additional clipboard review found that receivedLength was a high-water mark, which allowed a last chunk to mark a transfer complete despite an uninitialized prefix. The maintained fork now requires contiguous chunks on the existing reliable ordered control channel, rejects gaps/overlap, and zero-initializes transfer storage as defense in depth. Production receiver tests cover text, image, empty snapshots, missing-prefix, duplicate/overlap, truncated and out-of-bounds packets. Maintained common-c commit: `165374368805b80260467023dfa9948113ef1896`.

The new regression failed against the previous receiver. During that check, Platform.h was found to redefine NDEBUG and disable assertions in the common integration test despite compiler -UNDEBUG. Tests now explicitly undefine NDEBUG after production headers, so their assertions execute in Debug and Release. All three CTests pass with active assertions in both configurations, including ASan/UBSan Debug. Earlier integration-test passes alone did not establish those assertions had run; the fresh results supersede that limitation.

The English audit now includes XIB files as well as storyboards and source. One full-width colon in a diagnostics string was corrected. The submodule remains pinned to an exact tested commit; branch metadata names the maintained Enhanced branch for deliberate future updates.

## Common-c merge review

All 19 official commits through `f900dd4767759c7b9d0e93bcea666b55c69ea62f` remain ancestors of the maintained fork. Reviewed conflict regions and checked that the upstream crypto implementation matches the official endpoint. Enhanced microphone, text/image clipboard, HDR range, 7.1.4 negotiation and connection-context extensions remain in the source. Their live interoperability is not proven by compilation.

Linux x86_64 builds of the complete customized common-c library passed in Debug with ASan/UBSan and Release with warnings-as-errors. Integration, RTSP parser and production clipboard receiver CTests pass with active assertions. LeakSanitizer could not run in the traced local environment, so leak checks are explicitly disabled; ASan bounds and UBSan checks remain enabled. GCC analyzer produced two buffer-initialization warnings in receive/RTSP paths that use external writes/context initialization; reviewed as likely modeling limitations, not demonstrated runtime defects. Those warnings are not represented as a clean analyzer run. MbedTLS PSA and non-macOS platform backends remain untested.

## Full macOS builds and remaining limits

The previous published master completed native Intel Tahoe, arm64 and Universal jobs in [run 37530567839](https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/actions/runs/37530567839). Intel job `112498586027` ran on `macos-26-intel` and passed the full app/helper build, architecture checks and packaging; arm64 job `112498586461` and Universal job `112507526397` passed too. This supersedes the earlier stalled Intel-runner attempt described in the original report.

The reviewed standard source `686764a7eb0fe66cbc05c80467ca2f03e99ebe55` passed both full x86_64 and Universal Release builds in [run 37545875198](https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/actions/runs/37545875198). Intel-only job `112549633181` and Universal job `112549633480` passed common-c ASan/UBSan CTests with active assertions, actual native XML/logger sanitizer tests, recursive checkout, English/LAN source and bundle audits, and main/helper architecture checks. Xcode 26.6 (17F113). The Intel release package is cross-compiled on an Apple Silicon Tahoe runner; the earlier successful native Intel build above used the previous source revision. Neither proves physical streaming performance.

Regular release: [native-6.2-rebuild-17](https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/releases/tag/native-6.2-rebuild-17). Both uploaded ZIPs and GitHub SHA-256 digests were verified; see [checksums](REBUILD_SHA256SUMS.txt). The manual-update source `db93cccf209b17af1ac4a4037a2d49dfab97455e` passed both full builds in [run 37545859459](https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/actions/runs/37545859459), with x86_64 job `112549846668` and Universal job `112549846418`. All the same tests and architecture checks passed, plus the manual-update source/bundle guard. Regular release: [native-6.2-manual-4](https://github.com/th3d3ck3r/moonlight-macos-enhanced-ENG/releases/tag/native-6.2-manual-4); uploaded ZIPs/digests verified in [manual checksums](MANUAL_SHA256SUMS.txt). Both releases are regular releases, not drafts/prereleases, and their tags stay pinned to these validated source revisions.

Remaining build warnings: ENet command/flag enum mixing, an empty platform-guarded win32.o, unavailable helper signing identity and skipped unused AppIntents metadata. Packages are not Developer ID signed or notarized; the helper is ad-hoc signed and authorization is untested.

Live discovery, first-launch Local Network prompt/privacy listing, pairing, app lists, stream startup/shutdown/reconnect, keyboard/mouse/controllers, H.264/HEVC hardware decoding, HDR/SDR color and pacing, audio/microphone, clipboard, renderer selection/settings persistence and helper authorization must still be tested on the user's Intel Tahoe Mac. The source and bundle checks verify declarations, not OS permission behavior. Liquid Glass is planned, not implemented.

## Exact follow-up revisions

| Main commit | Change |
| --- | --- |
| `2f30c80381bde454b3c3e31277854a1cd68f551e` | Complete bounded status/app-ID parsing and XML root validation |
| `4945458bdd5545678817b083175ec8c4736da70c` | Held-key release on capture exit |
| `e0b34389c13c1354976a4e689e8586ff4834e4f1` | RTSP bounds-fix common-c gitlink |
| `3ef31ca35f428bfa4e538ee3293c13172494e2c2` | Known protocol credential redaction before diagnostic sinks |
| `c1c06f9d00bdc11be516c29202970b0f6a40f407` | XIB English audit, punctuation and maintained branch metadata |
| `507be79b986c9af3f5d04959f6ed830bfde1a009` | Strict pairing-status integer parsing |
| `8199e664c8dfba326661fabf5ba2c9dcac40e680` | Clipboard completeness and active protocol assertions |
| `686764a7eb0fe66cbc05c80467ca2f03e99ebe55` | Explicit paired-server certificate ownership |

Common-c follow-ups: RTSP bounds/test commit `4a2c0d3b09ace7c3aba81837bc2e8a3197916177`; clipboard receiver/tests/assertion fix `165374368805b80260467023dfa9948113ef1896`. Upstream endpoint remains an ancestor; these are additional native-fork corrections.
