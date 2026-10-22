; Counter-Strike 1.6 (Steam, 25th Anniversary) - ReGameDLL_CS + ZBots + HostageImprov
; Compile with Inno Setup 6: ISCC.exe CS16ZBots.iss

#define AppName "Counter-Strike 1.6 ZBots"
#define AppVersion "1.0"
#define Core AddBackslash(SourcePath) + "payload\core\"
#define Colors AddBackslash(SourcePath) + "payload\colors\"
#define ReGameVersion GetVersionNumbersString(Core + "dlls\mp.dll")

[Setup]
AppId={{5B7C2E41-9A3D-4F6B-8C1E-2D4A6F8B0C13}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
DefaultDirName={code:GetHalfLifeDir}
DirExistsWarning=no
AppendDefaultDirName=no
UsePreviousAppDir=yes
DisableProgramGroupPage=yes
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=commandline
UninstallFilesDir={app}\cstrike\zbots_uninstall
UninstallDisplayName={#AppName}
InfoBeforeFile=CREDITS.txt
OutputDir=output
OutputBaseFilename=CS16_ZBots_Setup
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern

[Types]
Name: "full"; Description: "Full installation"
Name: "custom"; Description: "Custom installation"; Flags: iscustom

[Components]
Name: "core"; Description: "ReGameDLL_CS {#ReGameVersion}, ZBots, HostageImprov, bot menus, nav files"; Types: full custom; Flags: fixed
Name: "colors"; Description: "Blue-grey menu colors"; Types: full

[Files]
Source: "{#Core}*"; DestDir: "{app}\cstrike"; Components: core; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "LICENSE-ReGameDLL.txt"; DestDir: "{app}\cstrike"; Components: core; Flags: ignoreversion
Source: "{#Colors}*"; DestDir: "{app}\cstrike"; Components: colors; Flags: ignoreversion recursesubdirs createallsubdirs

[Messages]
SelectDirLabel3=Select your Half-Life folder (the one that contains hl.exe and the cstrike folder).

[Code]
const
  BackupDir = 'cstrike\zbots_backup\';
  OverwrittenCount = 6;
  ReGameVersion = '{#ReGameVersion}';
  LatestReleaseApi = 'https://api.github.com/repos/rehlds/ReGameDLL_CS/releases/latest';
  LatestReleasePage = 'https://github.com/rehlds/ReGameDLL_CS/releases/latest';

var
  LatestVersion: String;
  UpdateCheckBox: TNewCheckBox;

{ Stock files this installer replaces; they are backed up and restored on uninstall }
function OverwrittenFile(I: Integer): String;
begin
  case I of
    0: Result := 'dlls\mp.dll';
    1: Result := 'delta.lst';
    2: Result := 'liblist.gam';
    3: Result := 'commandmenu.txt';
    4: Result := 'resource\CreateMultiplayerGameServerPage.res';
    5: Result := 'resource\TrackerScheme.res';
  end;
end;

{ SHA-256 of our version of each file, so re-running the installer doesn't back up our own files }
function OurHash(I: Integer): String;
begin
  case I of
    0: Result := '{#GetSHA256OfFile(Core + "dlls\mp.dll")}';
    1: Result := '{#GetSHA256OfFile(Core + "delta.lst")}';
    2: Result := '{#GetSHA256OfFile(Core + "liblist.gam")}';
    3: Result := '{#GetSHA256OfFile(Core + "commandmenu.txt")}';
    4: Result := '{#GetSHA256OfFile(Core + "resource\CreateMultiplayerGameServerPage.res")}';
    5: Result := '{#GetSHA256OfFile(Colors + "resource\TrackerScheme.res")}';
  end;
end;

function IsHalfLifeDir(Dir: String): Boolean;
begin
  Result := FileExists(AddBackslash(Dir) + 'hl.exe') and FileExists(AddBackslash(Dir) + 'cstrike\liblist.gam');
end;

{ Look through the Steam library folders for Half-Life }
function GetHalfLifeDir(Param: String): String;
var
  SteamPath, Line, Dir: String;
  Lines: TArrayOfString;
  I, P: Integer;
begin
  if not RegQueryStringValue(HKCU, 'Software\Valve\Steam', 'SteamPath', SteamPath) then
    SteamPath := ExpandConstant('{commonpf32}\Steam');
  StringChangeEx(SteamPath, '/', '\', True);
  Result := AddBackslash(SteamPath) + 'steamapps\common\Half-Life';
  if IsHalfLifeDir(Result) then
    Exit;
  if LoadStringsFromFile(AddBackslash(SteamPath) + 'steamapps\libraryfolders.vdf', Lines) then
    for I := 0 to GetArrayLength(Lines) - 1 do
    begin
      Line := Trim(Lines[I]);
      if Pos('"path"', Line) = 1 then
      begin
        Delete(Line, 1, 6);
        P := Pos('"', Line);
        Delete(Line, 1, P);
        P := Pos('"', Line);
        Dir := Copy(Line, 1, P - 1);
        StringChangeEx(Dir, '\\', '\', True);
        Dir := AddBackslash(Dir) + 'steamapps\common\Half-Life';
        if IsHalfLifeDir(Dir) then
        begin
          Result := Dir;
          Exit;
        end;
      end;
    end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  ErrorCode: Integer;
begin
  Result := True;
  if (CurPageID = wpFinished) and UpdateCheckBox.Visible and UpdateCheckBox.Checked then
    ShellExecAsOriginalUser('open', LatestReleasePage, '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
  if (CurPageID = wpSelectDir) and not IsHalfLifeDir(WizardDirValue) then
  begin
    MsgBox('This folder does not contain hl.exe and cstrike\liblist.gam.' + #13#10 +
      'Select your Half-Life folder, usually Steam\steamapps\common\Half-Life.', mbError, MB_OK);
    Result := False;
  end;
end;

{ Takes the next number off a dotted version string }
function NextVersionPart(var S: String): Integer;
var
  P: Integer;
begin
  P := Pos('.', S);
  if P = 0 then
    P := Length(S) + 1;
  Result := StrToIntDef(Copy(S, 1, P - 1), 0);
  Delete(S, 1, P);
end;

function IsNewerVersion(Latest, Current: String): Boolean;
var
  I, A, B: Integer;
begin
  Result := False;
  for I := 1 to 4 do
  begin
    A := NextVersionPart(Latest);
    B := NextVersionPart(Current);
    if A <> B then
    begin
      Result := A > B;
      Exit;
    end;
  end;
end;

{ Asks GitHub for the latest ReGameDLL_CS release tag; empty if offline or anything goes wrong }
function GetLatestReGameVersion: String;
var
  Json: AnsiString;
  S: String;
  P: Integer;
begin
  Result := '';
  try
    DownloadTemporaryFile(LatestReleaseApi, 'regamedll_latest.json', '', nil);
    if not LoadStringFromFile(ExpandConstant('{tmp}\regamedll_latest.json'), Json) then
      Exit;
    S := String(Json);
    P := Pos('"tag_name"', S);
    if P = 0 then
      Exit;
    Delete(S, 1, P + 9);
    Delete(S, 1, Pos('"', S));
    Result := Copy(S, 1, Pos('"', S) - 1);
  except
    Log('ReGameDLL update check failed: ' + GetExceptionMessage);
  end;
end;

{ Shown on the finish page only when GitHub has a newer release }
procedure InitializeWizard;
begin
  UpdateCheckBox := TNewCheckBox.Create(WizardForm);
  UpdateCheckBox.Parent := WizardForm.FinishedPage;
  UpdateCheckBox.Left := WizardForm.FinishedLabel.Left;
  UpdateCheckBox.Width := WizardForm.FinishedLabel.Width;
  UpdateCheckBox.Checked := True;
  UpdateCheckBox.Visible := False;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = wpFinished then
  begin
    WizardForm.FinishedLabel.Caption := 'Setup has finished installing {#SetupSetting("AppName")} on your computer.' + #13#10#13#10 +
      'If you ever use Steam''s "Verify integrity of game files", Steam restores the original mp.dll, ' +
      'delta.lst, liblist.gam and commandmenu.txt. Run this installer again afterwards.' + #13#10#13#10 +
      SetupMessage(msgClickFinish);
    WizardForm.FinishedLabel.AdjustHeight;
  end;
  if (CurPageID = wpFinished) and (LatestVersion <> '') and IsNewerVersion(LatestVersion, ReGameVersion) then
  begin
    UpdateCheckBox.Caption := 'Open the newer ReGameDLL_CS ' + LatestVersion + ' release page';
    UpdateCheckBox.Top := WizardForm.FinishedLabel.Top + WizardForm.FinishedLabel.Height + ScaleY(16);
    UpdateCheckBox.Visible := True;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  I: Integer;
  Src, Bak: String;
begin
  if (CurStep = ssPostInstall) and not WizardSilent then
    LatestVersion := GetLatestReGameVersion;
  if CurStep <> ssInstall then
    Exit;
  for I := 0 to OverwrittenCount - 1 do
  begin
    if (I = 5) and not WizardIsComponentSelected('colors') then
      Continue;
    Src := ExpandConstant('{app}\cstrike\') + OverwrittenFile(I);
    if not FileExists(Src) or (CompareText(GetSHA256OfFile(Src), OurHash(I)) = 0) then
      Continue;
    Bak := ExpandConstant('{app}\') + BackupDir + OverwrittenFile(I);
    ForceDirectories(ExtractFilePath(Bak));
    if not CopyFile(Src, Bak, False) then
      Log('Could not back up ' + Src);
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  I: Integer;
  Dst, Bak: String;
begin
  if CurUninstallStep <> usPostUninstall then
    Exit;
  for I := 0 to OverwrittenCount - 1 do
  begin
    Bak := ExpandConstant('{app}\') + BackupDir + OverwrittenFile(I);
    Dst := ExpandConstant('{app}\cstrike\') + OverwrittenFile(I);
    if FileExists(Bak) then
    begin
      ForceDirectories(ExtractFilePath(Dst));
      if CopyFile(Bak, Dst, False) then
        DeleteFile(Bak);
    end;
  end;
  { only empty folders are removed, so a backup that failed to restore is kept }
  RemoveDir(ExpandConstant('{app}\') + BackupDir + 'dlls');
  RemoveDir(ExpandConstant('{app}\') + BackupDir + 'resource');
  RemoveDir(ExpandConstant('{app}\') + BackupDir);
end;
