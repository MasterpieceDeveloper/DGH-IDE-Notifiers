(**

  This module contains a class which implements the IOTAEditViewNotifier for draweing on the code editor.

  @Author  David Hoyle
  @Version 1.687
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
unit DGHIDENotifiers.EditViewNotifier;

interface

{$INCLUDE CompilerDefinitions.inc}

{$IFDEF DXE100}
uses
  ToolsAPI,
  Classes,
  Graphics,
  Windows,
  DGHIDENotifiers.Types;

type
  (** A class which implements the INTAEditViewNotifier interface for drawings on the editor. **)
  TDINEditViewNotifier = class(TDGHNotifierObject, IInterface, IOTANotifier, INTAEditViewNotifier)
  strict private
  strict protected
    procedure BeginPaint(const View: IOTAEditView; var FullRepaint: Boolean);
    procedure EditorIdle(const View: IOTAEditView);
    procedure EndPaint(const View: IOTAEditView);
    procedure PaintLine(const View: IOTAEditView; LineNumber: Integer; const LineText: PAnsiChar; const TextWidth: Word; const LineAttributes: TOTAAttributeArray; const Canvas: TCanvas; const TextRect: TRect; const LineRect: TRect; const CellSize: TSize);
  public
  end;
{$ENDIF DXE100}

implementation

uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  SysUtils;

{$IFDEF DXE100}
(**

  This method is called before the code editor is repainted. By default Fullrepaint is false however
  you can set it to true but beaware that doing this all the time can affect the editors scrolling /
  drawing performance.

  @precon  None.
  @postcon Use this methods to setup information you want to use to render on the code editor.

  @param   View        as an IOTAEditView as a constant
  @param   FullRepaint as a Boolean as a reference

**)
procedure TDINEditViewNotifier.BeginPaint(const View: IOTAEditView; var FullRepaint: Boolean);
resourcestring
  strBeginPaint = '.BeginPaint = View.TopRow: %d, FullRepaint: %s';
begin
  DoNotification(Format(strBeginPaint, [View.TopRow, BoolToStr(FullRepaint)]));
end;

(**

  This method is called when the code editor is idle.

  @precon  None.
  @postcon Not sure how you would use this over and above BeginPaint() and EndPaint().

  @nohint  View

  @param   View as an IOTAEditView as a constant

**)
procedure TDINEditViewNotifier.EditorIdle(const View: IOTAEditView);
resourcestring
  strEditorIdle = '.EditorIdle = View.TopRow: %d';
begin
  DoNotification(Format(strEditorIdle, [View.TopRow]));
end;

(**

  This method is called after the code editor is repainted.

  @precon  None.
  @postcon Use this methods to clean up the information you used to render on the code editor.

  @param   View        as an IOTAEditView as a constant

**)
procedure TDINEditViewNotifier.EndPaint(const View: IOTAEditView);
resourcestring
  strEndPaint = '.EndPaint = View.TopRow: %d';
begin
  DoNotification(Format(strEndPaint, [View.TopRow]));
end;

(**

  This method is called for each line in the editor to be painted. The information you want to paint here
  should be already cached else you will impact the performance of the rendering of the code editor.

  @precon  None.
  @postcon Use this method to paint on the editor using the given information.

  @nocheck MissingCONSTInParam
  @nohint  LineText LineAttributes Canvas TextRect LineRect CellSize
  @nometrics

  @param   View           as an IOTAEditView as a constant
  @param   LineNumber     as an Integer
  @param   LineText       as a PAnsiChar as a constant
  @param   TextWidth      as a Word as a constant
  @param   LineAttributes as a TOTAAttributeArray as a constant
  @param   Canvas         as a TCanvas as a constant
  @param   TextRect       as a TRect as a constant
  @param   LineRect       as a TRect as a constant
  @param   CellSize       as a TSize as a constant

**)
procedure TDINEditViewNotifier.PaintLine(const View: IOTAEditView; LineNumber: Integer; const LineText: PAnsiChar; const TextWidth: Word; const LineAttributes: TOTAAttributeArray; const Canvas: TCanvas; const TextRect, LineRect: TRect; const CellSize: TSize);
resourcestring
  strEndPaint = '.PaintLine = View.TopRow, LineNumber: %d, LineText, TextWidth: %d,' + ' LineAttributes, Canvas, TextRect, CellSize';
begin
  DoNotification(Format(strEndPaint, [View.TopRow, LineNumber, TextWidth]));
end;
{$ENDIF DXE100}

end.

