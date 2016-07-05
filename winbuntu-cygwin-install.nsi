# winbuntu-cygwin-intall.nsi
# Used to compile the installer
# the installer downloads the cygwin setup program
# to perform package installation

# use modern gui
!include MUI2.nsh
# do not request admin privs
RequestExecutionLevel user

# name
Name "Winbuntu Cygwin Installer"
# output file
SetCompressor lzma
OutFile "winbuntu-cygwin-install.exe"
# default install directory
InstallDir C:\winbuntu-cygwin-x86_64
# installer icon
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\orange-install.ico"
# use directory select page, and install page
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

# do the actual setup
Section ""
 Call DoSetup
SectionEnd

Function DoSetup
  # download directory
  StrCpy $2 "$INSTDIR\var\cache\spm"
  CreateDirectory $2
  # executable filename (downloaded)
  StrCpy $0 "$2\setup-x86_64.exe"
  # download cygwin setup executable
  NSISdl::download "https://cygwin.com/setup-x86_64.exe" $0
  # check for successful download
  Pop $1
  StrCmp $1 success success
    # download failed
    SetDetailsView show
    DetailPrint "download failed: $0"
    Abort
  success:
    # Set registry values
    !define regPath "SOFTWARE\winbuntu"
    SetRegView 64
    WriteRegStr HKLM "${regPath}" "WinbuntuPath" "$INSTDIR"

    # download success, execute cygwin setup with parameters (mirrors,
    # lux-minimal package, download & install locations, etc.)
    ExecWait '"$0" -vgBqO -l "$2" -R "$INSTDIR" \
    -s http://cygwin.mirror.constant.com/ \
    -P xorg-server xinit'

FunctionEnd

