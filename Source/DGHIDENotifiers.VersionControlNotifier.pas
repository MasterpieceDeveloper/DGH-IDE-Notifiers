(**

  This module contain a class which implements the IOTAVersionControlNotifier and
  IOTAVersionControlNotifier150 interfaces to demonstrate how to create a version control interface
  for the RAD Studio IDE. The methods of the notifier are logged to the notification log window.

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
unit DGHIDENotifiers.VersionControlNotifier;

interface

uses
  ToolsAPI,
  Classes,
  DGHIDENotifiers.Types;

{$INCLUDE CompilerDefinitions.inc}

{$IFDEF D2010}
type
  (** This class implements version control notifiers to allow you to create your own
      version control system. **)
  TDGHIDENotificationsVersionControlNotifier = class(TDGHNotifierObject, IOTAVersionControlNotifier {$IFDEF DXE00}, IOTAVersionControlNotifier150 {$ENDIF})
  strict private
  strict protected
  public
    // IOTAVersionControlNotifier
    function AddNewProject(const Project: IOTAProject): Boolean;
    function GetDisplayName: string;
    function IsFileManaged(const Project: IOTAProject; const IdentList: TStrings): Boolean;
    procedure ProjectManagerMenu(const Project: IOTAProject; const IdentList: TStrings; const ProjectManagerMenuList: IInterfaceList; IsMultiSelect: Boolean);
    {$IFDEF DXE00}
    // IOTAVersionControlNotifier150
    function CheckoutProject(var ProjectName: string): Boolean;
    function CheckoutProjectWithConnection(var ProjectName: string; const Connection: string): Boolean;
    function GetName: string;
    {$ENDIF}
  end;
{$ENDIF}

implementation

uses
  SysUtils,
  DGHIDENotifiers.Common;

{$IFDEF D2010}
{ TDGHIDENotifiersVersionControlNotifications }

(**

  This method is called when a new project is added to the version control system.

  @precon  None.
  @postcon Provides access to the roject being added.

  @param   Project as an IOTAProject as a constant
  @return  a Boolean

**)
function TDGHIDENotificationsVersionControlNotifier.AddNewProject(const Project: IOTAProject): Boolean;
resourcestring
  strAddNewProjectProject = '.AddNewProject = Project: %s';
begin
  Result := True;
  DoNotification(Format(strAddNewProjectProject, [GetProjectFileName(Project)]));
end;

{$IFDEF DXE00}
(**

  This methos is called when a project is to be checked out of the version control system.

  @precon  None.
  @postcon Provides the project name.

  @param   ProjectName as a String as a reference
  @return  a Boolean

**)
function TDGHIDENotificationsVersionControlNotifier.CheckoutProject(var ProjectName: string): Boolean;
resourcestring
  strCheckOutProjectProjectName = '150.CheckOutProject = ProjectName: %s';
begin
  Result := True;
  DoNotification(Format(strCheckOutProjectProjectName, [ProjectName]));
end;

(**

  This method is called when a project is to be checked out of a remove connection.

  @precon  None.
  @postcon Provides access to the project name and connection.

  @param   ProjectName as a String as a reference
  @param   Connection  as a String as a constant
  @return  a Boolean

**)
function TDGHIDENotificationsVersionControlNotifier.CheckoutProjectWithConnection(var ProjectName: string; const Connection: string): Boolean;
resourcestring
  strCheckOutProjectWithConnectionProjectNameConnection = '150.CheckOutProjectWithConnection = ' + 'ProjectName: %s, Connection: %s';
begin
  Result := True;
  DoNotification(Format(strCheckOutProjectWithConnectionProjectNameConnection, [ProjectName, Connection]));
end;
{$ENDIF}

(**

  This is a getter method for the DisplayName property.

  @precon  None.
  @postcon Sould return the display name of the version control system.

  @return  a String

**)

function TDGHIDENotificationsVersionControlNotifier.GetDisplayName: string;
resourcestring
  strDGHIDENotifier = 'DGH IDE Notifier';
  strGetDisplayName = '.GetDisplayName = %s';
begin
  Result := strDGHIDENotifier;
  DoNotification(Format(strGetDisplayName, [Result]));
end;

{$IFDEF DXE00}
(**

  This is a getter method for the Name property.

  @precon  None.
  @postcon Should return the name of the version control system.

  @return  a String

**)
function TDGHIDENotificationsVersionControlNotifier.GetName: string;
resourcestring
  strGetName = '.GetName = %s';
const
  strDGHIDENotifier = 'DGHIDENotifier';
begin
  Result := strDGHIDENotifier;
  DoNotification(Format(strGetName, [Result]));
end;
{$ENDIF}

(**

  This method is called to find out if the file is managed by the versiom control system.

  @precon  None.
  @postcon Provides access to the project and a list of file identifiers.

  @param   Project   as an IOTAProject as a constant
  @param   IdentList as a TStrings as a constant
  @return  a Boolean

**)

function TDGHIDENotificationsVersionControlNotifier.IsFileManaged(const Project: IOTAProject; const IdentList: TStrings): Boolean;
resourcestring
  strIsFileManagedProjectIdentList = '.IsFileManaged = Project: %s, IdentList: %s';
begin
  Result := False;
  DoNotification(Format(strIsFileManagedProjectIdentList, [GetProjectFileName(Project), IdentList.Text]));
end;

(**

  This method is called when the context menu is invoked on the project manager.

  @precon  None.
  @postcon Provides access to the project, a list of the selected file identifiers and the
           project manager menu.

  @nohint  ProjectManagerMenuList
  @nocheck MissingCONSTINParam

  @param   Project                as an IOTAProject as a constant
  @param   IdentList              as a TStrings as a constant
  @param   ProjectManagerMenuList as an IInterfaceList as a constant
  @param   IsMultiSelect          as a Boolean

**)
procedure TDGHIDENotificationsVersionControlNotifier.ProjectManagerMenu(const Project: IOTAProject; const IdentList: TStrings; const ProjectManagerMenuList: IInterfaceList; IsMultiSelect: Boolean); //FI:O804

resourcestring
  strIsFileManaged = '150.IsFileManaged = Project: %s, IdentList: %s, ProjectManagerMenuList: %s, ' + 'IsMultiSelect: %s';
const
  strProjectManagerMenuList = 'ProjectManagerMenuList';
begin
  if Project = Nil then
    DoNotification(Format(strIsFileManaged, [GetProjectFileName(Project), IdentList.Text, strProjectManagerMenuList, strBoolean[IsMultiSelect]]));
end;
{$ENDIF}

end.

