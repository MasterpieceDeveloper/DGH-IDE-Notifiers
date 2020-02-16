(**

  This module contains a class that implements the IOTAProjectCompileNotifier interface for capturing
  compile information on each compile operation.

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
unit DGHIDENotifiers.ProjectCompileNotifier;

interface

uses
  ToolsAPI,
  DGHIDENotifiers.Types,
  DGHIDENotifiers.Interfaces;

type
  (** A class to implement the IOTAProjectCompileNotifier interface. **)
  TDNProjectCompileNotifier = class(TDGHNotifierObject, IOTAProjectCompileNotifier)
  strict private
    FModuleNotiferList: IDINModuleNotifierList;
  strict protected
    // IOTAProjectCompileNotification
    procedure AfterCompile(var CompileInfo: TOTAProjectCompileInfo);
    procedure BeforeCompile(var CompileInfo: TOTAProjectCompileInfo);
    // General Properties
    (**
      A property the exposes to this class and descendants an interface for notifying the module notifier
      collections of a change of module name.
      @precon  None.
      @postcon Returns the IDINRenameModule reference.
      @return  an IDINModuleNotifierList
    **)
    property RenameModule: IDINModuleNotifierList read FModuleNotiferList;
  public
  end;

implementation

uses
  SysUtils;

const
  (** An array constant of strings for each compiel mode. **)
  astrCompileMode: array[TOTACompileMode] of string = ('cmOTAMake', 'cmOTABuild', 'cmOTACheck', 'cmOTAMakeUnit');
  (** An array constant of strings for false and true. **)
  astrBoolean: array[False..True] of string = ('False', 'True');

{ TDNProjectCompileNotifier }

(**

  This method is called after the compilation of each project.

  @precon  None.
  @postcon Provides a record with the Mode, Configuration, Platform and result of the compile.

  @param   CompileInfo as a TOTAProjectCompileInfo as a reference

**)
procedure TDNProjectCompileNotifier.AfterCompile(var CompileInfo: TOTAProjectCompileInfo);
resourcestring
  strAfterCompile = '.AfterCompile = Mode: %s, Configuration: %s, Platform: %s, Result: %s';
begin
  DoNotification(Format(strAfterCompile, [astrCompileMode[CompileInfo.Mode], CompileInfo.Configuration, CompileInfo.platform, astrBoolean[CompileInfo.Result]]));
end;

(**

  This method is called before the compilation of each project.

  @precon  None.
  @postcon Provides a record with the Mode, Configuration and Platform for the compile operation (result
           is meaningless in this context).

  @param   CompileInfo as a TOTAProjectCompileInfo as a reference

**)
procedure TDNProjectCompileNotifier.BeforeCompile(var CompileInfo: TOTAProjectCompileInfo);
resourcestring
  strBeforeCompile = '.BeforeCompile = Mode: %s, Configuration: %s, Platform: %s, Result: %s';
begin
  DoNotification(Format(strBeforeCompile, [astrCompileMode[CompileInfo.Mode], CompileInfo.Configuration, CompileInfo.platform, astrBoolean[CompileInfo.Result]]));
end;

end.

