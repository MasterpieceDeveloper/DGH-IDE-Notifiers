(**

  This module contains some common resource strings and a procedure for setting the wizard /expert /
  plug-ins build information for the splash screen and about box.

  @Author  David Hoyle
  @Version 1.025
  @Date    09 Feb 2020

  @license

    DGH IDE Notifiers is a RAD Studio plug-in to logging RAD Studio IDE notifications
    and to demostrate how to use various IDE notifiers.

    Copyright (C) 2019  David Hoyle (https://github.com/DGH2112/DGH-IDE-Notifiers/)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

**)
unit DGHIDENotifiers.Common;

interface

uses
  ToolsAPI;

procedure BuildNumber(var iMajor, iMinor, iBugFix, iBuild: Integer);

function GetProjectFileName(const Project: IOTAProject): string;

{$IFNDEF _FIXINSIGHT_}
resourcestring
  (** This resource string is used for the bug fix number in the splash screen and about box
      entries. **)
  strRevision = ' abcdefghijklmnopqrstuvwxyz';
  (** This resource string is used in the splash screen and about box entries. **)
  strSplashScreenName = 'DGH IDE Notifications %d.%d%s for %s';
  {$IFDEF DEBUG}
  (** This resource string is used in the splash screen and about box entries. **)
  strSplashScreenBuild = 'David Hoyle (c) 2020 License GNU GPL3 (DEBUG Build %d.%d.%d.%d)';
  {$ELSE}
  (** This resource string is used in the splash screen and about box entries. **)
  strSplashScreenBuild = 'David Hoyle (c) 2020 License GNU GPL3 (Build %d.%d.%d.%d)';
  {$ENDIF}

const
  (** A constant to define the failed state for a notifier not installed. **)
  iWizardFailState = -1;
{$ENDIF}

implementation

uses
  SysUtils,
  Windows;

(**

  This procedure returns the build information for the OTA Plugin.

  @precon  None.
  @postcon the build information for the OTA plugin is returned.

  @param   iMajor  as an Integer as a reference
  @param   iMinor  as an Integer as a reference
  @param   iBugFix as an Integer as a reference
  @param   iBuild  as an Integer as a reference

**)
procedure BuildNumber(var iMajor, iMinor, iBugFix, iBuild: Integer);
const
  iWordMask = $FFFF;
  iBitShift = 16;
var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
  strBuffer: array[0..MAX_PATH] of Char;
begin
  { Build Number }
  GetModuleFilename(hInstance, strBuffer, MAX_PATH);
  VerInfoSize := GetFileVersionInfoSize(strBuffer, Dummy);
  if VerInfoSize <> 0 then
  begin
    GetMem(VerInfo, VerInfoSize);
    try
      GetFileVersionInfo(strBuffer, 0, VerInfoSize, VerInfo);
      VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
      iMajor := VerValue^.dwFileVersionMS shr iBitShift;
      iMinor := VerValue^.dwFileVersionMS and iWordMask;
      iBugFix := VerValue^.dwFileVersionLS shr iBitShift;
      iBuild := VerValue^.dwFileVersionLS and iWordMask;
    finally
      FreeMem(VerInfo, VerInfoSize);
    end;
  end;
end;

(**

  This method returns the filename of the given project is the project is valid.

  @precon  None.
  @postcon The filename of the project is returned if valid.

  @param   Project as an IOTAProject as a constant
  @return  a String

**)
function GetProjectFileName(const Project: IOTAProject): string;
resourcestring
  strNoProject = '(no project)';
begin
  Result := strNoProject;
  if Project <> Nil then
    Result := ExtractFileName(Project.FileName);
end;

end.

