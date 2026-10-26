# chase.lol - obb editor

This is the existing UABEAvalonia-based editor with the APK archive workspace, not the small prototype.

## Build on Windows

1. Install the .NET SDK (the project currently targets .NET 6 and can be built using a newer SDK): https://dotnet.microsoft.com/download/dotnet
2. Extract this project.
3. Double-click `build-release.bat`.
4. When it finishes successfully, launch `publish\chase.lol - obb editor.exe`.

The batch file explicitly builds the main app and the managed plugins so you do not have to choose between the two old solution files. The duplicate solution file was removed. The managed build does not require Visual Studio C++ Build Tools. If those tools are installed, the script also attempts to build the optional native texture codec (`TexToolWrap.dll`).

Keep the EXE together with the `plugins` folder and the other files in `publish`. The application uses external plugin assemblies and data/native support files, so the publish folder as a whole is the runnable package; it is not just an EXE with no sidecar files.

## Included features from the existing source

- UABEA-based Unity asset and bundle workflows
- Plugin-based texture, audio, text asset, and font tools
- APK ZIP-archive editor: list/filter entries, add files/folders, replace, rename, remove, edit text entries, extract selected/all, and export a rebuilt APK
- Optional APKTool decode/build workflows (requires Java and an `apktool.jar`)
- APK signing guidance; rebuilt APKs are unsigned and must be signed with Android SDK Build Tools before installation
- App-provided release data files (including `classdata.tpk`)

## Important limitations

- APK editing through the archive workspace operates on ZIP entries. Binary Android manifest/resource tables and smali workflows require the optional APKTool decode/build path.
- Some texture formats require the optional native `TexToolWrap.dll` and its helper libraries. If Visual Studio C++ Build Tools are not installed or the native build fails, the app and managed plugins can still package, but these specific native codecs may be unavailable. Native calls now fail gracefully instead of crashing the process.
- This archive was source-checked and its XML/project files were parsed, but it was **not compiled here** because the execution environment has no .NET SDK and cannot download one. The `publish` EXE is generated only after `build-release.bat` succeeds on Windows; no fake executable is included.
