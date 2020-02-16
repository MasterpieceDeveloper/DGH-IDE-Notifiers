(**

  This module contains a class which implements the IOTAModuleNotifier interfaces for tracking
  changes to modules in the IDE.

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
unit DGHIDENotifiers.ModuleNotifier;

interface

uses
  ToolsAPI,
  DGHIDENotifiers.Interfaces,
  DGHIDENotifiers.Types;

{$INCLUDE 'CompilerDefinitions.inc'}

type
  (** A class to implements the IOTAModuleNotitifer interfaces. **)
  TDNModuleNotifier = class(TDGHNotifierObject, IOTAModuleNotifier, IOTAModuleNotifier80, IOTAModuleNotifier90)
  strict private
    FModuleRenameEvent: TDNModuleRenameEvent;
  {$IFDEF D2010}   strict {$ENDIF} protected
    // IOTAModuleNotifier
    function CheckOverwrite: Boolean;
    procedure ModuleRenamed(const NewName: string);
    // IOTAModuleNotifier80
    function AllowSave: Boolean;
    function GetOverwriteFileNameCount: Integer;
    function GetOverwriteFileName(Index: Integer): string;
    procedure SetSaveFileName(const FileName: string);
    // IOTAModuleNotifier90
    procedure BeforeRename(const OldFileName, NewFileName: string);
    procedure AfterRename(const OldFileName, NewFileName: string);
    // General Properties
    (**
      A property the exposes to this class and descendants an interface for notifying the module notifier
      collections of a change of module name.
      @precon  None.
      @postcon Returns the IDINRenameModule reference.
      @return  a TDNModuleRenameEvent
    **)
    property ModuleRenameEvent: TDNModuleRenameEvent read FModuleRenameEvent;
  public
    constructor Create(const strNotifier, strFileName: string; const iNotification: TDGHIDENotification; const ModuleRenameEvent: TDNModuleRenameEvent); reintroduce; overload;
  end;

implementation

uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  SysUtils;

(**

  This method of the notifier is called after a module has been renamed providing the old and new
  filenames.

  @precon  None.
  @postcon Logs a notification message.

  @param   OldFileName as a String as a constant
  @param   NewFileName as a String as a constant

**)
procedure TDNModuleNotifier.AfterRename(const OldFileName, NewFileName: string);
resourcestring
  strAfterRename = '90(%s).AfterRename = OldFileName: %s, NewFileName: %s';
begin
  DoNotification(Format(strAfterRename, [ExtractFileName(FileName), ExtractFileName(OldFileName), ExtractFileName(NewFileName)]));
  FileName := NewFileName;
  if Assigned(ModuleRenameEvent) then
    ModuleRenameEvent(OldFileName, NewFileName);
end;

(**

  This method of the notifier is called to check whether your notifier will allow the module to be
  saved. Return true to allow the module to be saved by the IDE else return false to prevent saving
  the module.

  @precon  None.
  @postcon Logs a notification message.

  @return  a Boolean

**)
function TDNModuleNotifier.AllowSave: Boolean;
resourcestring
  strAllowSave = '80(%s).AllowSave = Result: True';
begin
  Result := True;
  DoNotification(Format(strAllowSave, [ExtractFileName(FileName)]));
end;

(**

  This method of the notifier is callde before a module is renamed providing the old and new file
  names.

  @precon  None.
  @postcon Logs a notification message.

  @param   OldFileName as a String as a constant
  @param   NewFileName as a String as a constant

**)
procedure TDNModuleNotifier.BeforeRename(const OldFileName, NewFileName: string);
resourcestring
  strBeforeRename = '90(%s).BeforeRename = OldFileName: %s, NewFileName: %s';
begin
  DoNotification(Format(strBeforeRename, [ExtractFileName(FileName), ExtractFileName(OldFileName), ExtractFileName(NewFileName)]));
end;

(**

  This method of the notifier is called before a Save As operation to check if any files read only
  file wil be overwritten.

  @precon  None.
  @postcon A log entry is written.

  @return  a Boolean

**)
function TDNModuleNotifier.CheckOverwrite: Boolean;
resourcestring
  strCheckOverwrite = '(%s).CheckOverwrite = Result: True';
begin
  Result := True;
  DoNotification(Format(strCheckOverwrite, [ExtractFileName(FileName)]));
end;

(**

  A constructor for the TDNModuleNotfier class.

  @precon  None.
  @postcon Initialises the module.

  @param   strNotifier       as a String as a constant
  @param   strFileName       as a String as a constant
  @param   iNotification     as a TDGHIDENotification as a constant
  @param   ModuleRenameEvent as a TDNModuleRenameEvent as a constant

**)
constructor TDNModuleNotifier.Create(const strNotifier, strFileName: string; const iNotification: TDGHIDENotification; const ModuleRenameEvent: TDNModuleRenameEvent);
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod(Self, 'Create', tmoTiming); {$ENDIF}
  inherited Create(strNotifier, strFileName, iNotification);
  FModuleRenameEvent := ModuleRenameEvent;
end;

(**

  This method of the notifier is called so that you can return a number of files (in addition to those
  managed by the IDE) that you want to manage along with the module.

  @precon  None.
  @postcon Returns an empty string but isn

  @nocheck MissingCONSTInParam

  @param   Index as an Integer
  @return  a String

**)
function TDNModuleNotifier.GetOverwriteFileName(Index: Integer): string;
resourcestring
  strGetOverwriteFileName = '(%s).GetOverwriteFileName = Index: %d, Result: ''''';
begin
  Result := '';
  DoNotification(Format(strGetOverwriteFileName, [ExtractFileName(FileName), Index]));
end;

(**

  This method of the notifier is called so that you can return the number of files (in addition to
  those managed by the IDE) that you want to manage along with the module and specifically to be checked
  by the IDE during a Save As operation.

  @precon  None.
  @postcon Return 0 to indicate there are no extra files to manage.

  @return  an Integer

**)
function TDNModuleNotifier.GetOverwriteFileNameCount: Integer;
resourcestring
  strGetOverwriteFileName = '(%s).GetOverwriteFileNameCount = Result: 0';
begin
  Result := 0;
  DoNotification(Format(strGetOverwriteFileName, [ExtractFileName(FileName)]));
end;

(**

  This method of the notifier is called when a module has been renamed.

  @precon  None.
  @postcon Logs a message to the notifications view.

  @param   NewName as a String as a constant

**)
procedure TDNModuleNotifier.ModuleRenamed(const NewName: string);
resourcestring
  strModuleRenamed = '80(%s).ModuleRenamed = NewName: %s';
begin
  DoNotification(Format(strModuleRenamed, [ExtractFileName(FileName), ExtractFileName(NewName)]));
  FileName := NewName;
end;

(**

  This method of the notifier is called with the fully qualified filename that the user entered in the
  Save As dialog. This name can then be used to determine all the resulting names.

  @precon  None.
  @postcon A log message is saved.

  @param   FileName as a String as a constant

**)
procedure TDNModuleNotifier.SetSaveFileName(const FileName: string);
resourcestring
  strSetSaveFileName = '80(%s).SetSaveFileName = FileName: %s';
begin
  DoNotification(Format(strSetSaveFileName, [ExtractFileName(FileName), ExtractFileName(FileName)]));
end;

end.

