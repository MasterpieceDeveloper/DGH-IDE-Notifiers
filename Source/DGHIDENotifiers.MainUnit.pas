(**

  This module contains the basic code to register the wizard / expert / plug-in with the RAD Studio
  IDE for both packages and DLLs. It also is responsible for the ceration and destructions of the
  dockable notification window / log.

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
unit DGHIDENotifiers.MainUnit;

interface

uses
  ToolsAPI;

function InitWizard(const BorlandIDEServices: IBorlandIDEServices; RegisterProc: TWizardRegisterProc; var Terminate: TWizardTerminateProc): Boolean; stdcall;

exports
  InitWizard name WizardEntryPoint;

implementation

uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  DGHIDENotifiers.Wizard,
  DGHIDENotifiers.Types;

(**

  This method is requested by the RAD Studio IDE in order to load the plugin as a DLL wizard.

  @precon  None.
  @postcon Creates the plugin.

  @nocheck MissingCONSTInParam
  @nohint  Terminate

  @param   BorlandIDEServices as an IBorlandIDEServices as a constant
  @param   RegisterProc       as a TWizardRegisterProc
  @param   Terminate          as a TWizardTerminateProc as a reference
  @return  a Boolean

**)
function InitWizard(const BorlandIDEServices: IBorlandIDEServices; RegisterProc: TWizardRegisterProc; var Terminate: TWizardTerminateProc): Boolean; stdcall; //FI:O804

const
  strIOTAWizard = 'IOTAWizard';
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod('InitWizard', tmoTiming); {$ENDIF}
  Result := BorlandIDEServices <> Nil;
  RegisterProc(TDGHIDENotifiersWizard.Create(strIOTAWizard, '', dinWizard));
end;

end.

