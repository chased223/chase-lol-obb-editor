# chase.lol - obb editor

A simpler, Windows-style front end built from the uploaded UABEA source. This version keeps UABEA's real Unity asset/bundle parsing and serialization implementation instead of replacing it with a generic ZIP handler.

## What is retained from the underlying UABEA code

- Unity serialized-file and AssetBundle loading/writing through AssetsTools.NET.
- Bundle entry import, replacement, rename, removal, save and repack/compression paths.
- Asset listing, type filtering, asset lookup, structured-data view/edit, raw and dump import/export.
- Asset file metadata, type trees, dependencies, script information and scene hierarchy tools.
- Existing texture, audio clip, font and text asset plugin projects and the plugin manager.
- Mod package creation/loading and the existing asset/template data support.

Exact support depends on the Unity version and file format. Game-specific encryption, custom wrapper formats, and external integrity/signature systems are not automatically solved by this application.

## UI changes in this fork

- Branded title and Windows desktop-style blue/gray workspace.
- Larger bundle workspace with an entry list and grouped actions.
- Asset browser with an always-visible quick filter for name, type, container, file ID, path ID and type ID.
- Double-click an asset row to open its structured data view.
- Right-side asset details and consolidated common actions.
- Existing advanced menus remain available so the simplified layout does not remove UABEA tools.


## APK editing (new)

A separate **APK Archive Editor** now opens `.apk` files from **File → Open APK archive...** or by choosing an `.apk` in the normal Open dialog. It treats an APK as a ZIP container and provides:

- Browse/filter entries and inspect path, type, unpacked size, packed size, and change status.
- Extract a selected entry or all entries while guarding against path traversal.
- Replace an entry, add one or many files, add a folder recursively, rename entries, remove entries, and edit UTF-8-like text entries up to 8 MB.
- Export a rebuilt APK to a separate file; the source APK is never overwritten automatically.
- Optional **Decode with APKTool** and **Build with APKTool** commands, using an externally installed `apktool.jar` and Java available on `PATH`. Decode produces a folder beside the chosen parent folder; edit `AndroidManifest.xml`, `res/`, `assets/`, or `smali/` there, then use Build to create a new APK. APKTool may not support every vendor-customized APK.

### APK signing and format limits

Repacking changes the ZIP bytes and removes old `META-INF` signature files; APK Signature Scheme v2/v3 signing-block data is not retained by the ZIP writer. The exported APK is **unsigned** and must be aligned and signed before installing. Use Android SDK Build Tools `zipalign` first, then `apksigner sign`, then `apksigner verify`. An example is shown in the editor under **How to sign a rebuilt APK**. See the official [Android apksigner documentation](https://developer.android.com/tools/apksigner) and [APKTool decoding documentation](https://apktool.org/wiki/the-basics/decoding/).

A newly generated signing key generally cannot update an installed app signed by a different key. Keep the original developer's signing key private and safe; this editor does not extract or bypass signing keys. Some games additionally use custom encryption, split APKs, integrity checks, or server-side verification; this generic editor does not defeat those checks.

## Build on Windows

The source package was prepared in an environment without a .NET SDK/compiler, so a compiled `.exe` could not be produced or runtime-tested in this environment. Build the package on Windows:

1. Extract the entire project folder.
2. Install the .NET SDK from https://dotnet.microsoft.com/download/dotnet. The source currently targets .NET 6; a newer SDK can build it after restoring dependencies. NuGet restore requires internet access.
3. Double-click `build-release.bat`. It builds the main app and managed plugins directly, avoiding the two-solution ambiguity and not requiring a Developer Command Prompt.
4. When the script reports `BUILD SUCCEEDED`, launch `publish\chase.lol - obb editor.exe`.

Keep the executable together with the `plugins` folder and other files in `publish`. Because the editor uses dynamically loaded plugins and bundled data/native support files, the complete `publish` directory is the runnable package; the `.exe` alone is not sufficient.

The script attempts to build the optional native texture codec if Visual Studio C++ Build Tools are installed. Without `TexToolWrap.dll`, the app and managed plugins can still start, but texture formats that require those native routines may be unavailable. Native calls are guarded so missing codecs should return an unsupported result rather than crash the whole editor.

For APK operations, ordinary archive editing does not require APKTool. The **Decode with APKTool** and **Build with APKTool** commands require Java and an external `apktool.jar`; rebuilt APKs are unsigned and must be aligned and signed with Android SDK Build Tools before installation.

Build the project from copies of game files. Custom encryption, game-specific wrappers and integrity checks are not automatically handled. Windows 7 compatibility has not been verified on a Windows 7 machine.

## License and attribution

This fork retains the upstream `license` and bundled third-party notices. UABEA is distributed under the MIT license; the copyright and permission notices must be kept with redistributions. Review the notices for native texture libraries and bundled assets before redistributing a compiled package.
