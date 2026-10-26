# chase.lol UI fork notes

- Retained the uploaded UABEA project/solution, its asset libraries, plugins, type database, and native texture dependencies.
- Redesigned the main bundle workspace and asset browser with a classic blue/gray desktop visual style.
- Replaced the asset list's modal-only name search with an inline quick filter that composes with asset-type filters.
- Added double-click to open structured asset data.
- Updated app/window/about branding and changed the crash log filename.
- Kept UABEA's advanced actions and original license attribution.


## APK archive editing

- Added a dedicated APK archive workspace accessible from the main File menu, toolbar, general Open dialog, or file drag-and-drop.
- Added APK entry listing/filtering, replace, add files, add folders recursively, rename, remove, extract selected/all, editable text entries, and safe separate-file export.
- Removed stale `META-INF` v1 signature files when rebuilding; export warns that APKs must be aligned and signed again.
- Added optional APKTool decode/build commands for manifest/resource/smali edits. Java and `apktool.jar` are external prerequisites.
- Added an APK signing help panel linking to Android SDK `apksigner` guidance.
