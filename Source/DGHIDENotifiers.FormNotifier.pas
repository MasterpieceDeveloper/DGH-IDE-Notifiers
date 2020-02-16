(**

  This module contains a class which implements an IOTAFormNotifier interfaces for capturing form
  changes.

  @Author  David Hoyle
  @Version 1.008
  @Date    08 Feb 2020

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
unit DGHIDENotifiers.FormNotifier;

interface

uses
  ToolsAPI,
  DGHIDENotifiers.ModuleNotifier;

type
  (** A class to implement an IOTAFormNotifier interface. **)
  TDINFormNotifier = class(TDNModuleNotifier, IInterface, IOTANotifier, IOTAFormNotifier)
  strict private
  {$IFDEF D2010}   strict {$ENDIF} protected
    procedure ComponentRenamed(ComponentHandle: Pointer; const OldName: string; const NewName: string);
    procedure FormActivated;
    procedure FormSaving;
  public
  end;

implementation

uses
  SysUtils;

{ TDNFormNotifier }

(**

  This method is called when a component on the form is renamed.

  @precon  None.
  @postcon Outputs the name changes.

  @nocheck MissingCONSTInParam

  @param   ComponentHandle as a Pointer
  @param   OldName         as a String as a constant
  @param   NewName         as a String as a constant

**)
procedure TDINFormNotifier.ComponentRenamed(ComponentHandle: Pointer; const OldName, NewName: string);
resourcestring
  strComponentRenamed = '.ComponentRenamed = ComponentHandle: %p, OldName: %s, NewName: %s';
begin
  DoNotification(Format(strComponentRenamed, [ComponentHandle, OldName, NewName]));
end;

(**

  This method is called when a form is activated.

  @precon  None.
  @postcon A notifications is output.

**)
procedure TDINFormNotifier.FormActivated;
resourcestring
  strFormActivated = '.FormActivated';
begin
  DoNotification(strFormActivated);
end;

(**

  This method is called when a form is saving.

  @precon  None.
  @postcon A notifications is output.

**)
procedure TDINFormNotifier.FormSaving;
resourcestring
  strFormSaving = '.FormSaving';
begin
  DoNotification(strFormSaving);
end;

end.

