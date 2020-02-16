(**

  This module contains an IDE wizard which implements IOTAWizard and IOTAMenuWizard to create a
  RAD Studio IDE expert / plug-in to log notifications from various aspects of the IDE.

  The wizard is responsible for the life time management of all other objects in this plugin (except
  the dockable form) and installs the notifiers on creation and remoces them on destruction.

  The following notifiers are currently implemented:
   * IOTAIDENotifier                via IOTAIDEServices.AddNotifier();
   * IOTAVersionControlNotifier     via IOTAVersionControlServices.AddNotifier();
   * IOTACompileNotifier            via IOTACompileServices.AddNotifier();
   * IOTAIDEInsightNotifier         via IOTAIDEInsightService.AddNotifier();
   * IOTAMessageNotifier            via IOTAMessageServices60.AddNotifier();
   * IOTAProjectFileStorageNotifier via IOTAProjectFileStorage.AddNotifier();
   * IOTAEditorNotifier             via IOTAEditorServices.AddNotifier();
   * INTAEditServicesNotifier       via IOTAEditorServices.AddNotifier();
   * IOTADebuggerNotifier           via IOTADebuggerServices60.AddNotifier();
   * IOTADebuggerNotifier90         via IOTADebuggerServices60.AddNotifier();
   * IOTADebuggerNotifier100        via IOTADebuggerServices60.AddNotifier();
   * IOTADebuggerNotifier110        via IOTADebuggerServices60.AddNotifier();
   * IOTAModuleNotifier             via IOTAModule40.AddNotifier();
   * IOTAModuleNotifier80           via IOTAModule40.AddNotifier();
   * IOTAModuleNotifier90           via IOTAModule40.AddNotifier();
   * IOTAProjectNotifier            via IOTAModule40.AddNotifier();
   * IOTAProjectBuilderNotifier     via IOTAProjectBuilder.AddCompileNotifier();
   * IOTAEditorNotifier             via IOTASourceEditor.AddNotifier()
   * IOTAFormNotifier               via IOTAFormEditor.AddNotifier()
   * INTAEditViewNotifier           via IOTAEditView.AddNotifier()

  The following notifiers are STILL to be implemented:
   * IOTAToolsFilter.AddNotifier(IOTANotifier)... IOTAToolsFilterNotifier = interface(IOTANotifier)
   * IOTAEditBlock.AddNotifier(IOTASyncEditNotifier)
   * IOTAEditLineTracker.AddNotifier(IOTAEditLineNotifier)
   * IOTAEditBlock, IOTASyncEditNotifier = interface
   * IOTABreakpoint40.AddNotifier(IOTABreakpointNotifier)
   * IOTAThread50.AddNotifier(IOTAThreadNotifier, IOTAThreadNotifier160)
   * IOTAProcessModule80.AddNotifier(IOTAProcessModNotifier)
   * IOTAProcess60.AddNotifier(IOTAProcessNotifier, IOTAProcessNotifier90)
   * IOTAToDoServices.AddNotifier(IOTAToDoManager)
   * IOTADesignerCommandNotifier = interface(IOTANotifier)
   * IOTAProjectMenuItemCreatorNotifier = interface(IOTANotifier)

  @Author  David Hoyle
  @Version 1.063
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
unit DGHIDENotifiers.Wizard;

interface

uses
  ToolsAPI,
  Graphics,
  DGHIDENotifiers.Types;

{$INCLUDE CompilerDefinitions.inc}
{$R DGHIDENotITHVerInfo.RES ..\DGHIDENotITHVerInfo.RC}

type
  (** This class implement the plugins wizard. **)
  TDGHIDENotifiersWizard = class(TDGHNotifierObject, IOTAWizard, IOTAMenuWizard)
  strict private
    FIDENotifier: Integer;
    {$IFDEF D2010}
    FVersionControlNotifier: Integer;
    FCompileNotifier: Integer;
    FIDEInsightNotifier: Integer;
    {$ENDIF}
    FMessageNotfier: Integer;
    FProjectFileStorageNotifier: Integer;
    FEditorNotifier: Integer;
    FDebuggerNotifier: integer;
  strict protected
  public
    constructor Create(const strNotifier, strFileName: string; const iNotification: TDGHIDENotification); override;
    destructor Destroy; override;
    // IOTAWizard
    procedure Execute;
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;
    // IOTAMenuWizard
    function GetMenuText: string;
  end;

implementation

uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  SysUtils,
  TypInfo,
  DGHIDENotifiers.DockableIDENotificationsForm,
  DGHIDENotifiers.IDENotifier,
  {$IFDEF D2010}
  DGHIDENotifiers.VersionControlNotifier,
  DGHIDENotifiers.CompileNotifier,
  DGHIDENotifiers.IDEInsightNotifier,
  {$ENDIF}
  DGHIDENotifiers.MessageNotifier,
  DGHIDENotifiers.ProjectStorageNotifier,
  DGHIDENotifiers.EditorNotifier,
  DGHIDENotifiers.DebuggerNotifier,
  DGHIDENotifiers.SplashScreen,
  DGHIDENotifiers.AboutBox;

(**

  A constructor for the TDGHIDENotifierWizard class.

  @precon  None.
  @postcon Installs all the notifiers.

  @param   strNotifier   as a String as a constant
  @param   strFileName   as a String as a constant
  @param   iNotification as a TDGHIDENotification as a constant

**)
constructor TDGHIDENotifiersWizard.Create(const strNotifier, strFileName: string; const iNotification: TDGHIDENotification);
const
  strIOTAIDENotifier = 'IOTAIDENotifier';
  strIOTAVersionControlNotifier = 'IOTAVersionControlNotifier';
  strIOTACompileNotifier = 'IOTACompileNotifier';
  strIOTAIDEInsightNotifier = 'IOTAIDEInsightNotifier';
  strIOTAMessageNotifier = 'IOTAMessageNotifier';
  strIOTAProjectFileStorageNotifier = 'IOTAProjectFileStorageNotifier';
  strINTAEditorServicesNotifier = 'INTAEditorServicesNotifier';
  strIOTADebuggerNotifier = 'IOTADebuggerNotifier';
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod(Self, 'Create', tmoTiming); {$ENDIF}
  inherited Create(strNotifier, strFileName, iNotification);
  AddSplashScreen;
  AddAboutBoxEntry;
  FIDENotifier := (BorlandIDEServices as IOTAServices).AddNotifier(TDGHNotificationsIDENotifier.Create(strIOTAIDENotifier, '', dinIDENotifier));
  {$IFDEF D2010}
  FVersionControlNotifier := (BorlandIDEServices as IOTAVersionControlServices).AddNotifier(TDGHIDENotificationsVersionControlNotifier.Create(strIOTAVersionControlNotifier, '', dinVersionControlNotifier));
  FCompileNotifier := (BorlandIDEServices as IOTACompileServices).AddNotifier(TDGHIDENotificationsCompileNotifier.Create(strIOTACompileNotifier, '', dinCompileNotifier));
  FIDEInsightNotifier := (BorlandIDEServices as IOTAIDEInsightService).AddNotifier(TDGHIDENotificationsIDEInsightNotifier.Create(strIOTAIDEInsightNotifier, '', dinIDEInsightNotifier));
  {$ENDIF}
  FMessageNotfier := (BorlandIDEServices as IOTAMessageServices).AddNotifier(TDGHIDENotificationsMessageNotifier.Create(strIOTAMessageNotifier, '', dinMessageNotifier));
  FProjectFileStorageNotifier := (BorlandIDEServices as IOTAProjectFileStorage).AddNotifier(TDGHNotificationsProjectFileStorageNotifier.Create(strIOTAProjectFileStorageNotifier, '', dinProjectFileStorageNotifier));
  FEditorNotifier := (BorlandIDEServices as IOTAEditorServices).AddNotifier(TDGHNotificationsEditorNotifier.Create(strINTAEditorServicesNotifier, '', dinEditorNotifier));
  FDebuggerNotifier := (BorlandIDEServices as IOTADebuggerServices).AddNotifier(TDGHNotificationsDebuggerNotifier.Create(strIOTADebuggerNotifier, '', dinDebuggerNotifier));
  TfrmDockableIDENotifications.CreateDockableBrowser;
end;

(**

  A destructor for the TDGHIDENotifiersWizard class.

  @precon  None.
  @postcon Removes all the notifiers.

**)
destructor TDGHIDENotifiersWizard.Destroy;
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod(Self, 'Destroy', tmoTiming); {$ENDIF}
  if FIDENotifier > -1 then
    (BorlandIDEServices as IOTAServices).RemoveNotifier(FIDENotifier);
  {$IFDEF D2010}
  if FVersionControlNotifier > -1 then
    (BorlandIDEServices as IOTAVersionControlServices).RemoveNotifier(FVersionControlNotifier);
  if FCompileNotifier > -1 then
    (BorlandIDEServices as IOTACompileServices).RemoveNotifier(FCompileNotifier);
  if FIDEInsightNotifier > -1 then
    (BorlandIDEServices as IOTAIDEInsightService).RemoveNotifier(FIDEInsightNotifier);
  {$ENDIF}
  if FMessageNotfier > -1 then
    (BorlandIDEServices as IOTAMessageServices).RemoveNotifier(FMessageNotfier);
  if FProjectFileStorageNotifier > -1 then
    (BorlandIDEServices as IOTAProjectFileStorage).RemoveNotifier(FProjectFileStorageNotifier);
  if FEditorNotifier > -1 then
    (BorlandIDEServices as IOTAEditorServices).RemoveNotifier(FEditorNotifier);
  if FDebuggerNotifier > -1 then
    (BorlandIDEServices as IOTADebuggerServices).RemoveNotifier(FDebuggerNotifier);
  RemoveAboutBoxEntry;
  TfrmDockableIDENotifications.RemoveDockableBrowser;
  inherited Destroy;
end;

(**

  This method is invoked when the menu under the help menu is.

  @precon  None.
  @postcon Displays the notifier dockable form.

**)
procedure TDGHIDENotifiersWizard.Execute;
const
  strIOTAWizardExecute = 'IOTAWizard.Execute';
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod(Self, 'Execute', tmoTiming); {$ENDIF}
  DoNotification(strIOTAWizardExecute);
  TfrmDockableIDENotifications.ShowDockableBrowser;
end;

(**

  This is a getter method for the IDstring property.

  @precon  None.
  @postcon Returns a unique string for the plugin wizard.

  @return  a String

**)
function TDGHIDENotifiersWizard.GetIDString: string;
resourcestring
  strIOTAWizardGetIDStringResult = 'IOTAWizard.GetIDString = Result: %s';
const
  strDGHIDENotifiersDavidHoyle = 'DGHIDENotifiers.David Hoyle';
begin
  Result := strDGHIDENotifiersDavidHoyle;
  DoNotification(Format(strIOTAWizardGetIDStringResult, [Result]));
end;

(**

  This is a getter method for the MenuText property.

  @precon  None.
  @postcon Returns the menu text for the menu created under the help menu.

  @return  a String

**)
function TDGHIDENotifiersWizard.GetMenuText: string;
resourcestring
  strIDENotifiers = 'IDE Notifiers';
  strIOTAMenuWizardGetMenuTextResult = 'IOTAMenuWizard.GetMenuText = Result: %s';
begin
  Result := strIDENotifiers;
  DoNotification(Format(strIOTAMenuWizardGetMenuTextResult, [Result]));
end;

(**

  This is a getter method for the Name property.

  @precon  None.
  @postcon Returns the name of the wizard.

  @return  a String

**)
function TDGHIDENotifiersWizard.GetName: string;
resourcestring
  strIOTAWizardGetNameResult = 'IOTAWizard.GetName = Result: %s';
const
  strDGHIDENotifiers = 'DGHIDENotifiers';
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod(Self, 'GetName', tmoTiming); {$ENDIF}
  Result := strDGHIDENotifiers;
  DoNotification(Format(strIOTAWizardGetNameResult, [Result]));
end;

(**

  This is a getter method for the State property.

  @precon  None.
  @postcon Returns an enabled state for the wizard.

  @return  a TWizardState

**)
function TDGHIDENotifiersWizard.GetState: TWizardState;
resourcestring
  strIOTAWizardGetStateResultWsEnabled = 'IOTAWizard.GetState = Result: [wsEnabled]';
begin
  Result := [wsEnabled];
  DoNotification(strIOTAWizardGetStateResultWsEnabled);
end;

end.

