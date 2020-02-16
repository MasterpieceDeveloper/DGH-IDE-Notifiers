(**

  This module contains a class which represents a form for displaying information about the application.

  @Author  David Hoyle
  @Version 1.074
  @Date    09 Feb 2020

**)
unit DGHIDENotifiers.AboutDlg;

interface

{$INCLUDE CompilerDefinitions.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Buttons,
  Vcl.ExtCtrls, System.ImageList, Vcl.ImgList;

type
  (** A class to represent the about form. **)
  TfrmDINAboutDlg = class(TForm)
    pnlButtons: TPanel;
    lblInformation: TMemo;
    lblBuildDate: TLabel;
    lblAuthor: TLabel;
    lblBuild: TLabel;
    lblExpertMgr: TLabel;
    btnOK: TButton;
    ilButtons: TImageList;
    procedure FormCreate(Sender: TObject);
  strict private
  strict protected
  public
    class procedure Execute;
  end;

implementation

uses
  ToolsAPI,
  DGHIDENotifiers.Common;

{$R *.dfm}

(**

  This method is the intended way to display this dialogue.

  @precon  None.
  @postcon The dialogue is displayed in a modal state.

**)
class procedure TfrmDINAboutDlg.Execute;
var
  F: TfrmDINAboutDlg;
begin
  F := TfrmDINAboutDlg.Create(Application.MainForm);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

(**

  This is an OnFormCreate Event Handler for the TfrmOISAbout class.

  @precon  None.
  @postcon Updates the captions to the build of the application.

  @param   Sender as a TObject

**)
procedure TfrmDINAboutDlg.FormCreate(Sender: TObject);
type
  TDINVerInfo = record
    FMajor, FMinor, FBugFix, FBuild: Integer;
  end;
resourcestring
  strBuildDate = 'Build Date: %s';
  {$IFDEF DEBUG}
  strDINCaption = 'DGH IDE Notifiers %d.%d%s (DEBUG Build %d.%d.%d.%d)';
  {$ELSE}
  strDINCaption = 'DGH IDE Notifiers %d.%d%s (Build %d.%d.%d.%d)';
  {$ENDIF}
const
  strDateFmt = 'ddd dd mmm yyyy @ hh:nn';
var
  dtDateTime: TDateTime;
  recVerInfo: TDINVerInfo;
  {$IFDEF DXE102}
  ITS: IOTAIDEThemingServices250;
  {$ENDIF DXE102}

begin
  {$IFDEF DXE102}
  if Supports(BorlandIDEServices, IOTAIDEThemingServices250, ITS) then
  begin
    ITS.RegisterFormClass(TfrmDINAboutDlg);
    if ITS.IDEThemingEnabled then
      ITS.ApplyTheme(Self);
  end;
  {$ENDIF DXE102}
  FileAge(ParamStr(0), dtDateTime);
  lblBuildDate.Caption := Format(strBuildDate, [FormatDateTime(strDateFmt, dtDateTime)]);
  BuildNumber(recVerInfo.FMajor, recVerInfo.FMinor, recVerInfo.FBugFix, recVerInfo.FBuild);
  lblBuild.Caption := Format(strDINCaption, [recVerInfo.FMajor, recVerInfo.FMinor, strRevision[recVerInfo.FBugFix + 1], recVerInfo.FMajor, recVerInfo.FMinor, recVerInfo.FBugFix, recVerInfo.FBuild]);
end;

end.

