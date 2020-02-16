(**

  This module contains a class which implements the IOTAIDENotifier, IOTAIDENotifier50 and
  IOTAIDENotifier80 interfaces to capture file notifiction and compiler notifications in the
  RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.298
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
unit DGHIDENotifiers.IDENotifier;

interface

uses
  ToolsAPI,
  DGHIDENotifiers.Interfaces,
  DGHIDENotifiers.Types,
  Classes,
  DGHIDENotifiers.ModuleNotifierCollection;

{$INCLUDE 'CompilerDefinitions.inc'}

type
  (** This class implements the IDENotifier interfaces. **)
  TDGHNotificationsIDENotifier = class(TDGHNotifierObject, IOTAIDENotifier, IOTAIDENotifier50, IOTAIDENotifier80)
  strict private
    FModuleNotifiers: IDINModuleNotifierList;
    FProjectNotifiers: IDINModuleNotifierList;
    FProjectCompileNotifiers: IDINModuleNotifierList;
    FSourceEditorNotifiers: IDINModuleNotifierList;
    FFormEditorNotifiers: IDINModuleNotifierList;
  {$IFDEF D2010}   strict {$ENDIF} protected
    // IOTAIDENotifier
    procedure FileNotification(NotifyCode: TOTAFileNotification; const FileName: string; var Cancel: Boolean);
    // IOTAIDENotifier
    procedure BeforeCompile(const Project: IOTAProject; var Cancel: Boolean); overload;
    procedure AfterCompile(Succeeded: Boolean); overload;
    // IOTAIDENotifier50
    procedure BeforeCompile(const Project: IOTAProject; IsCodeInsight: Boolean; var Cancel: Boolean); overload;
    procedure AfterCompile(Succeeded: Boolean; IsCodeInsight: Boolean); overload;
    // IOTAIDENotifier80
    procedure AfterCompile(const Project: IOTAProject; Succeeded: Boolean; IsCodeInsight: Boolean); overload;
    // General Methods
    procedure InstallModuleNotifier(const M: IOTAModule; const FileName: string);
    procedure UninstallModuleNotifier(const M: IOTAModule; const FileName: string);
    procedure InstallProjectNotifier(const M: IOTAModule; const FileName: string);
    procedure UninstallProjectNotifier(const M: IOTAModule; const FileName: string);
    {$IFDEF DXE00}
    procedure InstallProjectCompileNotifier(const P: IOTAProject; const FileName: string);
    procedure UninstallProjectCompileNotifier(const P: IOTAProject; const FileName: string);
    {$ENDIF DXE00}
    procedure RenameModule(const strOldFilename, strNewFilename: string);
    procedure InstallEditorNotifiers(const M: IOTAModule);
    procedure UninstallEditorNotifiers(const M: IOTAModule);
  public
    constructor Create(const strNotifier, strFileName: string; const iNotification: TDGHIDENotification); override;
    destructor Destroy; override;
  end;

implementation

uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  SysUtils,
  DGHIDENotifiers.Common,
  DGHIDENotifiers.ModuleNotifier,
  DGHIDENotifiers.ProjectNotifier,
  DGHIDENotifiers.FormNotifier,
  DGHIDENotifiers.ProjectCompileNotifier,
  DGHIDENotifiers.SourceEditorNotifier;

(**

  This method is called after a project is compiled.

  @precon  None.
  @postcon Provides access whether the compilation was successful.

  @nocheck MissingCONSTInParam

  @param   Succeeded     as a Boolean

**)
procedure TDGHNotificationsIDENotifier.AfterCompile(Succeeded: Boolean);
resourcestring
  strAfterCompile = '.AfterCompile = Succeeded: %s';
begin
  DoNotification(Format(strAfterCompile, [strBoolean[Succeeded]]));
end;

(**

  This method is called after a project is compiled.

  @precon  None.
  @postcon Provides access whether the compilation was successful and whether it was invoked by
           CodeInsight.

  @nocheck MissingCONSTInParam

  @param   Succeeded     as a Boolean
  @param   IsCodeInsight as a Boolean

**)
procedure TDGHNotificationsIDENotifier.AfterCompile(Succeeded, IsCodeInsight: Boolean);
resourcestring
  strAfterCompile = '50.AfterCompile = Succeeded: %s, IsCodeInsight: %s';
begin
  DoNotification(Format(strAfterCompile, [strBoolean[Succeeded], strBoolean[IsCodeInsight]]));
end;

(**

  This method is called after a project is compiled.

  @precon  None.
  @postcon Provides access to the Project, whether the compilation was successful and whether it was
           invoked by CodeInsight.

  @nocheck MissingCONSTInParam

  @param   Project       as an IOTAProject as a constant
  @param   Succeeded     as a Boolean
  @param   IsCodeInsight as a Boolean

**)
procedure TDGHNotificationsIDENotifier.AfterCompile(const Project: IOTAProject; Succeeded, IsCodeInsight: Boolean);
resourcestring
  strAfterCompile = '80.AfterCompile = Project: %s, Succeeded: %s, IsCodeInsight: %s';
begin
  DoNotification(Format(strAfterCompile, [GetProjectFileName(Project), strBoolean[Succeeded], strBoolean[IsCodeInsight]]));
end;

(**

  This method is called before a project is compiled.

  @precon  None.
  @postcon Provides access to the Project being compiled and whether the compile was invoked by
           CodeInsight.

  @nocheck MissingCONSTInParam

  @param   Project       as an IOTAProject as a constant
  @param   IsCodeInsight as a Boolean
  @param   Cancel        as a Boolean as a reference

**)
procedure TDGHNotificationsIDENotifier.BeforeCompile(const Project: IOTAProject; IsCodeInsight: Boolean; var Cancel: Boolean);
resourcestring
  strBeforeCompile = '50.BeforeCompile = Project: %s, IsCodeInsight: %s, Cancel: %s';
begin
  DoNotification(Format(strBeforeCompile, [GetProjectFileName(Project), strBoolean[IsCodeInsight], strBoolean[Cancel]]));
end;

(**

  This method is called before a project is compiled.

  @precon  None.
  @postcon Provides access to the Project being compiled.

  @param   Project       as an IOTAProject as a constant
  @param   Cancel        as a Boolean as a reference

**)
procedure TDGHNotificationsIDENotifier.BeforeCompile(const Project: IOTAProject; var Cancel: Boolean);
resourcestring
  strBeforeCompile = '.BeforeCompile = Project: %s, Cancel: %s';
begin
  DoNotification(Format(strBeforeCompile, [GetProjectFileName(Project), strBoolean[Cancel]]));
end;

(**

  This is a constructor for the TDGHNotificationsIDENotifier class.

  @precon  None.
  @postcon Initialises a string list to store the filenames and their module notifier indexes.

  @param   strNotifier   as a String as a constant
  @param   strFileName   as a String as a constant
  @param   iNotification as a TDGHIDENotification as a constant

**)
constructor TDGHNotificationsIDENotifier.Create(const strNotifier, strFileName: string; const iNotification: TDGHIDENotification);
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod('TDGHNotificationsIDENotifier.Create', tmoTiming); {$ENDIF}
  inherited Create(strNotifier, strFileName, iNotification);
  FModuleNotifiers := TDINModuleNotifierList.Create;
  FProjectNotifiers := TDINModuleNotifierList.Create;
  FProjectCompileNotifiers := TDINModuleNotifierList.Create;
  FSourceEditorNotifiers := TDINModuleNotifierList.Create;
  FFormEditorNotifiers := TDINModuleNotifierList.Create;
end;

(**

  This is a destructor for the TDGHNotificationsIDENotifier class.

  @precon  None.
  @postcon Closes any remaining module notifiers and frees the memory.

**)
destructor TDGHNotificationsIDENotifier.Destroy;
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod('TDGHNotificationsIDENotifier.Destroy', tmoTiming); {$ENDIF}
  inherited Destroy;
end;

(**

  This method iscalled when ever a file or package is loaded or unloaded from the IDE.

  @precon  None.
  @postcon Provides access to the Filename and the operation that occurred.

  @nocheck MissingCONSTInParam

  @param   NotifyCode as a TOTAFileNotification
  @param   FileName   as a String as a constant
  @param   Cancel     as a Boolean as a reference

**)
procedure TDGHNotificationsIDENotifier.FileNotification(NotifyCode: TOTAFileNotification; const FileName: string; var Cancel: Boolean);
const
  strNotifyCode: array[Low(TOTAFileNotification)..High(TOTAFileNotification)] of string = ('ofnFileOpening', 'ofnFileOpened', 'ofnFileClosing', 'ofnDefaultDesktopLoad', 'ofnDefaultDesktopSave', 'ofnProjectDesktopLoad', 'ofnProjectDesktopSave', 'ofnPackageInstalled', 'ofnPackageUninstalled', 'ofnActiveProjectChanged' {$IFDEF DXE80}, 'ofnProjectOpenedFromTemplate' {$ENDIF}
    );
resourcestring
  strFileNotificationNotify = '.FileNotification = NotifyCode: %s, FileName: %s, Cancel: %s';
var
  MS: IOTAModuleServices;
  M: IOTAModule;
  P: IOTAProject;
begin
  DoNotification(Format(strFileNotificationNotify, [strNotifyCode[NotifyCode], ExtractFileName(FileName), strBoolean[Cancel]]));
  if not Cancel and Supports(BorlandIDEServices, IOTAModuleServices, MS) then
    case NotifyCode of
      ofnFileOpened:
        begin
          M := MS.OpenModule(FileName);
          if Supports(M, IOTAProject, P) then
          begin
            InstallProjectNotifier(M, FileName);
            InstallProjectCompileNotifier(P, FileName);
          end
          else
          begin
            InstallModuleNotifier(M, FileName);
          end;
        end;
      ofnFileClosing:
        begin
          M := MS.OpenModule(FileName);
          if Supports(M, IOTAProject, P) then
          begin
            UninstallProjectNotifier(M, FileName);
            UninstallProjectCompileNotifier(P, FileName);
          end
          else
          begin
            UninstallModuleNotifier(M, FileName);
          end;
        end;
    end;
end;

(**

  This method installed the Editor notifiers. The module files are queried to see if they support either
  the IOTASourceEditor or IOTAFormEditor interfaces and the notifiers are installed via those.

  @precon  M must be a valid instance.
  @postcon Editor or Form notifier are installed for the modules files.

  @param   M as an IOTAModule as a constant

**)
procedure TDGHNotificationsIDENotifier.InstallEditorNotifiers(const M: IOTAModule);
const
  strIOTAEditViewNotifier = 'IOTAEditViewNotifier';
  strIOTAFormNotifier = 'IOTAFormNotifier';
var
  i: Integer;
  E: IOTAEditor;
  SE: IOTASourceEditor;
  FE: IOTAFormEditor;
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod(Self, 'InstallEditorNotifier', tmoTiming); {$ENDIF}
  for i := 0 to M.GetModuleFileCount - 1 do
  begin
    E := M.GetModuleFileEditor(i);
    if Supports(E, IOTASourceEditor, SE) then
      FSourceEditorNotifiers.Add(M.FileName, SE.AddNotifier(TDINSourceEditorNotifier.Create(strIOTAEditViewNotifier, M.FileName, dinSourceEditorNotifier, SE)));
    if Supports(E, IOTAFormEditor, FE) then
      FFormEditorNotifiers.Add(M.FileName, FE.AddNotifier(TDINFormNotifier.Create(strIOTAFormNotifier, M.FileName, dinFormNotifier)));
  end;
end;

(**

  This method installs the module notifiers.

  @precon  M must be a valid instance.
  @postcon A module notifier is created and associated with the given filename and added to the IDE and
           then added to the Module Notifiers List.

  @param   M        as an IOTAModule as a constant
  @param   FileName as a String as a constant

**)
procedure TDGHNotificationsIDENotifier.InstallModuleNotifier(const M: IOTAModule; const FileName: string);
const
  strIOTAModuleNotifier = 'IOTAModuleNotifier';
var
  MN: IOTAModuleNotifier;
begin
  MN := TDNModuleNotifier.Create(strIOTAModuleNotifier, FileName, dinModuleNotifier, RenameModule);
  FModuleNotifiers.Add(FileName, M.AddNotifier(MN));
  InstallEditorNotifiers(M);
end;

{$IFDEF DXE00}
(**

  This method installs the project compile notifiers.

  @precon  P must be a valid instance.
  @postcon A project compile notifier is created and associated with the given filename and added to the
           IDE and then added to the Project Compile Notifiers List.

  @param   P        as an IOTAProject as a constant
  @param   FileName as a String as a constant

**)
procedure TDGHNotificationsIDENotifier.InstallProjectCompileNotifier(const P: IOTAProject; const FileName: string);
const
  strIOTAProjectCompileNotifier = 'IOTAProjectCompileNotifier';
var
  PCN: IOTAProjectCompileNotifier;
begin
  if Assigned(P.ProjectBuilder) then
  begin
    PCN := TDNProjectCompileNotifier.Create(strIOTAProjectCompileNotifier, FileName, dinProjectCompileNotifier);
    FProjectCompileNotifiers.Add(FileName, P.ProjectBuilder.AddCompileNotifier(PCN));
  end;
end;
{$ENDIF DXE00}

(**

  This method installs the project notifiers.

  @precon  M must be a valid instance.
  @postcon A project notifier is created and associated with the given filename and added to the IDE and
           then added to the Project Notifiers List.

  @param   M        as an IOTAModule as a constant
  @param   FileName as a String as a constant

**)

procedure TDGHNotificationsIDENotifier.InstallProjectNotifier(const M: IOTAModule; const FileName: string);
const
  strIOTAProjectNotifier = 'IOTAProjectNotifier';
var
  MN: IOTAModuleNotifier;
begin
  MN := TDNProjectNotifier.Create(strIOTAProjectNotifier, FileName, dinProjectNotifier, RenameModule);
  FProjectNotifiers.Add(FileName, M.AddNotifier(MN));
end;

(**

  This method is a callback event for when a module is renamed by the IDE.

  @precon  None.
  @postcon Ebsures that the modules in the notifier lists are updated with the new filename.

  @param   strOldFilename as a String as a constant
  @param   strNewFilename as a String as a constant

**)
procedure TDGHNotificationsIDENotifier.RenameModule(const strOldFilename, strNewFilename: string);
begin
  FModuleNotifiers.Rename(strOldFilename, strNewFilename);
  FProjectNotifiers.Rename(strOldFilename, strNewFilename);
  FProjectCompileNotifiers.Rename(strOldFilename, strNewFilename);
  FSourceEditorNotifiers.Rename(strOldFilename, strNewFilename);
  FFormEditorNotifiers.Rename(strOldFilename, strNewFilename);
end;

(**

  This method uninstalls the editor notifiers.

  @precon  M must be a valid instance.
  @postcon The editor notifiers are removed from the IDE.

  @param   M as an IOTAModule as a constant

**)
procedure TDGHNotificationsIDENotifier.UninstallEditorNotifiers(const M: IOTAModule);
var
  i: Integer;
  E: IOTAEditor;
  SE: IOTASourceEditor;
  FE: IOTAFormEditor;
  iIndex: Integer;
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod(Self, 'UninstallEditorNotifier', tmoTiming); {$ENDIF}
  for i := 0 to M.GetModuleFileCount - 1 do
  begin
    E := M.GetModuleFileEditor(i);
    if Supports(E, IOTASourceEditor, SE) then
    begin
      iIndex := FSourceEditorNotifiers.Remove(M.FileName);
      if iIndex > -1 then
        SE.RemoveNotifier(iIndex);
    end;
    if Supports(E, IOTAFormEditor, FE) then
    begin
      iIndex := FFormEditorNotifiers.Remove(M.FileName);
      if iIndex > -1 then
        FE.RemoveNotifier(iIndex);
    end;
  end;
end;

(**

  This method uninstalls the Module Notifier associated with the filename and removes it from the Module
  Notifier List.

  @precon  M must be a valid instance.
  @postcon The module notifier is removed from the IDE and then removed from the notifier list.

  @param   M        as an IOTAModule as a constant
  @param   FileName as a String as a constant

**)
procedure TDGHNotificationsIDENotifier.UninstallModuleNotifier(const M: IOTAModule; const FileName: string);
var
  MNL: IDINModuleNotifierList;
  iIndex: Integer;
begin
  MNL := FModuleNotifiers;
  iIndex := MNL.Remove(FileName);
  if iIndex > -1 then
    M.RemoveNotifier(iIndex);
  UninstallEditorNotifiers(M);
end;

{$IFDEF DXE00}
(**

  This method uninstalls the Project Compile Notifier associated with the filename and removes it from
  the Project Compile Notifier List.

  @precon  P must be a valid instance.
  @postcon The project compile notifier is removed from the IDE and then removed from the notifier list.

  @param   P        as an IOTAProject as a constant
  @param   FileName as a String as a constant

**)
procedure TDGHNotificationsIDENotifier.UninstallProjectCompileNotifier(const P: IOTAProject; const FileName: string);
var
  MNL: IDINModuleNotifierList;
  iIndex: Integer;
begin
  MNL := FProjectCompileNotifiers;
  iIndex := MNL.Remove(FileName);
  if iIndex > -1 then
    P.ProjectBuilder.RemoveCompileNotifier(iIndex);
end;
{$ENDIF DXE00}

(**

  This method uninstalls the Project Notifier associated with the filename and removes it from the
  Project Notifier List.

  @precon  M must be a valid instance.
  @postcon The project notifier is removed from the IDE and then removed from the project list.

  @param   M        as an IOTAModule as a constant
  @param   FileName as a String as a constant

**)

procedure TDGHNotificationsIDENotifier.UninstallProjectNotifier(const M: IOTAModule; const FileName: string);
var
  MNL: IDINModuleNotifierList;
  iIndex: Integer;
begin
  MNL := FProjectNotifiers;
  iIndex := MNL.Remove(FileName);
  if iIndex > -1 then
    M.RemoveNotifier(iIndex);
end;

end.

