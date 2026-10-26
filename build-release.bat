@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title chase.lol - obb editor build

set "OUT=%~dp0publish"
set "TMPROOT=%TEMP%\chase-lol-build-%RANDOM%-%RANDOM%"
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
set "VSINSTALL="

echo ==========================================================
echo  chase.lol - obb editor
echo  Windows x64 self-contained build
echo ==========================================================
echo.

where dotnet >nul 2>nul
if errorlevel 1 (
    echo ERROR: .NET SDK was not found.
    echo Install the .NET SDK, then run this file again.
    echo https://dotnet.microsoft.com/download/dotnet
    pause
    exit /b 1
)

echo Installed .NET SDKs:
dotnet --list-sdks
echo.

if exist "%OUT%" rmdir /s /q "%OUT%"
if exist "%TMPROOT%" rmdir /s /q "%TMPROOT%"
mkdir "%OUT%"
mkdir "%TMPROOT%"
if errorlevel 1 goto :fail

echo [1/6] Publishing the main application...
dotnet publish "UABEAvalonia\UABEAvalonia.csproj" -c Release -r win-x64 --self-contained true ^
  -p:PublishSingleFile=true ^
  -p:IncludeNativeLibrariesForSelfExtract=true ^
  -p:EnableCompressionInSingleFile=true ^
  -p:PublishTrimmed=false ^
  -p:DebugType=None -p:DebugSymbols=false ^
  -o "%OUT%"
if errorlevel 1 goto :fail

echo.
echo [2/6] Building managed plugins...
for %%P in (TexturePlugin TextAssetPlugin AudioClipPlugin FontPlugin) do (
    echo.
    echo     Publishing %%P...
    dotnet publish "%%P\%%P.csproj" -c Release -r win-x64 --self-contained false ^
      -p:PublishSingleFile=false -p:PublishTrimmed=false ^
      -p:BuildTextureNative=false -p:DebugType=None -p:DebugSymbols=false ^
      -o "%TMPROOT%\%%P"
    if errorlevel 1 goto :fail
    if not exist "%TMPROOT%\%%P\%%P.dll" (
        echo ERROR: The %%P plugin DLL was not created.
        goto :fail
    )
    if not exist "%OUT%\plugins" mkdir "%OUT%\plugins"
    copy /Y "%TMPROOT%\%%P\%%P.dll" "%OUT%\plugins\%%P.dll" >nul
    if errorlevel 1 goto :fail
    if exist "%TMPROOT%\%%P\%%P.deps.json" copy /Y "%TMPROOT%\%%P\%%P.deps.json" "%OUT%\plugins\" >nul
    if exist "%TMPROOT%\%%P\%%P.pdb" copy /Y "%TMPROOT%\%%P\%%P.pdb" "%OUT%\plugins\" >nul

    rem Plugin-only managed dependencies must remain next to the EXE so Assembly.LoadFrom can resolve them.
    for %%D in ("%TMPROOT%\%%P\*.dll") do (
        if exist "%%~fD" (
            if /I not "%%~nxD"=="%%P.dll" (
                if /I not "%%~nxD"=="chase.lol - obb editor.dll" (
                    copy /Y "%%~fD" "%OUT%\" >nul
                    if errorlevel 1 goto :fail
                )
            )
        )
    )
    rem Also preserve RID-specific files shipped by plugin package dependencies.
    if exist "%TMPROOT%\%%P\runtimes" (
        xcopy "%TMPROOT%\%%P\runtimes\*" "%OUT%\runtimes\" /E /I /Y >nul
        if errorlevel 1 goto :fail
        for /r "%TMPROOT%\%%P\runtimes" %%N in (*.dll) do (
            if exist "%%~fN" copy /Y "%%~fN" "%OUT%\" >nul
        )
    )
)

echo.
echo [3/6] Copying application data files...
if exist "ReleaseFiles" (
    xcopy "ReleaseFiles\*" "%OUT%\" /E /I /Y >nul
    if errorlevel 1 goto :fail
)
if not exist "%OUT%\plugins" mkdir "%OUT%\plugins"

echo.
echo [4/6] Checking for Visual Studio C++ tools for optional native texture codecs...
if exist "%VSWHERE%" (
    for /f "usebackq delims=" %%I in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VSINSTALL=%%I"
)
if defined VSINSTALL (
    if exist "%VSINSTALL%\Common7\Tools\VsDevCmd.bat" (
        call "%VSINSTALL%\Common7\Tools\VsDevCmd.bat" -arch=x64 >nul
        if not errorlevel 1 (
            echo Building TexToolWrap native DLL...
            msbuild "TexToolWrap\TexToolWrap.vcxproj" /t:Build /m /p:Configuration=Release /p:Platform=x64
            if errorlevel 1 (
                echo WARNING: Native texture codec build failed. The editor will still build; formats that require TexToolWrap may be unavailable.
            ) else (
                echo Native texture codec build completed.
            )
        ) else (
            echo WARNING: Visual Studio developer environment could not be initialized. Skipping native texture codecs.
        )
    )
) else (
    echo Visual Studio C++ Build Tools not found. Skipping optional TexToolWrap build.
    echo The managed editor and plugins will still be packaged.
)

rem Keep the native wrapper and helper libraries beside the EXE when present.
if exist "TexToolWrap\bin\x64\Release\TexToolWrap.dll" copy /Y "TexToolWrap\bin\x64\Release\TexToolWrap.dll" "%OUT%\" >nul
if exist "TexToolWrap\PVRTexLib\Windows_x86_64\PVRTexLib.dll" copy /Y "TexToolWrap\PVRTexLib\Windows_x86_64\PVRTexLib.dll" "%OUT%\" >nul
if exist "TexToolWrap\ispc\win64\ispc_texcomp.dll" copy /Y "TexToolWrap\ispc\win64\ispc_texcomp.dll" "%OUT%\" >nul
if exist "TexToolWrap\crunch\win64\crnlib.dll" copy /Y "TexToolWrap\crunch\win64\crnlib.dll" "%OUT%\" >nul

echo.
echo [5/6] Verifying package...
if not exist "%OUT%\chase.lol - obb editor.exe" (
    echo ERROR: Expected executable was not generated:
    echo "%OUT%\chase.lol - obb editor.exe"
    goto :fail
)
if not exist "%OUT%\plugins\TexturePlugin.dll" (
    echo ERROR: TexturePlugin.dll is missing from publish\plugins.
    goto :fail
)
if not exist "%OUT%\plugins\AudioClipPlugin.dll" (
    echo ERROR: AudioClipPlugin.dll is missing from publish\plugins.
    goto :fail
)
if not exist "%OUT%\plugins\TextAssetPlugin.dll" (
    echo ERROR: TextAssetPlugin.dll is missing from publish\plugins.
    goto :fail
)
if not exist "%OUT%\plugins\FontPlugin.dll" (
    echo ERROR: FontPlugin.dll is missing from publish\plugins.
    goto :fail
)

echo.
echo [6/6] Cleaning temporary build files...
if exist "%TMPROOT%" rmdir /s /q "%TMPROOT%"

echo.
echo ==========================================================
echo BUILD SUCCEEDED
echo EXE: "%OUT%\chase.lol - obb editor.exe"
echo Keep the EXE together with the plugins folder and the other files in publish.
echo ==========================================================
pause
exit /b 0

:fail
echo.
echo BUILD FAILED. Copy the first error shown above.
echo Temporary files were kept at "%TMPROOT%" to help diagnose the failure.
pause
exit /b 1
