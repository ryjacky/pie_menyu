; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "PieMenyu"
#define MyAppVersion "0.0.4-alpha"
#define MyAppPublisher "PieMenyu"
#define MyAppURL "https://github.com/ryjacky/PieMenyu"
#define MyAppExeName "pie_menyu_editor.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{05145B8F-45B4-4341-B484-12E34D3BB729}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
OutputDir=.
OutputBaseFilename=PieMenyuInstaller
Compression=lzma
SolidCompression=yes
WizardStyle=classic

[UninstallRun]
Filename: "{cmd}"; Parameters: "/C ""taskkill /im pie_menyu.exe /f /t"
Filename: "{cmd}"; Parameters: "/C ""taskkill /im pie_menyu_editor.exe /f /t"

[Registry]
Root: "HKCR"; Subkey: "piemenyu"; ValueType: string; ValueName: ""; ValueData: "URL:piemenyu Protocol"; Flags: uninsdeletekey
Root: "HKCR"; Subkey: "piemenyu"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""; Flags: uninsdeletevalue
Root: "HKCR"; Subkey: "piemenyu\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\PieMenyu\pie_menyu.exe"" ""%1"""; Flags: uninsdeletekey
Root: "HKCR"; Subkey: "piemenyueditor"; ValueType: string; ValueName: ""; ValueData: "URL:piemenyueditor Protocol"; Flags: uninsdeletekey
Root: "HKCR"; Subkey: "piemenyueditor"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""; Flags: uninsdeletevalue
Root: "HKCR"; Subkey: "piemenyueditor\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\PieMenyuEditor\pie_menyu_editor.exe"" ""%1"""; Flags: uninsdeletekey

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"
Name: "chinese"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\PieMenyuEditor\{#MyAppName}"; Filename: "{app}\PieMenyuEditor\{#MyAppExeName}"
Name: "{autodesktop}\PieMenyuEditor\{#MyAppName}"; Filename: "{app}\PieMenyuEditor\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\PieMenyuEditor\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usPostUninstall then
  begin
    if MsgBox('Do you also want to remove all user data related to PieMenyu?', mbConfirmation, MB_YESNO or MB_DEFBUTTON2) = IDYES then
    begin
        DelTree(ExpandConstant('{userappdata}\PieMenyu'), True, True, True);
    end;
  end;
end;

function IsProcessRunning(const FileName : string): Boolean;
var
    FSWbemLocator: Variant;
    FWMIService   : Variant;
    FWbemObjectSet: Variant;
begin
    Result := false;
    FSWbemLocator := CreateOleObject('WBEMScripting.SWBEMLocator');
    FWMIService := FSWbemLocator.ConnectServer('', 'root\CIMV2', '', '');
    FWbemObjectSet :=
      FWMIService.ExecQuery(
        Format('SELECT Name FROM Win32_Process Where Name="%s"', [FileName]));
    Result := (FWbemObjectSet.Count > 0);
    FWbemObjectSet := Unassigned;
    FWMIService := Unassigned;
    FSWbemLocator := Unassigned;
end;

function InitializeSetup(): Boolean;
var
    ResultCode: Integer;
begin
  Result := True;
  
  if IsProcessRunning('pie_menyu.exe') or IsProcessRunning('pie_menyu_editor.exe') then
  begin
    if MsgBox('There are instances of PieMenyu running. Please save any unsaved work and close them before proceeding with the installation. Click OK to continue or Cancel to abort the installation.', mbConfirmation, MB_OKCANCEL) = IDCANCEL then
    begin
      Result := False;
    end
    else
    begin
      Exec('taskkill', '/F /IM pie_menyu.exe /t', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
      Exec('taskkill', '/F /IM pie_menyu_editor.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    end;
  end;
end;