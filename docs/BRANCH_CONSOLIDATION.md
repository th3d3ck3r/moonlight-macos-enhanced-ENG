# One branch, English manual updates

`master` is the sole active branch of this repository and maintains only the English, manual-update edition. It retains the native streaming code, renderers, settings, English resources and customized common-c submodule. About explicitly labels manual updates and links to this fork. Future updates are downloaded manually from this project's GitHub releases; no automatic updater is included.

The validation workflow builds the full x86_64 and Universal applications and runs existing protocol, XML, credential-redaction, English, LAN and update-isolation audits. Manual Build 21 becomes Latest after consolidation validation and publication. Existing Standard and Manual releases and their tags remain available as history. Future release runs publish only the Manual edition.

Before deleting any extra branch, the consolidation commit retains every old tip as an ancestor and the publication job creates `archive/2026-10-06/consolidated-history`. It checks that the branch has not moved, and only runs after both full application builds pass. The Manual and older historical branch tips are retained as merge parents, with their exact identifiers listed below. Archive tags retain older discarded customizations for history only; those changes are not restored into the application.

Physical Mac pairing and streaming tests are still required. Consolidation does not establish runtime validation.

## Validation record

Source `4e5b3ec78c6b6227c50bdc9ac7da198d782cf7bc` passed the full x86_64 and Universal build jobs in run `37563407960`, including the bundled update-isolation audit. The initial cleanup job stopped on a missing archive-tag response before deleting any branch; its error handling was corrected in the publication workflow. Release assets are reused from the successful application jobs, with a check that no application, submodule, project or test source changed.

Preserved tips:
- Standard rebuild: `ab03958a60edf4fc644c881382072aeef4677298`
- Manual rebuild: `328ea83b8e6856668b63930f8a6e6c1b64776102`
- Historical Crimson branch: `6691a9d84fa59325ef8605a999ee0a8e10b96a34`
- Historical discovery branch: `f03fb401876108870b09f5dfd6dd45c74f00dbb3`

The first publication attempt was denied while targeting an earlier commit. Publication now tags the current documentation/consolidation commit after verifying that its application sources exactly match the successfully built source.
