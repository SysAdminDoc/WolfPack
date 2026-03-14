; =============================================================================
; WolfPack - NSIS Installer v1.2.0
; =============================================================================

!include "MUI2.nsh"
!include "FileFunc.nsh"

; ---- Build-time defines (passed via /D flags) ----
!ifndef VERSION
  !define VERSION "0.0.0"
!endif
!ifndef SOURCE_DIR
  !define SOURCE_DIR "build\portable"
!endif
!ifndef OUTPUT_FILE
  !define OUTPUT_FILE "output\WolfPack-${VERSION}-setup.exe"
!endif

; ---- General ----
Name "WolfPack ${VERSION}"
OutFile "${OUTPUT_FILE}"
InstallDir "$LOCALAPPDATA\WolfPack"
InstallDirRegKey HKCU "Software\WolfPack" "InstallDir"
RequestExecutionLevel user
SetCompressor /SOLID lzma
SetCompressorDictSize 64
Unicode true

; ---- MUI Settings ----
!define MUI_ABORTWARNING
!define MUI_ICON "assets\wolfpack.ico"
!define MUI_UNICON "assets\wolfpack.ico"
!define MUI_HEADERIMAGE
!define MUI_WELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Wizard\win.bmp"

; ---- Pages ----
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_RUN "$INSTDIR\WolfPack.vbs"
!define MUI_FINISHPAGE_RUN_TEXT "Launch WolfPack"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; ---- Language ----
!insertmacro MUI_LANGUAGE "English"

; ---- Install Section ----
Section "Install" SecInstall
    SetOutPath "$INSTDIR"

    ; Copy all files from the portable build
    File /r "${SOURCE_DIR}\*.*"

    ; Write registry keys
    WriteRegStr HKCU "Software\WolfPack" "InstallDir" "$INSTDIR"
    WriteRegStr HKCU "Software\WolfPack" "Version" "${VERSION}"

    ; Add/Remove Programs entry
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\WolfPack" \
        "DisplayName" "WolfPack ${VERSION}"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\WolfPack" \
        "UninstallString" '"$INSTDIR\uninstall.exe"'
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\WolfPack" \
        "InstallLocation" "$INSTDIR"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\WolfPack" \
        "DisplayIcon" "$INSTDIR\LibreWolf\librewolf.exe,0"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\WolfPack" \
        "Publisher" "SysAdminDoc"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\WolfPack" \
        "DisplayVersion" "${VERSION}"
    WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\WolfPack" \
        "NoModify" 1
    WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\WolfPack" \
        "NoRepair" 1

    ; Calculate installed size
    ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
    IntFmt $0 "0x%08X" $0
    WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\WolfPack" \
        "EstimatedSize" "$0"

    ; Create uninstaller
    WriteUninstaller "$INSTDIR\uninstall.exe"

    ; Start Menu shortcuts
    CreateDirectory "$SMPROGRAMS\WolfPack"
    CreateShortCut "$SMPROGRAMS\WolfPack\WolfPack.lnk" \
        "$INSTDIR\WolfPack.vbs" "" "$INSTDIR\LibreWolf\librewolf.exe" 0
    CreateShortCut "$SMPROGRAMS\WolfPack\Uninstall.lnk" \
        "$INSTDIR\uninstall.exe"

    ; Desktop shortcut
    CreateShortCut "$DESKTOP\WolfPack.lnk" \
        "$INSTDIR\WolfPack.vbs" "" "$INSTDIR\LibreWolf\librewolf.exe" 0

SectionEnd

; ---- Uninstall Section ----
Section "Uninstall"

    ; Kill running instances
    nsExec::ExecToLog 'taskkill /F /IM librewolf.exe'

    ; Remove app files
    RMDir /r "$INSTDIR\LibreWolf"
    RMDir /r "$INSTDIR\Extension_Configs"
    Delete "$INSTDIR\WolfPack.bat"
    Delete "$INSTDIR\WolfPack.vbs"
    Delete "$INSTDIR\WolfPack.ps1"
    Delete "$INSTDIR\WolfPack.exe"
    Delete "$INSTDIR\LibreWolf-Portable.exe"
    Delete "$INSTDIR\LibreWolf-WinUpdater.exe"
    Delete "$INSTDIR\ScheduledTask-Create.ps1"
    Delete "$INSTDIR\ScheduledTask-Remove.ps1"
    Delete "$INSTDIR\portable.ini"
    Delete "$INSTDIR\uninstall.exe"
    ; Clean up old naming
    Delete "$INSTDIR\LibreWolf.bat"
    Delete "$INSTDIR\LibreWolf.vbs"
    Delete "$INSTDIR\LibreWolf.ps1"
    Delete "$INSTDIR\LibreWolf.exe"
    Delete "$INSTDIR\LibreWolf-Dark.bat"
    Delete "$INSTDIR\LibreWolf-Dark.vbs"
    Delete "$INSTDIR\LibreWolf-Dark.ps1"
    Delete "$INSTDIR\LibreWolf-Dark.exe"

    ; Ask about profile data
    MessageBox MB_YESNO "Remove your profile data (bookmarks, settings, extensions)?" IDYES removeprofile IDNO keepprofile
    removeprofile:
        RMDir /r "$INSTDIR\Profiles"
    keepprofile:

    RMDir "$INSTDIR"

    ; Remove shortcuts
    Delete "$DESKTOP\WolfPack.lnk"
    Delete "$SMPROGRAMS\WolfPack\WolfPack.lnk"
    Delete "$SMPROGRAMS\WolfPack\Uninstall.lnk"
    RMDir "$SMPROGRAMS\WolfPack"
    ; Clean up old naming
    Delete "$DESKTOP\LibreWolf.lnk"
    Delete "$SMPROGRAMS\LibreWolf\LibreWolf.lnk"
    Delete "$SMPROGRAMS\LibreWolf\Uninstall.lnk"
    RMDir "$SMPROGRAMS\LibreWolf"
    Delete "$DESKTOP\LibreWolf Dark.lnk"
    Delete "$SMPROGRAMS\LibreWolf Dark\LibreWolf Dark.lnk"
    Delete "$SMPROGRAMS\LibreWolf Dark\Uninstall.lnk"
    RMDir "$SMPROGRAMS\LibreWolf Dark"

    ; Remove registry
    DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\WolfPack"
    DeleteRegKey HKCU "Software\WolfPack"
    ; Clean up old naming
    DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\LibreWolf-Portable"
    DeleteRegKey HKCU "Software\LibreWolf-Portable"
    DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\LibreWolf-Dark"
    DeleteRegKey HKCU "Software\LibreWolf-Dark"

SectionEnd
