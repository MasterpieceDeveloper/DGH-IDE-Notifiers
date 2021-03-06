(**

  This module contains a procedure to add a splash screen entry to the RAD Studio splash screen on
  startup.

  @Author  David Hoyle
  @Version 1.0
  @Date    05 Jan 2020

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
unit DGHIDENotifiers.SplashScreen;

interface

{$INCLUDE CompilerDefinitions.inc}

procedure AddSplashScreen;

implementation

uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  ToolsAPI,
  SysUtils,
  Windows,
  Forms,
  DGHIDENotifiers.Common;

(**

  This method installs an entry in the RAD Studio IDE splash screen.

  @precon  None.
  @postcon An entry is added to the splash screen for this plugin.

**)
procedure AddSplashScreen;
const
  {$IFDEF D2007}
  strDGHIDENotificationsSplashScreenBitMap = 'DGHIDENotificationsSplashScreenBitMap24x24';
  {$ELSE}
  strDGHIDENotificationsSplashScreenBitMap = 'DGHIDENotificationsSplashScreenBitMap48x48';
  {$ENDIF}
var
  iMajor: Integer;
  iMinor: Integer;
  iBugFix: Integer;
  iBuild: Integer;
  bmSplashScreen: HBITMAP;
begin
  {$IFDEF CODESITE}
  CodeSite.TraceMethod('AddSplashScreen', tmoTiming);
  {$ENDIF}
  {$IFDEF D2005}
  BuildNumber(iMajor, iMinor, iBugFix, iBuild);
  bmSplashScreen := LoadBitmap(hInstance, strDGHIDENotificationsSplashScreenBitMap);
  (SplashScreenServices As IOTASplashScreenServices).AddPluginBitmap(
    Format(strSplashScreenName, [iMajor, iMinor, Copy(strRevision, iBugFix + 1, 1),
      Application.Title]),
    bmSplashScreen,
    {$IFDEF DEBUG} True {$ELSE} False {$ENDIF},
    Format(strSplashScreenBuild, [iMajor, iMinor, iBugfix, iBuild]), ''
    );
  {$ENDIF}
end;

end.

