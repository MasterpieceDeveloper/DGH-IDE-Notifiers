(**

  This module contains a class which implements the IOTAEditorNotifier and INTAEditServicesNotifier
  interfaces for capturing editor events in the RAD Studio IDE.

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
unit DGHIDENotifiers.EditorNotifier;

interface

uses
  ToolsAPI,
  DockForm,
  Classes,
  DGHIDENotifiers.Types;

{$INCLUDE 'CompilerDefinitions.inc'}

type
  (** This class implements a notifier to capture editor notifications. **)
  TDGHNotificationsEditorNotifier = class(TDGHNotifierObject, IOTANotifier, IOTAEditorNotifier, INTAEditServicesNotifier)
  strict private
  strict protected
  public
    // IOTAEditorNotifier
    procedure ViewActivated(const View: IOTAEditView);
    procedure ViewNotification(const View: IOTAEditView; Operation: TOperation);
    // INTAEditorServicesNotifier
    procedure DockFormRefresh(const EditWindow: INTAEditWindow; DockForm: TDockableForm);
    procedure DockFormUpdated(const EditWindow: INTAEditWindow; DockForm: TDockableForm);
    procedure DockFormVisibleChanged(const EditWindow: INTAEditWindow; DockForm: TDockableForm);
    procedure EditorViewActivated(const EditWindow: INTAEditWindow; const EditView: IOTAEditView);
    procedure EditorViewModified(const EditWindow: INTAEditWindow; const EditView: IOTAEditView);
    procedure WindowActivated(const EditWindow: INTAEditWindow);
    procedure WindowCommand(const EditWindow: INTAEditWindow; Command: Integer; Param: Integer; var Handled: Boolean);
    procedure WindowNotification(const EditWindow: INTAEditWindow; Operation: TOperation);
    procedure WindowShow(const EditWindow: INTAEditWindow; Show: Boolean; LoadedFromDesktop: Boolean);
  end;

implementation

uses
  SysUtils,
  TypInfo;

resourcestring
  (** A resource string for no edit window **)
  strNoEditWindow = '(no edit window)';
  (** A resource string for no form **)
  strNoForm = '(no form)';
  (** A resource string for no dockform **)
  strNoDockform = '(no dockform)';

(**

  This function returns the DockForm Caption.

  @precon  None.
  @postcon The DockForm Caption is returned.

  @nocheck MissingCONSTInParam

  @param   DockForm as a TDockableForm
  @return  a String

**)
function GetDockFormCaption(DockForm: TDockableForm): string;
begin
  Result := strNoDockform;
  if DockForm <> Nil then
    Result := DockForm.Caption;
end;

(**

  This function returns the DockForm ClassName.

  @precon  None.
  @postcon The DockForm ClassName is returned.

  @nocheck MissingCONSTInParam

  @param   DockForm as a TDockableForm
  @return  a String

**)
function GetDockFormClassName(DockForm: TDockableForm): string;
begin
  Result := strNoDockform;
  if DockForm <> Nil then
    Result := DockForm.ClassName;
end;

(**

  This function returns the top line of the editor view.

  @precon  None.
  @postcon The top line of the edit view is returned.

  @nocheck MissingCONSTInParam

  @param   EditView as an IOTAEditView
  @return  an Integer

**)
function GetEditViewTopRow(EditView: IOTAEditView): Integer;
begin
  Result := 0;
  if EditView <> Nil then
    Result := EditView.TopRow;
end;

(**

  This function returns the Form Caption of the Editor window.

  @precon  None.
  @postcon The Form Caption of thr editor form is returned.

  @nocheck MissingCONSTInParam

  @param   EditWindow as an INTAEditWindow
  @return  a String

**)
function GetEditWindowFormCaption(EditWindow: INTAEditWindow): string;
begin
  Result := strNoEditWindow;
  if EditWindow <> Nil then
  begin
    Result := strNoForm;
    if EditWindow.Form <> Nil then
      Result := ExtractFileName(EditWindow.Form.Caption);
  end;
end;

(**

  This function returns the Form ClassName of the Editor window.

  @precon  None.
  @postcon The Form ClassName of thr editor form is returned.

  @nocheck MissingCONSTInParam

  @param   EditWindow as an INTAEditWindow
  @return  a String

**)
function GetEditWindowFormClassName(EditWindow: INTAEditWindow): string;
begin
  Result := strNoEditWindow;
  if EditWindow <> Nil then
  begin
    Result := strNoForm;
    if EditWindow.Form <> Nil then
      Result := EditWindow.Form.ClassName;
  end;
end;

{ TDGHNotificationsEditorNotifier }

(**

  This method is called when a IDE is being shutdown for each dockable form.

  @precon  None.
  @postcon Provides access to the editor window and dockable form.

  @nocheck MissingCONSTInParam

  @param   EditWindow as an INTAEditWindow as a constant
  @param   DockForm   as a TDockableForm

**)
procedure TDGHNotificationsEditorNotifier.DockFormRefresh(const EditWindow: INTAEditWindow; DockForm: TDockableForm);
resourcestring
  strDockFormRefresh = '.DockFormRefresh = EditWindow: %s.%s, DockForm: %s.%s';
begin
  DoNotification(Format(strDockFormRefresh, [GetEditWindowFormClassName(EditWindow), GetEditWindowFormCaption(EditWindow), GetDockFormClassName(DockForm), GetDockFormCaption(DockForm)]));
end;

(**

  This method is called when a dockable form is docked with an editor window.

  @precon  None.
  @postcon Provides access to the dockable form and the editor window.

  @nocheck MissingCONSTInParam

  @param   EditWindow as an INTAEditWindow as a constant
  @param   DockForm   as a TDockableForm

**)
procedure TDGHNotificationsEditorNotifier.DockFormUpdated(const EditWindow: INTAEditWindow; DockForm: TDockableForm);
resourcestring
  strDockFormUpdated = '.DockFormUpdated = EditWindow: %s.%s, DockForm: %s.%s';
begin
  DoNotification(Format(strDockFormUpdated, [GetEditWindowFormClassName(EditWindow), GetEditWindowFormCaption(EditWindow), GetDockFormClassName(DockForm), GetDockFormCaption(DockForm)]));
end;

(**

  This method is called whn dockable forms are loaded by the desktop.

  @precon  None.
  @postcon Provides access to the edit window and dickable form.

  @nocheck MissingCONSTInParam

  @param   EditWindow as an INTAEditWindow as a constant
  @param   DockForm   as a TDockableForm

**)
procedure TDGHNotificationsEditorNotifier.DockFormVisibleChanged(const EditWindow: INTAEditWindow; DockForm: TDockableForm);
resourcestring
  strDockFormVisibleChanged = '.DockFormVisibleChanged = EditWindow: %s.%s, DockForm: %s.%s';
begin
  DoNotification(Format(strDockFormVisibleChanged, [GetEditWindowFormClassName(EditWindow), GetEditWindowFormCaption(EditWindow), GetDockFormClassName(DockForm), GetDockFormCaption(DockForm)]));
end;

(**

  This method is fired each time an editor tab is made active via changing tabs or opening
  a new file.

  @precon  None.
  @postcon Provides access tot the editor window and the editor view.

  @param   EditWindow as an INTAEditWindow as a constant
  @param   EditView   as an IOTAEditView as a constant

**)
procedure TDGHNotificationsEditorNotifier.EditorViewActivated(const EditWindow: INTAEditWindow; const EditView: IOTAEditView);
resourcestring
  strEditorViewActivated = '.EditorViewActivated = EditWindow: %s.%s, EditView.TopRow: %d';
begin
  DoNotification(Format(strEditorViewActivated, [GetEditWindowFormClassName(EditWindow), GetEditWindowFormCaption(EditWindow), GetEditViewTopRow(EditView)]));
end;

(**

  This method is called each time the editor text is changed.

  @precon  None.
  @postcon Provides access to the editor window and editor view.

  @param   EditWindow as an INTAEditWindow as a constant
  @param   EditView   as an IOTAEditView as a constant

**)
procedure TDGHNotificationsEditorNotifier.EditorViewModified(const EditWindow: INTAEditWindow; const EditView: IOTAEditView);
resourcestring
  strEditorViewModified = '.EditorViewModified = EditWindow: %s.%s, EditView.TopRow: %d';
begin
  DoNotification(Format(strEditorViewModified, [GetEditWindowFormClassName(EditWindow), GetEditWindowFormCaption(EditWindow), GetEditViewTopRow(EditView)]));
end;

(**

  This method is called when the editor display the page.

  @precon  None.
  @postcon Provides access to the editor view.

  @param   View as an IOTAEditView as a constant

**)
procedure TDGHNotificationsEditorNotifier.ViewActivated(const View: IOTAEditView);
resourcestring
  strViewActiviated = '.ViewActiviated = View.TopRow: %d';
begin
  DoNotification(Format(strViewActiviated, [GetEditViewTopRow(View)]));
end;

(**

  This method is called for the opening and closing of editor files.

  @precon  None.
  @postcon Provide access to the edit view and the operation (Insert or Remove).

  @nocheck MissingCONSTInParam

  @param   View      as an IOTAEditView as a constant
  @param   Operation as a TOperation

**)
procedure TDGHNotificationsEditorNotifier.ViewNotification(const View: IOTAEditView; Operation: TOperation);
resourcestring
  strViewNotification = '.ViewNotification = View.TopRow: %d, Operation: %s';
begin
  DoNotification(Format(strViewNotification, [GetEditViewTopRow(View), GetEnumName(TypeInfo(TOperation), Ord(Operation))]));
end;

(**

  This method doesn`t seem to be called.

  @precon  None.
  @postcon Provides access to the edit window.

  @param   EditWindow as an INTAEditWindow as a constant

**)
procedure TDGHNotificationsEditorNotifier.WindowActivated(const EditWindow: INTAEditWindow);
resourcestring
  strWindowActiviated = '.WindowActiviated = EditWindow: %s.%s';
begin
  DoNotification(Format(strWindowActiviated, [GetEditWindowFormClassName(EditWindow), GetEditWindowFormCaption(EditWindow)]));
end;

(**

  This method is called for editor commands.

  @precon  None.
  @postcon Provides access to the edit window, command and parameters. I think you can intercept
           commands here and return True in Handled to prevent the origin command processing.

  @nocheck MissingCONSTInParam

  @param   EditWindow as an INTAEditWindow as a constant
  @param   Command    as an Integer
  @param   Param      as an Integer
  @param   Handled    as a Boolean as a reference

**)
procedure TDGHNotificationsEditorNotifier.WindowCommand(const EditWindow: INTAEditWindow; Command, Param: Integer; var Handled: Boolean);
resourcestring
  strWindowCommand = '.WindowCommand = EditWindow: %s.%s, Command: %d, Param: %d, Handled: %s';
begin
  DoNotification(Format(strWindowCommand, [GetEditWindowFormClassName(EditWindow), GetEditWindowFormCaption(EditWindow), Command, Param, strBoolean[Handled]]));
end;

(**

  This method is called for each editor window opened and closed.

  @precon  None.
  @postcon Provides access to the editor window and the operation (Insert or Remove).

  @nocheck MissingCONSTInParam

  @param   EditWindow as an INTAEditWindow as a constant
  @param   Operation  as a TOperation

**)
procedure TDGHNotificationsEditorNotifier.WindowNotification(const EditWindow: INTAEditWindow; Operation: TOperation);
resourcestring
  strWindowNotification = '.WindowNotification = EditWindow: %s.%s, Operation: %s';
begin
  DoNotification(Format(strWindowNotification, [GetEditWindowFormClassName(EditWindow), GetEditWindowFormCaption(EditWindow), GetEnumName(TypeInfo(TOperation), Ord(Operation))]));
end;

(**

  This method is called each time an editor window appears or disappears.

  @precon  None.
  @postcon Provides access to the editor window, whether it shown and whether its due to a desktop
           change.

  @nocheck MissingCONSTInParam

  @param   EditWindow        as an INTAEditWindow as a constant
  @param   Show              as a Boolean
  @param   LoadedFromDesktop as a Boolean

**)
procedure TDGHNotificationsEditorNotifier.WindowShow(const EditWindow: INTAEditWindow; Show, LoadedFromDesktop: Boolean);
resourcestring
  strWindowShow = '.WindowShow = EditWindow: %s.%s, Show: %s, LoadedFromDesktop: %s';
begin
  DoNotification(Format(strWindowShow, [GetEditWindowFormClassName(EditWindow), GetEditWindowFormCaption(EditWindow), strBoolean[Show], strBoolean[LoadedFromDesktop]]));
end;

end.

