(**

  This module contains a class that implements the IOTAProjectNotifier which uses the
  TDNModuleNotifier class as a based class.

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
unit DGHIDENotifiers.ProjectNotifier;

interface

{$INCLUDE 'CompilerDefinitions.inc'}

uses
  ToolsAPI,
  DGHIDENotifiers.ModuleNotifier;

type
  (** A class to implement the IOTAProjectNotifier interface. **)
  TDNProjectNotifier = class(TDNModuleNotifier, IOTAProjectNotifier)
  strict private
  {$IFDEF D2010}   strict {$ENDIF} protected
    // IOTAProjectModule
    procedure ModuleAdded(const AFileName: string);
    procedure ModuleRemoved(const AFileName: string);
    procedure ModuleRenamed(const AOldFileName, ANewFileName: string); {$IFNDEF D2010} overload; {$ENDIF}
  public
  end;

implementation

uses
  SysUtils;

(**

  This method of the notifier is called when a module is added to a project or a project is added
  to a project group.

  @precon  None.
  @postcon Logs the file added.

  @param   AFileName as a String as a constant

**)
procedure TDNProjectNotifier.ModuleAdded(const AFileName: string);
resourcestring
  strModuleAdded = '(%s).ModuleAdded = AFileName: %s';
begin
  DoNotification(Format(strModuleAdded, [FileName, ExtractFileName(AFileName)]));
end;

(**

  This method of the notifier is called when a module is removed from a project or a project is
  removed from a prject group.

  @precon  None.
  @postcon Logs the file removed.

  @param   AFileName as a String as a constant

**)
procedure TDNProjectNotifier.ModuleRemoved(const AFileName: string);
resourcestring
  strModuleRemoved = '(%s).ModuleRemoved = AFileName: %s';
begin
  DoNotification(Format(strModuleRemoved, [FileName, ExtractFileName(AFileName)]));
end;

(**

  This method is called when a file has its name changed.

  @precon  None.
  @postcon The old and new file names are logged.

  @param   AOldFileName as a String as a constant
  @param   ANewFileName as a String as a constant

**)
procedure TDNProjectNotifier.ModuleRenamed(const AOldFileName, ANewFileName: string);
resourcestring
  strModuleRenamed = '(%s).ModuleRenamed = AOldFileName: %s, ANewFileName: %s';
begin
  DoNotification(Format(strModuleRenamed, [FileName, ExtractFileName(AOldFileName), ExtractFileName(ANewFileName)]));
  FileName := ANewFileName;
  if Assigned(ModuleRenameEvent) then
    ModuleRenameEvent(AOldFileName, ANewFileName);
end;

end.

