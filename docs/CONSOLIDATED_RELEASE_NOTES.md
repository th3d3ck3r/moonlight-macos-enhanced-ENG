English Manual Build 21 consolidates the maintained native client on `master`. The app's About and onboarding links now open this fork's main page and README. Manual-update labeling, English-only UI, Intel/Tahoe support, custom microphone/clipboard/audio extensions and all reviewed protocol fixes are preserved. No automatic app updater is included.

Full x86_64 and Universal application builds and the English/LAN, update-isolation, architecture, common-c protocol, native XML and credential-redaction checks passed in run 37563407960 at source commit `4e5b3ec78c6b6227c50bdc9ac7da198d782cf7bc`. This release uses those exact validated artifacts.

Extra branches have been preserved in Git history and an archive tag before removal. Existing releases remain available as history. Liquid Glass is planned and is not included.

Live discovery, permission prompts, pairing, streaming, hardware decoding, HDR, input, audio, microphone and clipboard remain untested on a physical Intel Mac. Packages are not Developer ID signed or notarized; privileged helper authorization remains untested.
