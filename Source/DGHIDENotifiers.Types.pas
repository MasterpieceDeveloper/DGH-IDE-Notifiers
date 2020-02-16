(**

  This module contains a custom base class for all the notifier along with supporting types so that
  all the notifiers can log messages with the notification logging window.

  @Author  David Hoyle
  @Version 1.049
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
unit DGHIDENotifiers.Types;

interface

uses
  ToolsAPI,
  Graphics;

type
  (** An enumerate to describe each notification type. **)
  TDGHIDENotification = (dinWizard, dinMenuWizard, dinIDENotifier, dinVersionControlNotifier, dinCompileNotifier, dinMessageNotifier, dinIDEInsightNotifier, dinProjectFileStorageNotifier, dinEditorNotifier, dinDebuggerNotifier, dinModuleNotifier, dinProjectNotifier, dinProjectCompileNotifier, dinSourceEditorNotifier, dinFormNotifier, dinEditViewNotifier);

  (** A set of the above notification type so that they can be filtered. **)
  TDGHIDENotifications = set of TDGHIDENotification;

  (** A base notifier object to provide common notification messaging in all notifiers. **)
  TDGHNotifierObject = class(TNotifierObject, IOTANotifier)
  strict private
    FNotification: TDGHIDENotification;
    FNotifier: string;
    FFileName: string;
  strict protected
    // IOTANotifier
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;
    // Implementation Methods
    procedure DoNotification(const strMessage: string);
    function GetFileName: string;
  public
    constructor Create(const strNotifier, strFileName: string; const iNotification: TDGHIDENotification); virtual;
    destructor Destroy; override;
    // TInterfaceObject
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    (**
      A property to read and write the module file name so the notifier knows the file name it is
      associated with.
      @precon  None.
      @postcon Returns the filename of the module associated with the notifier.
      @return  a String
    **)
    property FileName: string read FFileName write FFileName;
  end;

const
  (** A constant array of colours to provide a different colour for each notification. **)
  iNotificationColours: array[Low(TDGHIDENotification)..High(TDGHIDENotification)] of TColor = (clTeal, clAqua, clMaroon, clRed, clNavy, clBlue, clOlive, clYellow, clGreen,    //clLime // not used as its the BitMap mask colour
    clPurple, clFuchsia, clDkGray, clSilver, $FFFF80, $FF80FF, $80FFFF);

  (** A constant array of boolean to provide a string representation of a boolean value. **)
  strBoolean: array[Low(False)..High(True)] of string = ('False', 'True');

  (** A constant array of strings to provide string representation of each notification. **)
  strNotificationLabel: array[TDGHIDENotification] of string = ('Wizard Notifications', 'Menu Wizard Notifications', 'IDE Notifications', 'Version Control Notifications', 'Compile Notifications', 'Message Notifications', 'IDE Insight Notifications', 'Project File Storage Notifications', 'Editor Notifications', 'Debugger Notifications', 'Module Notifications', 'Project Notifications', 'Project Compile Notifications', 'Source Editor Notifications', 'Form Notifications', 'Edit View Notifier');

implementation

uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  SysUtils,
  DGHIDENotifiers.DockableIDENotificationsForm;

(**

  This method of the notifier is called after construction of the notifier (not is all cases).

  @precon  None.
  @postcon Outputs a notification.

**)
procedure TDGHNotifierObject.AfterConstruction;
resourcestring
  strAfterConstruction = '%s.AfterConstruction';
begin
  inherited AfterConstruction;
  DoNotification(Format(strAfterConstruction, [GetFileName]));
end;

(**

  This method is called after the object the notifier is attached to is saved (if applicable).

  @precon  None.
  @postcon Outputs a notification.

**)
procedure TDGHNotifierObject.AfterSave;
resourcestring
  strAfterSave = '%s.AfterSave';
begin
  DoNotification(Format(strAfterSave, [GetFileName]));
end;

(**

  This method is called before the notifier is destroyed.

  @precon  None.
  @postcon Outputs a notification.

**)
procedure TDGHNotifierObject.BeforeDestruction;
resourcestring
  strBeforeDestruction = '%s.BeforeDestruction';
begin
  inherited BeforeDestruction;
  DoNotification(Format(strBeforeDestruction, [GetFileName]));
end;

(**

  This method is called before the object the notifier is attached to is saved (if applicable).

  @precon  None.
  @postcon Outputs a notification.

**)
procedure TDGHNotifierObject.BeforeSave;
resourcestring
  strBeforeSave = '%s.BeforeSave';
begin
  DoNotification(Format(strBeforeSave, [GetFileName]));
end;

(**

  A constructor for the TDGHNotifierObject class.

  @precon  None.
  @postcon Stores the notifier object name and notifier type.

  @param   strNotifier   as a String as a constant
  @param   strFileName   as a String as a constant
  @param   iNotification as a TDGHIDENotification as a constant

**)
constructor TDGHNotifierObject.Create(const strNotifier, strFileName: string; const iNotification: TDGHIDENotification);
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod(Self, 'Create', tmoTiming); {$ENDIF}
  inherited Create;
  FNotifier := strNotifier;
  FFileName := strFileName;
  FNotification := iNotification;
end;

(**

  A destructor for the TDGHNotifierObject class.

  @precon  None.
  @postcon Does nothing.

**)
destructor TDGHNotifierObject.Destroy;
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod(Self, 'Destroy', tmoTiming); {$ENDIF}
  inherited Destroy;
end;

(**

  This method is called when the notifier is destroyed.

  @precon  None.
  @postcon Outputs a notificiation.

**)
procedure TDGHNotifierObject.Destroyed;
resourcestring
  strDestroyed = '%s.Destroyed';
begin
  DoNotification(Format(strDestroyed, [GetFileName]));
end;

(**

  This method adds a notification to the dockable notifier form.

  @precon  None.
  @postcon A notification is aded to the dockable form.

  @param   strMessage as a String as a constant

**)
procedure TDGHNotifierObject.DoNotification(const strMessage: string);
begin
  TfrmDockableIDENotifications.AddNotification(FNotification, FNotifier + strMessage);
end;

(**

  Returns the filename associated with the notifier if set.

  @precon  None.
  @postcon Returns the filename associated with the notifier if set.

  @return  a String

**)
function TDGHNotifierObject.GetFileName: string;
begin
  Result := '';
  if Length(FFileName) > 0 then
    Result := '(' + ExtractFileName(FFileName) + ')';
end;

(**

  This method is called when the object the notifier is attached to is saved (if applicable).

  @precon  None.
  @postcon Outputs a message.

**)
procedure TDGHNotifierObject.Modified;
resourcestring
  strModified = '%s.Modified';
begin
  DoNotification(Format(strModified, [GetFileName]));
end;

end.

