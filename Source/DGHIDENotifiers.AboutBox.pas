(**

  This module contains two procedures for adding and removing an about box entry in the RAD Studio
  IDE.

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
unit DGHIDENotifiers.AboutBox;

interface

{$INCLUDE CompilerDefinitions.inc}

procedure AddAboutBoxEntry;

procedure RemoveAboutBoxEntry;

implementation

uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  ToolsAPI,
  SysUtils,
  Windows,
  DGHIDENotifiers.Common,
  Forms;

{$IFDEF D2005}
var
  (** This is an internal reference for the about box entry`s plugin index - requried for
      removal. **)
  iAboutPlugin: Integer;
{$ENDIF}

(**

  This method adds an Aboutbox entry to the RAD Studio IDE.

  @precon  None.
  @postcon The about box entry is added to the IDE and its plugin index stored in iAboutPlugin.

**)

procedure AddAboutBoxEntry;
const
  strSplashScreenResName = 'DGHIDENotificationsSplashScreenBitMap48x48';
resourcestring
  strIDEExpertToLogIDENotifications = 'An IDE expert to log IDE notifications.';
  strSKUBuild = 'SKU Build %d.%d.%d.%d';
var
  iMajor: Integer;
  iMinor: Integer;
  iBugFix: Integer;
  iBuild: Integer;
  bmSplashScreen: HBITMAP;
begin
  {$IFDEF CODESITE}CodeSite.TraceMethod('AddAboutBoxEntry', tmoTiming);{$ENDIF}
  {$IFDEF D2005}
  BuildNumber(iMajor, iMinor, iBugFix, iBuild);
  bmSplashScreen := LoadBitmap(hInstance, strSplashScreenResName);
  iAboutPlugin := (BorlandIDEServices As IOTAAboutBoxServices).AddPluginInfo(
    Format(strSplashScreenName, [iMajor, iMinor, Copy(strRevision, iBugFix + 1, 1),
      Application.Title]),
    strIDEExpertToLogIDENotifications,
    bmSplashScreen,
    {$IFDEF DEBUG} True {$ELSE} False {$ENDIF},
    Format(strSplashScreenBuild, [iMajor, iMinor, iBugfix, iBuild]),
    Format(strSKUBuild, [iMajor, iMinor, iBugfix, iBuild]));
  {$ENDIF}
end;

(**

  This method removes the indexed abotu box entry from the RAD Studio IDE.

  @precon  None.
  @postcon The about box entry is remvoed from the IDE.

**)
procedure RemoveAboutBoxEntry;
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod('RemoveAboutBoxEntry', tmoTiming); {$ENDIF}
  {$IFDEF D2010}
  if iAboutPlugin > iWizardFailState then
    (BorlandIDEServices as IOTAAboutBoxServices).RemovePluginInfo(iAboutPlugin);
  {$ENDIF}
end;

end.

