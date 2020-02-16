(**

  This module contains a class which implements the IOTAMessageNotififer and INTAMessageNotifier
  interfaces to demonstrate how to capture events associated with the creationa dn destruction of
  message groups and add context menus to custom messages in the RAD Studio IDE.

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
unit DGHIDENotifiers.MessageNotifier;

interface

uses
  ToolsAPI,
  DGHIDENotifiers.Types,
  Menus;

type
  (** This class implements notifiers for capturing Message information. **)
  TDGHIDENotificationsMessageNotifier = class(TDGHNotifierObject, IOTAMessageNotifier, INTAMessageNotifier)
  strict private
  strict protected
  public
    // IOTAMessageNotifier
    procedure MessageGroupAdded(const Group: IOTAMessageGroup);
    procedure MessageGroupDeleted(const Group: IOTAMessageGroup);
    // INTAMessageNotifier
    procedure MessageViewMenuShown(Menu: TPopupMenu; const MessageGroup: IOTAMessageGroup; LineRef: Pointer);
  end;

implementation

uses
  SysUtils;

(**

  This function returns the message group name.

  @precon  None.
  @postcon The message group name is returned.

  @nocheck MissingCONSTInParam

  @param   Group as an IOTAMessageGroup
  @return  a String

**)
function GetMessageGroupName(Group: IOTAMessageGroup): string;
resourcestring
  strNoGroup = '(no group)';
begin
  Result := strNoGroup;
  if Group <> Nil then
    Result := Group.Name;
end;

{ TDGHIDENotificationsMessageNotifier }

(**

  This method is called when a messahge group is added to the message view window.

  @precon  None.
  @postcon Provides access to the message group.

  @param   Group as an IOTAMessageGroup as a constant

**)
procedure TDGHIDENotificationsMessageNotifier.MessageGroupAdded(const Group: IOTAMessageGroup);
resourcestring
  strMessageGroupAdded = '.MessageGroupAdded = Group: %s';
begin
  DoNotification(Format(strMessageGroupAdded, [GetMessageGroupName(Group)]));
end;

(**

  This method is called when a message group is deleted from the message view window.

  @precon  None.
  @postcon Provides access to the message group.

  @param   Group as an IOTAMessageGroup as a constant

**)
procedure TDGHIDENotificationsMessageNotifier.MessageGroupDeleted(const Group: IOTAMessageGroup);
resourcestring
  strMessageGroupDeleted = '.MessageGroupDeleted = Group: %s';
begin
  DoNotification(Format(strMessageGroupDeleted, [GetMessageGroupName(Group)]));
end;

(**

  This method is called when the user right clicks on a message.

  @precon  None.
  @postcon provides access to the pop menu to be displayed so that you can add items and the
           message group.

  @nocheck MissingCONSTInParam

  @param   Menu         as a TPopupMenu
  @param   MessageGroup as an IOTAMessageGroup as a constant
  @param   LineRef      as a Pointer

**)
procedure TDGHIDENotificationsMessageNotifier.MessageViewMenuShown(Menu: TPopupMenu; const MessageGroup: IOTAMessageGroup; LineRef: Pointer);
resourcestring
  strMessageViewMenuShown = '.MessageViewMenuShown = Menu: %s, MessageGroup: %s, LineRef: %p';
begin
  DoNotification(Format(strMessageViewMenuShown, [Menu.Name, GetMessageGroupName(MessageGroup), LineRef]));
end;

end.

