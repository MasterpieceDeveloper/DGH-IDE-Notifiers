 (**

  This module contains a dockable IDE window for logging all the notifications from this wizard /
  expert / plug-in which are generated RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.049
  @date    09 Feb 2020

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
unit DGHIDENotifiers.DockableIDENotificationsForm;

interface

{$INCLUDE 'CompilerDefinitions.inc'}

{$IFDEF DXE00}
{$DEFINE REGULAREXPRESSIONS}
{$ENDIF}

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  OleCtrls,
  DockForm,
  StdCtrls,
  Buttons,
  ToolWin,
  ComCtrls,
  ActnList,
  ImgList,
  DGHIDENotifiers.Types,
  VirtualTrees,
  {$IFDEF REGULAREXPRESSIONS}
  RegularExpressions,
  {$ENDIF}
  Generics.Collections,
  ExtCtrls,
  Themes,
  DGHIDENotifiers.Interfaces, System.Actions, System.ImageList;

type
  (** This record describes the message information to be stored. **)
  TMsgNotification = record
  strict private
    //: @nohints - Workaround for BaDI bug
    FDateTime: TDateTime;
    //: @nohints - Workaround for BaDI bug
    FMessage: string;
    //: @nohints - Workaround for BaDI bug
    FNotificationType: TDGHIDENotification;
  public
    constructor Create(const dtDateTime: TDateTime; const strMsg: string; const eNotificationType: TDGHIDENotification);
    (**
      This property returns the date and time of the messages.
      @precon  None.
      @postcon Returns the date and time of the messages.
      @return  a TDateTime
    **)
    property DateTime: TDateTime read FDateTime;
    (**
      This property returns the text of the messages.
      @precon  None.
      @postcon Returns the text of the messages.
      @return  a String
    **)
    property Message: string read FMessage;
    (**
      This property returns the type of the messages.
      @precon  None.
      @postcon Returns the type of the messages.
      @return  a TDGHIDENotification
    **)
    property NotificationType: TDGHIDENotification read FNotificationType;
  end;

  (** This class presents a dockable form for the RAD Studio IDE. **)
  TfrmDockableIDENotifications = class(TDockableForm)
    tbrMessageFilter: TToolBar;
    ilButtons: TImageList;
    alButtons: TActionList;
    tbtnCapture: TToolButton;
    tbtnSep1: TToolButton;
    actCapture: TAction;
    tbtnClear: TToolButton;
    actClear: TAction;
    stbStatusBar: TStatusBar;
    pnlTop: TPanel;
    pnlRetention: TPanel;
    lblLogRetention: TLabel;
    edtLogRetention: TEdit;
    udLogRetention: TUpDown;
    LogView: TVirtualStringTree;
    btnAbout: TToolButton;
    actAbout: TAction;
    procedure actAboutExecute(Sender: TObject);
    procedure actCaptureExecute(Sender: TObject);
    procedure actCaptureUpdate(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure LogViewGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure LogViewGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex);
    procedure LogViewAfterCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; CellRect: TRect);
    procedure LogViewKeyPress(Sender: TObject; var Key: Char);
  strict private
    FMessageList: TList<TMsgNotification>;
    FMessageFilter: TDGHIDENotifications;
    FCapture: Boolean;
    FLogFileName: string;
    FRegExFilter: string;
    FIsFiltering: Boolean;
    {$IFDEF REGULAREXPRESSIONS}
    FRegExEng: TRegEx;
    {$ENDIF}
    FLastUpdate: UInt64;
    FUpdateTimer: TTimer;
    {$IFDEF DXE102}
    FStyleServices: TCustomStyleServices;
    {$ENDIF DXE102}
    FIDEEditorColours: IDNIDEEditorColours;
    FIDEEditorTokenInfo: TDNTokenFontInfoTokenSet;
    FBackgroundColour: TColor;
  strict protected
    procedure CreateFilterButtons;
    procedure ActionExecute(Sender: TObject);
    procedure ActionUpdate(Sender: TObject);
    procedure LoadSettings;
    procedure SaveSettings;
    function AddViewItem(const iMsgNotiticationIndex: Integer): PVirtualNode;
    function ConstructorLogFileName: string;
    procedure LoadLogFile;
    procedure SaveLogFile;
    procedure FilterMessages;
    procedure UpdateTimer(Sender: TObject);
    procedure RetreiveIDEEditorColours;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class procedure RemoveDockableBrowser;
    class procedure CreateDockableBrowser;
    class procedure ShowDockableBrowser;
    class procedure AddNotification(const iNotification: TDGHIDENotification; const strMessage: string);
    (**
      This property gets and set the number of days to retain log entries.
      @precon  None.
      @postcon Gets and set the number of days to retain log entries.
      @return  an Integer
    **)
  end;

  (** This is a class references for the dockable form which is required by some of the OTA
      methods. **)
  TfrmDockableIDENotificationsClass = class of TfrmDockableIDENotifications;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  DeskUtil,
  Registry,
  ShlObj,
  {$IFNDEF D2010}
  SHFolder,
  {$ENDIF}
  DGHIDENotifiers.MessageTokens,
  ToolsAPI,
  StrUtils,
  {$IFDEF REGULAREXPRESSIONS}
  RegularExpressionsCore,
  {$ENDIF}
  Types,
  DGHIDENotifiers.IDEEditorColours,
  DGHIDENotifiers.AboutDlg;

type
  (** A tree node record which contains the index of the message to display. **)
  TTreeNodeData = record
    FNotificationIndex: Integer;
  end;
  (** A pointer to the above structure. **)

  PTreeNodeData = ^TTreeNodeData;
  (** A type to define an array of strings. **)

  TDGHArrayOfString = array of string;

const
  (** Treeview margin. **)
  iMargin = 4;
  (** Treeview spacing. **)
  iSpace = 4;
  (** This is the timer update interval in milliseconds. **)
  iUpdateInterval = 250;
  (** A Registry root for the plug-in settings. **)
  strRegKeyRoot = 'Software\Season''s Fall\DGHIDENotifications';
  (** An Registry Section name for the general settings. **)
  strINISection = 'Setup';
  (** A registry key for whether the plug-in is capturing events. **)
  strCaptureKey = 'Capture';
  (** A registry key for which notifications are captured. **)
  strNotificationsKey = 'Notifications';
  (** A registry key for notification retention. **)
  strRetensionPeriodInDaysKey = 'RetensionPeriodInDays';
  (** A Registry section for the log column widths **)
  strLogViewINISection = 'LogView';
  (** A registry key for for the date time width. **)
  strDateTimeWidthKey = 'DateTimeWidth';
  (** A registry key for for the message width. **)
  strMessageWidthKey = 'MessageWidth';

var
  (** This is a private reference for the form to implement a singleton pattern. **)
  FormInstance: TfrmDockableIDENotifications;

procedure RegisterDockableForm(const FormClass: TfrmDockableIDENotificationsClass; var FormVar; const FormName: string); forward;

procedure UnRegisterDockableForm(var FormVar; const FormName: string); forward;

(**

  This method creates an instance of the dockable form and registers it with the IDE.

  @precon  FormVar must be a valid reference.
  @postcon The dockable form is created and registered with the IDE.

  @param   FormVar   as a TfrmDockableIDENotifications as a reference
  @param   FormClass as a TfrmDockableIDENotificationsClass as a constant

**)
procedure CreateDockableForm(var FormVar: TfrmDockableIDENotifications; const FormClass: TfrmDockableIDENotificationsClass);
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod('CreateDockableForm', tmoTiming); {$ENDIF}
  TCustomForm(FormVar) := FormClass.Create(Nil);
  RegisterDockableForm(FormClass, FormVar, TCustomForm(FormVar).Name);
end;

(**

  This function returns the first position of the delimiter character in the given string on or
  after the starting point.

  @precon  None.
  @postcon Returns the position of the firrst delimiter after the starting point.

  @note    Used to workaround backward compatability issues with String.Split and StringSplit.

  @param   cDelimiter as a Char as a constant
  @param   strText    as a String as a constant
  @param   iStartPos  as an Integer as a constant
  @return  an Integer

**)
function DGHPos(const cDelimiter: Char; const strText: string; const iStartPos: Integer): Integer;
var
  I: Integer;
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod('DGHPos', tmoTiming); {$ENDIF}
  Result := 0;
  for I := iStartPos to Length(strText) do
    if strText[I] = cDelimiter then
    begin
      Result := I;
      Break;
    end;
end;

(**

  This function splits a string into an array of strings based on the given delimiter character.

  @precon  None.
  @postcon Splits the given string by the delimmiters and returns an array of strings.

  @note    Used to workaround backward compatability issues with String.Split and StringSplit.

  @param   strText    as a String as a constant
  @param   cDelimiter as a Char as a constant
  @return  a TDGHArrayOfString

**)
function DGHSplit(const strText: string; const cDelimiter: Char): TDGHArrayOfString;
var
  iSplits: Integer;
  i: Integer;
  iStart, iEnd: Integer;
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod('DGHSplit', tmoTiming); {$ENDIF}
  iSplits := 0;
  for i := 1 to Length(strText) do
    if strText[i] = cDelimiter then
      Inc(iSplits);
  SetLength(Result, Succ(iSplits));
  i := 0;
  iStart := 1;
  while DGHPos(cDelimiter, strText, iStart) > 0 do
  begin
    iEnd := DGHPos(cDelimiter, strText, iStart);
    Result[i] := Copy(strText, iStart, iEnd - iStart);
    Inc(i);
    iStart := iEnd + 1;
  end;
  Result[i] := Copy(strText, iStart, Length(strText) - iStart + 1);
end;

(**

  This method unregisters the dockable form from the IDE and frees its instance.

  @precon  FormVar must be a valid reference.
  @postcon The form is unregistered from the IDE and freed.

  @param   FormVar as a TfrmDockableIDENotifications as a reference

**)
procedure FreeDockableForm(var FormVar: TfrmDockableIDENotifications);
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod('FreeDockableForm', tmoTiming); {$ENDIF}
  if Assigned(FormVar) then
  begin
    UnRegisterDockableForm(FormVar, FormVar.Name);
    FreeAndNil(FormVar);
  end;
end;

(**

  This method registers the dockable form with the IDE.

  @precon  FormVar must be a valid reference.
  @postcon The dockable form is registered with the IDE.

  @param   FormClass as a TfrmDockableIDENotificationsClass as a constant
  @param   FormVar   as   @param   FormName  as a String as a constant

**)
procedure RegisterDockableForm(const FormClass: TfrmDockableIDENotificationsClass; var FormVar; const FormName: string);
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod('RegisterDockableForm', tmoTiming); {$ENDIF}
  if @RegisterFieldAddress <> Nil then
    RegisterFieldAddress(FormName, @FormVar);
  RegisterDesktopFormClass(FormClass, FormName, FormName);
end;

(**

  This method shows the form if it has been created.

  @precon  None.
  @postcon The form is displayed.

  @param   Form as a TfrmDockableIDENotifications as a constant

**)
procedure ShowDockableForm(const Form: TfrmDockableIDENotifications);
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod('ShowDockableForm', tmoTiming); {$ENDIF}
  if not Assigned(Form) then
    Exit;
  if not Form.Floating then
  begin
    Form.ForceShow;
    FocusWindow(Form);
    Form.SetFocus;
  end
  else
  begin
    Form.Show;
    Form.SetFocus;
  end;
end;

(**

  This method unregisters the dockable for from the IDE.

  @precon  FormVar must be a valid reference.
  @postcon The dockable form is unregistered from the IDE.

  @nohint  FormName

  @param   FormVar  as   @param   FormName as a String as a constant

**)
procedure UnRegisterDockableForm(var FormVar; const FormName: string); //FI:O804

begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod('UnRegisterDockableForm', tmoTiming); {$ENDIF}
  if @UnRegisterFieldAddress <> Nil then
    UnRegisterFieldAddress(@FormVar);
end;

(**

  This is an on execute event handler for the About action.

  @precon  None.
  @postcon Displays the about dialogue.

  @param   Sender as a TObject

**)
procedure TfrmDockableIDENotifications.actAboutExecute(Sender: TObject);
begin
  TfrmDINAboutDlg.Execute;
end;

(**

  This is an on execute event handler for the Capture action.

  @precon  None.
  @postcon Toggles the action.

  @param   Sender as a TObject

**)
procedure TfrmDockableIDENotifications.actCaptureExecute(Sender: TObject);
begin
  FCapture := not FCapture;
end;

(**

  This is an on update event handler for the Capture action.

  @precon  None.
  @postcon Sets the checked property of the capture action.

  @param   Sender as a TObject

**)
procedure TfrmDockableIDENotifications.actCaptureUpdate(Sender: TObject);
begin
  if Sender is TAction then
    (Sender as TAction).Checked := FCapture;
end;

(**

  This is an on execute event handler for the Clear action.

  @precon  None.
  @postcon Clears the list of notifications.

  @param   Sender as a TObject

**)
procedure TfrmDockableIDENotifications.actClearExecute(Sender: TObject);
begin
  FMessageList.Clear;
  LogView.Clear;
end;

(**

  This is an on execute event handler for all the notification action.

  @precon  None.
  @postcon Updates the filter for the view of the notifications and rebuilds the list.

  @param   Sender as a TObject

**)
procedure TfrmDockableIDENotifications.ActionExecute(Sender: TObject);
var
  A: TAction;
  iMessage: Integer;
  R: TMsgNotification;
  N: PVirtualNode;
begin
  if Sender is TAction then
  begin
    A := Sender as TAction;
    if TDGHIDENotification(A.Tag) in FMessageFilter then
      Exclude(FMessageFilter, TDGHIDENotification(A.Tag))
    else
      Include(FMessageFilter, TDGHIDENotification(A.Tag));
  end;
  N := Nil;
  FRegExFilter := '';
  FilterMessages;
  LogView.BeginUpdate;
  try
    LogView.Clear;
    for iMessage := 0 to FMessageList.Count - 1 do
    begin
      R := FMessageList[iMessage];
      if R.NotificationType in FMessageFilter then
        N := AddViewItem(iMessage);
    end;
  finally
    LogView.EndUpdate;
    if Assigned(N) then
    begin
      LogView.FocusedNode := N;
      LogView.Selected[N] := True;
    end;
  end;
end;

(**

  This is an on update event handler for all the notification action.

  @precon  None.
  @postcon Updates the check property of the notification based on whether the notification is in
           the filter.

  @param   Sender as a TObject

**)
procedure TfrmDockableIDENotifications.ActionUpdate(Sender: TObject);
var
  A: TAction;
begin
  if Sender is TAction then
  begin
    A := Sender as TAction;
    A.Checked := (TDGHIDENotification(A.Tag) in FMessageFilter);
  end;
end;

(**

  This method adds a notification to the forms listbox and underlying stored mechanism.

  @precon  None.
  @postcon A notification message is aded to the list if included in the filter else just stored
           internally.

  @param   iNotification as a TDGHIDENotification as a constant
  @param   strMessage    as a String as a constant

**)
class procedure TfrmDockableIDENotifications.AddNotification(const iNotification: TDGHIDENotification; const strMessage: string);
var
  dtDateTime: TDateTime;
  strMsg: string;
  iIndex: Integer;
begin
  if Assigned(FormInstance) and (FormInstance.FCapture) then
  begin
    dtDateTime := Now();
    strMsg := StringReplace(strMessage, #13#10, '\n', [rfReplaceAll]);
      // Add ALL message to the message list.
    if Assigned(FormInstance.FMessageList) then
    begin
      if FormInstance.FRegExFilter <> '' then
      begin
        FormInstance.FRegExFilter := '';
        FormInstance.FilterMessages;
      end;
      iIndex := FormInstance.FMessageList.Add(TMsgNotification.Create(dtDateTime, strMsg, iNotification));
          // Only add filtered messages to the listbox
      if iNotification in FormInstance.FMessageFilter then
        FormInstance.AddViewItem(iIndex);
    end;
  end;
end;

(**

  This method adds an item to the listbox.

  @precon  None.
  @postcon An item is added to the end of the list box.

  @param   iMsgNotiticationIndex as an Integer as a constant
  @return  a PVirtualNode

**)
function TfrmDockableIDENotifications.AddViewItem(const iMsgNotiticationIndex: Integer): PVirtualNode;
var
  NodeData: PTreeNodeData;
begin
  Result := LogView.AddChild(Nil);
  NodeData := LogView.GetNodeData(Result);
  NodeData.FNotificationIndex := iMsgNotiticationIndex;
  FLastUpdate := GetTickCount;
end;

(**

  This method returns the file name for the log file based on the location of the user profile and
  where Microsft state you should store your information.

  @precon  None.
  @postcon The filename for the log file is returned.

  @return  a String

**)
function TfrmDockableIDENotifications.ConstructorLogFileName: string;
const
  strSeasonsFall = '\Season''s Fall\';
  strLogExt = '.log';
var
  iSize: Integer;
  strBuffer: string;
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod('TfrmDockableIDENotifications.ConstructorLogFileName', tmoTiming); {$ENDIF}
  iSize := MAX_PATH;
  SetLength(Result, iSize);
  iSize := GetModuleFileName(HInstance, PChar(Result), iSize);
  SetLength(Result, iSize);
  SetLength(strBuffer, MAX_PATH);
  SHGetFolderPath(0, CSIDL_APPDATA or CSIDL_FLAG_CREATE, 0, SHGFP_TYPE_CURRENT, PChar(strBuffer));
  strBuffer := StrPas(PChar(strBuffer));
  strBuffer := strBuffer + strSeasonsFall;
  if not DirectoryExists(strBuffer) then
    ForceDirectories(strBuffer);
  Result := strBuffer + ChangeFileExt(ExtractFileName(Result), strLogExt);
end;

(**

  A constructor for the TfrmDockableIDENotifications class.

  @precon  AOwner must be a valid reference.
  @postcon Initialises the form and loads the settings.

  @nocheck MissingCONSTInParam

  @param   AOwner as a TComponent

**)
constructor TfrmDockableIDENotifications.Create(AOwner: TComponent);
const
  iPadding = 2;
  strTextHeightTest = 'Wg';

{$IFDEF DXE102}
var
  ITS: IOTAIDEThemingServices250;
{$ENDIF DXE102}

begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod('TfrmDockableIDENotifications.Create', tmoTiming); {$ENDIF}
  inherited Create(AOwner);
  DeskSection := Name;
  AutoSave := True;
  SaveStateNecessary := True;
  FIsFiltering := False;
  FCapture := True;
  FLastUpdate := 0;
  {$IFDEF DXE102}
  FStyleServices := Nil;
  {$ENDIF DXE102}
  LogView.NodeDataSize := SizeOf(TTreeNodeData);
  FMessageList := TList<TMsgNotification>.Create;
  FMessageFilter := [Low(TDGHIDENotification)..High(TDGHIDENotification)];
  CreateFilterButtons;
  FIDEEditorColours := TITHIDEEditorColours.Create;
  RetreiveIDEEditorColours;
  LogView.DefaultNodeHeight := iPadding + LogView.Canvas.TextHeight(strTextHeightTest) + iPadding;
  {$IFDEF DXE102}
  if Supports(BorlandIDEServices, IOTAIDEThemingServices250, ITS) then
  begin
    ITS.RegisterFormClass(TfrmDockableIDENotifications);
    ITS.ApplyTheme(Self);
    FStyleServices := ITS.StyleServices;
  end;
  {$ENDIF DXE102}
  LoadSettings;
  {$IFDEF CODESITE}  CodeSite.Enabled := False; {$ENDIF}
  LoadLogFile;
  {$IFDEF CODESITE}  CodeSite.Enabled := True; {$ENDIF}
  FUpdateTimer := TTimer.Create(Nil);
  FUpdateTimer.Interval := iUpdateInterval;
  FUpdateTimer.OnTimer := UpdateTimer;
end;

{ TMsgNotification }

(**

  This is a constructor for the TMsgNotification record.

  @precon  None.
  @postcon Initialises the record.

  @param   dtDateTime        as a TDateTime as a constant
  @param   strMsg            as a String as a constant
  @param   eNotificationType as a TDGHIDENotification as a constant

**)
constructor TMsgNotification.Create(const dtDateTime: TDateTime; const strMsg: string; const eNotificationType: TDGHIDENotification);
begin
  FDateTime := dtDateTime;
  FMessage := strMsg;
  FNotificationType := eNotificationType;
end;

(**

  This method creates the dockable form is it is not already created.

  @precon  None.
  @postcon The dockable form is created.

**)
class procedure TfrmDockableIDENotifications.CreateDockableBrowser;
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod('TfrmDockableIDENotifications.CreateDockableBrowser', tmoTiming); {$ENDIF}
  if not Assigned(FormInstance) then
    CreateDockableForm(FormInstance, TfrmDockableIDENotifications);
end;

(**

  This method creates tool bar buttons, one for each notification type to the right of the default
  buttons.

  @precon  None.
  @postcon Toolbar buttons are created for each notifications type so that the notification can
           be switched on or off in the view.

**)
procedure TfrmDockableIDENotifications.CreateFilterButtons;
const
  iMaskColour = clLime;
  iBMSize = 16;
  iPadding = 1;
var
  iFilter: TDGHIDENotification;
  BM: TBitMap;
  B: TToolButton;
  A: TAction;
  iIndex: Integer;
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod('TfrmDockableIDENotifications.CreateFilterButtons', tmoTiming); {$ENDIF}
  for iFilter := Low(TDGHIDENotification) to High(TDGHIDENotification) do
  begin
      // Create image for toolbar and add to image list
    BM := TBitMap.Create;
    try
      BM.Height := iBMSize;
      BM.Width := iBMSize;
      BM.Canvas.Pen.Color := clBlack;
      BM.Canvas.Brush.Color := iMaskColour;
      BM.Canvas.FillRect(Rect(0, 0, iBMSize, iBMSize));
      BM.Canvas.Brush.Color := iNotificationColours[iFilter];
      BM.Canvas.Ellipse(Rect(0 + iPadding, 0 + iPadding, iBMSize - iPadding, iBMSize - iPadding));
      iIndex := ilButtons.AddMasked(BM, iMaskColour);
    finally
      BM.Free;
    end;
      // Create Action and assign image
    A := TAction.Create(alButtons);
    A.ActionList := alButtons;
    A.Caption := strNotificationLabel[iFilter];
    A.ImageIndex := iIndex;
    A.Tag := Integer(iFilter);
    A.Hint := strNotificationLabel[iFilter];
    A.OnExecute := ActionExecute;
    A.OnUpdate := ActionUpdate;
      // Create toolbar button and assign action
    B := TToolButton.Create(tbrMessageFilter);
    B.Action := A;
    B.Left := tbrMessageFilter.Buttons[tbrMessageFilter.ButtonCount - 1].Left + tbrMessageFilter.Buttons[tbrMessageFilter.ButtonCount - 1].Width + 1; // Add to the right...
    B.Parent := tbrMessageFilter; // Assign the parent last and the button goes in the right place
  end;
end;

(**

  A destructor for the TfrmDockableIDENotifications class.

  @precon  None.
  @postcon Saves the settings and frees the form memory.

**)
destructor TfrmDockableIDENotifications.Destroy;
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod('TfrmDockableIDENotifications.Destroy', tmoTiming); {$ENDIF}
  FUpdateTimer.Free;
  SaveSettings;
  SaveLogFile;
  FreeAndNil(FMessageList);
  SaveStateNecessary := True;
  inherited Destroy;
end;

(**

  This method filters the list of messages based on matches to the regular expression.

  @precon  None.
  @postcon The mesage list is filtered for matches to the filter regular expression.

**)
procedure TfrmDockableIDENotifications.FilterMessages;
resourcestring
  strFilteringForMessages = 'Filtering for "%s" (%1.0n messages)...';
  strNoFilteringInEffect = 'No filtering in effect';
var
  N: PVirtualNode;
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod('TfrmDockableIDENotifications.FilterMessages', tmoTiming); {$ENDIF}
  FIsFiltering := False;
  stbStatusBar.SimplePanel := False;
  {$IFDEF REGULAREXPRESSIONS}
  try
  {$ENDIF}
    if FRegExFilter <> '' then
    begin
        {$IFDEF REGULAREXPRESSIONS}
      FRegExEng := TRegEx.Create(FRegExFilter, [roIgnoreCase, roCompiled, roSingleLine]);
        {$ENDIF}
      FIsFiltering := True;
    end;
    LogView.BeginUpdate;
    try
      N := LogView.RootNode.FirstChild;
      while N <> Nil do
      begin
          {$IFDEF REGULAREXPRESSIONS}
        LogView.IsVisible[N] := not FIsFiltering or FRegExEng.IsMatch(LogView.Text[N, 1]);
          {$ELSE}
        LogView.IsVisible[N] := not FIsFiltering or (Pos(LowerCase(FRegExFilter), LowerCase(LogView.Text[N, 1])) > 0);
          {$ENDIF}
        N := LogView.GetNextSibling(N);
      end;
    finally
      LogView.EndUpdate;
    end;
    if FRegExFilter <> '' then
      stbStatusBar.Panels[1].Text := Format(strFilteringForMessages, [FRegExFilter, Int(LogView.VisibleCount)])
    else
      stbStatusBar.Panels[1].Text := strNoFilteringInEffect;
  {$IFDEF REGULAREXPRESSIONS}
  except
    on E: ERegularExpressionError do
      stbStatusBar.Panels[1].Text := Format('(%s) %s', [FRegExFilter, E.Message]);
  end;
  {$ENDIF}
end;

(**

  This method loads an existing log file information into the listview.

  @precon  None.
  @postcon Any existing log file information is loaded.

**)
procedure TfrmDockableIDENotifications.LoadLogFile;
resourcestring
  strLoadingLogFile = 'Loading log file: "%s"';
  strLoadingLogFilePct = 'Loading log file (%1.1f%%): "%s"';
  strLogFileLoadedRecords = 'Log file "%s" Loaded! (%1.0n records)';
const
  iMsgUpdateInterval = 100;
  dblPercentage = 100.0;
  iMsgTypeField = 2;
  iDateField = 0;
  iMsgField = 1;
  iSizeOfExpectedArray = 3;
var
  slLog: TStringList;
  iLogMsg: Integer;
  astrMsg: TDGHArrayOfString;
  dtDate: TDateTime;
  iMsgType: Integer;
  iErrorCode: Integer;
  SSS: IOTASplashScreenServices;
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod('TfrmDockableIDENotifications.LoadLogFile', tmoTiming); {$ENDIF}
  FLogFileName := ConstructorLogFileName;
  if not FileExists(FLogFileName) then
    Exit;
  if Supports(SplashScreenServices, IOTASplashScreenServices, SSS) then
    SSS.StatusMessage(Format(strLoadingLogFile, [ExtractFileName(FLogFileName)]));
  slLog := TStringList.Create;
  try
    slLog.LoadFromFile(FLogFileName);
    for iLogMsg := 0 to slLog.Count - 1 do
      if slLog[iLogMsg] <> '' then
      begin
        if (iLogMsg mod iMsgUpdateInterval = 0) and Assigned(SSS) then
          SSS.StatusMessage(Format(strLoadingLogFilePct, [Int(Succ(iLogMsg)) / Int(slLog.Count) * dblPercentage, ExtractFileName(FLogFileName)]));
        astrMsg := DGHSplit(slLog[iLogMsg], '|');
        if (Length(astrMsg) = iSizeOfExpectedArray) then
        begin
          Val(astrMsg[iDateField], dtDate, iErrorCode);
          Val(astrMsg[iMsgTypeField], iMsgType, iErrorCode);
          if dtDate >= Now() - udLogRetention.Position then
            FMessageList.Add(TMsgNotification.Create(dtDate, astrMsg[iMsgField], TDGHIDENotification(iMsgType)));
        end;
      end;
    if Assigned(SSS) then
      SSS.StatusMessage(Format(strLogFileLoadedRecords, [ExtractFileName(FLogFileName), Int(slLog.Count)]));
  finally
    slLog.Free;
  end;
  ActionExecute(Nil);
end;

(**

  This method loads the forms / applcations settings from the registry.

  @precon  None.
  @postcon The forms / applications settings are loaded from the registry.

**)
procedure TfrmDockableIDENotifications.LoadSettings;
const
  iDefaultRetensionInDays = 7;
  iDateTimeDefaultWidth = 175;
  iMessageDefaultWidth = 500;
var
  R: TRegIniFile;
  iNotification: TDGHIDENotification;
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod('TfrmDockableIDENotifications.LoadSettings', tmoTiming); {$ENDIF}
  R := TRegIniFile.Create(strRegKeyRoot);
  try
    FCapture := R.ReadBool(strINISection, strCaptureKey, False);
    FMessageFilter := [];
    for iNotification := Low(TDGHIDENotification) to High(TDGHIDENotification) do
      if R.ReadBool(strNotificationsKey, strNotificationLabel[iNotification], True) then
        Include(FMessageFilter, iNotification);
    udLogRetention.Position := R.ReadInteger(strINISection, strRetensionPeriodInDaysKey, iDefaultRetensionInDays);
    LogView.Header.Columns[0].Width := R.ReadInteger(strLogViewINISection, strDateTimeWidthKey, iDateTimeDefaultWidth);
    LogView.Header.Columns[1].Width := R.ReadInteger(strLogViewINISection, strMessageWidthKey, iMessageDefaultWidth);
  finally
    R.Free;
  end;
end;

(**

  This is an on after cell paint event handler for the log view.

  @precon  None.
  @postcon Overwrites the message with a syntax highlighted message.

  @param   Sender       as a TBaseVirtualTree
  @param   TargetCanvas as a TCanvas
  @param   Node         as a PVirtualNode
  @param   Column       as a TColumnIndex
  @param   CellRect     as a TRect

**)
procedure TfrmDockableIDENotifications.LogViewAfterCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; CellRect: TRect);

  (**

    This procedure sets the font colours for rendering the token.

    @precon  T must be a valid instance.
    @postcon The font colour is set.

    @param   T as a TDNToken as a constant

  **)
  procedure SetFontColour(const T: TDNToken);
  begin
    TargetCanvas.Font.Color := FIDEEditorTokenInfo[T.TokenType].FForeColour;
    {$IFDEF DXE102}
    if Assigned(FStyleServices) then
      TargetCanvas.Font.Color := FStyleServices.GetSystemColor(TargetCanvas.Font.Color);
    {$ENDIF DXE102}
  end;

  (**

    This procedure sets the font style for rendering the token.

    @precon  T must be a valid instance.
    @postcon The font style is set.

    @param   T as a TDNToken as a constant

  **)
  procedure SetFontStyle(const T: TDNToken);
  begin
    TargetCanvas.Font.Style := FIDEEditorTokenInfo[T.TokenType].FFontStyles;
  end;

  (**

    This procedure sets the backgroup colour of the text to be rendered.

    @precon  T must be a valid instance.
    @postcon The backgroudn colour is set.

    @param   T            as a TDNToken as a constant
    @param   IBrushColour as a TColor as a constant

  **)
  procedure SetBackgroundColour(const T: TDNToken; const IBrushColour: TColor);
  begin
    if T.RegExMatch then
      TargetCanvas.Brush.Color := FIDEEditorTokenInfo[ttSelection].FBackColour
    else
      TargetCanvas.Brush.Color := IBrushColour;
    {$IFDEF DXE102}
    if Assigned(FStyleServices) then
      TargetCanvas.Brush.Color := FStyleServices.GetSystemColor(TargetCanvas.Brush.Color);
    {$ENDIF DXE102}
  end;

  (**

    This procedure draws the text token on the canvas.

    @precon  T must be a valid instance.
    @postcon The text is drawn.

    @param   T as a TDNToken as a constant
    @param   R as a TRect as a reference

  **)
  procedure DrawText(const T: TDNToken; var R: TRect);
  var
    strText: string;
  begin
    strText := T.Text;
    TargetCanvas.TextRect(R, strText, [tfLeft, tfVerticalCenter]);
    Inc(R.Left, TargetCanvas.TextWidth(strText));
  end;

var
  NodeData: PTreeNodeData;
  Tokenizer: TDNMessageTokenizer;
  iToken: Integer;
  R: TRect;
  T: TDNToken;
  iBrushColor: TColor;
begin
  if Column = 1 then
  begin
    NodeData := Sender.GetNodeData(Node);
    R := CellRect;
    InflateRect(R, -1, -1);
    Inc(R.Left, iMargin + ilButtons.Width + iSpace);
    iBrushColor := TargetCanvas.Brush.Color;
    TargetCanvas.FillRect(R);
    Tokenizer := TDNMessageTokenizer.Create(FMessageList[NodeData.FNotificationIndex].Message, FRegExFilter);
    try
      for iToken := 0 to Tokenizer.Count - 1 do
      begin
        T := Tokenizer[iToken];
        SetFontColour(T);
        SetFontStyle(T);
        SetBackgroundColour(T, iBrushColor);
        DrawText(T, R);
      end;
    finally
      Tokenizer.Free;
    end;
  end;
end;

(**

  This is an on get image index event handler for the virtual string tree.

  @precon  None.
  @postcon Returns the image index for the message column.

  @param   Sender     as a TBaseVirtualTree
  @param   Node       as a PVirtualNode
  @param   Kind       as a TVTImageKind
  @param   Column     as a TColumnIndex
  @param   Ghosted    as a Boolean as a reference
  @param   ImageIndex as a TImageIndex as a reference

**)
procedure TfrmDockableIDENotifications.LogViewGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex);
const
  iPadding = 2;
var
  NodeData: PTreeNodeData;
begin
  NodeData := Sender.GetNodeData(Node);
  ImageIndex := -1;
  if Kind in [ikNormal, ikSelected] then
    case Column of
      1:
        ImageIndex := iPadding + Integer(FMessageList[NodeData.FNotificationIndex].NotificationType);
    end;
end;

(**

  This method is an on get text event handler for the virtual string tree.

  @precon  None.
  @postcon Returns the text for the appropriate column in the message log.

  @param   Sender   as a TBaseVirtualTree
  @param   Node     as a PVirtualNode
  @param   Column   as a TColumnIndex
  @param   TextType as a TVSTTextType
  @param   CellText as a String as a reference

**)
procedure TfrmDockableIDENotifications.LogViewGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
const
  strDateTimeFmt = 'ddd dd/mmm/yyyy hh:nn:ss.zzz';
var
  NodeData: PTreeNodeData;
  R: TMsgNotification;
begin
  NodeData := Sender.GetNodeData(Node);
  R := FMessageList[NodeData.FNotificationIndex];
  case Column of
    0:
      CellText := FormatDateTime(strDateTimeFmt, R.DateTime);
    1:
      CellText := R.Message;
  end;
end;

(**

  This is an on KeyPress event handler for the virtual string tree log.

  @precon  None.
  @postcon Captures filter text and stores it internally and triggers a filtering of the message
           view.

  @param   Sender as a TObject
  @param   Key    as a Char as a reference

**)
procedure TfrmDockableIDENotifications.LogViewKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    #08:
      begin
        FRegExFilter := Copy(FRegExFilter, 1, Length(FRegExFilter) - 1);
        FilterMessages;
        Key := #0;
      end;
    #27:
      begin
        FRegExFilter := '';
        FilterMessages;
        Key := #0;
      end;
    #32..#128:
      begin
        FRegExFilter := FRegExFilter + Key;
        FilterMessages;
        Key := #0;
      end;
  end;
end;

(**

  This method frees the dockable form.

  @precon  None.
  @postcon The dockable form  is freed.

**)
class procedure TfrmDockableIDENotifications.RemoveDockableBrowser;
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod('TfrmDockableIDENotifications.RemoveDockableBrowser', tmoTiming); {$ENDIF}
  FreeDockableForm(FormInstance);
end;

(**

  This method gets the IDE Editor colours so they can be used for rendering the notifications.

  @precon  None.
  @postcon FIDEEditorTokenInfo is updated to reflect the IDE Editor Colours.

**)
procedure TfrmDockableIDENotifications.RetreiveIDEEditorColours;
begin
  FIDEEditorTokenInfo := FIDEEditorColours.GetIDEEditorColours(FBackgroundColour);
end;

(**

  This method saves the log information to a log file.

  @precon  None.
  @postcon Any log file information is saved.

**)
procedure TfrmDockableIDENotifications.SaveLogFile;
var
  slLog: TStringList;
  iLogItem: Integer;
  iMsgType: Integer;
  R: TMsgNotification;
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod('TfrmDockableIDENotifications.SaveLogFile', tmoTiming); {$ENDIF}
  slLog := TStringList.Create;
  try
    for iLogItem := 0 to FMessageList.Count - 1 do
    begin
      R := FMessageList[iLogItem];
      iMsgType := Integer(R.NotificationType);
      slLog.Add(Format('%1.12f|%s|%d', [R.DateTime, R.Message, iMsgType]));
    end;
    slLog.SaveToFile(FLogFileName);
  finally
    slLog.Free;
  end;
end;

(**

  This method saves the forms / applications settings to the registry.

  @precon  None.
  @postcon The forms / applications settings are saved to the regsitry.

**)
procedure TfrmDockableIDENotifications.SaveSettings;
var
  R: TRegIniFile;
  iNotification: TDGHIDENotification;
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod('TfrmDockableIDENotifications.SaveSettings', tmoTiming); {$ENDIF}
  R := TRegIniFile.Create(strRegKeyRoot);
  try
    R.WriteBool(strINISection, strCaptureKey, FCapture);
    for iNotification := Low(TDGHIDENotification) to High(TDGHIDENotification) do
      R.WriteBool(strNotificationsKey, strNotificationLabel[iNotification], iNotification in FMessageFilter);
    R.WriteInteger(strINISection, strRetensionPeriodInDaysKey, udLogRetention.Position);
    R.WriteInteger(strLogViewINISection, strDateTimeWidthKey, LogView.Header.Columns[0].Width);
    R.WriteInteger(strLogViewINISection, strMessageWidthKey, LogView.Header.Columns[1].Width);
  finally
    R.Free;
  end;
end;

(**

  This method shows the dockable form and also will create it if it is not already created.

  @precon  None.
  @postcon The dockable form is shown.

**)
class procedure TfrmDockableIDENotifications.ShowDockableBrowser;
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod('TfrmDockableIDENotifications.ShowDockableBrowser', tmoTiming); {$ENDIF}
  CreateDockableBrowser;
  ShowDockableForm(FormInstance);
end;

(**

  This update timer updates the focused log entry after a period of time after the last notification
  and updates the statusbar.

  @precon  None.
  @postcon Updates the focused node and the statusbar.

  @param   Sender as a TObject

**)
procedure TfrmDockableIDENotifications.UpdateTimer(Sender: TObject);
resourcestring
  strShowingMessages = 'Showing %1.0n of %1.0n Messages';
var
  Node: PVirtualNode;
begin
  if (FLastUpdate > 0) and (GetTickCount > FLastUpdate + iUpdateInterval) then
  begin
    Node := LogView.GetLastChild(LogView.RootNode);
    LogView.Selected[Node] := True;
    LogView.FocusedNode := Node;
    stbStatusBar.Panels[0].Text := Format(strShowingMessages, [Int(LogView.RootNodeCount), Int(FMessageList.Count)]);
    FLastUpdate := 0;
  end;
end;

end.

