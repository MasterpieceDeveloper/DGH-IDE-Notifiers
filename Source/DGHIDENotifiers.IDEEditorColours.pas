(**

  This module contains a class which implements the IBADIIDEEditorColours interface to extract
  the token colours from the IDE.

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
unit DGHIDENotifiers.IDEEditorColours;

interface

uses
  System.Win.Registry,
  VCL.Graphics,
  DGHIDENotifiers.Interfaces;

type
  (** A class which implements the IBADIIDEEditorColours interface for getting the current IDEs
      editor colours. **)
  TITHIDEEditorColours = class(TInterfacedObject, IDNIDEEditorColours)
  strict private
    function GetIDEVersionNum(const strBDSDir: string): string;
    function GetIDERegPoint(): string;
    procedure ReadHighlight(const Reg: TRegIniFile; const strSectionName: string; var TokenFontInfo: TDNTokenInfo);
  strict protected
    function GetIDEEditorColours(var iBGColour: TColor): TDNTokenFontInfoTokenSet;
  public
  end;

implementation

uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  System.SysUtils;

const
  (** This is a default set of font information for the application. **)
  strTokenTypeInfo: TDNTokenFontInfoTokenSet = ((
    FForeColour: clRed;
    FBackColour: clNone;
    FFontStyles: []
  ), (
    FForeColour: clBlack;
    FBackColour: clNone;
    FFontStyles: []
  ), (
    FForeColour: clBlack;
    FBackColour: clNone;
    FFontStyles: [fsBold]
  ), (
    FForeColour: clBlack;
    FBackColour: clNone;
    FFontStyles: []
  ), (
    FForeColour: clBlack;
    FBackColour: clNone;
    FFontStyles: []
  ), (
    FForeColour: clBlack;
    FBackColour: clNone;
    FFontStyles: []
  ), (
    FForeColour: clBlack;
    FBackColour: clNone;
    FFontStyles: []
  ), (
    FForeColour: clBlack;
    FBackColour: clNone;
    FFontStyles: []
  ), (
    FForeColour: clBlack;
    FBackColour: clNone;
    FFontStyles: [fsItalic]
  ), (
    FForeColour: clBlack;
    FBackColour: clNone;
    FFontStyles: [fsBold]
  ), (
    FForeColour: clBlack;
    FBackColour: clNone;
    FFontStyles: [fsBold]
  ), (
    FForeColour: clBlack;
    FBackColour: clAqua;
    FFontStyles: []
  ), (
    FForeColour: clBlack;
    FBackColour: clNone;
    FFontStyles: []
  ));


(**

  This method iterates each token type and loads into information from the registry (if found).

  @precon  None.
  @postcon The IDE Editor Colours are loaded.

  @param   iBGColour as a TColor as a reference
  @return  a TDNTokenFontInfoTokenSet

**)
function TITHIDEEditorColours.GetIDEEditorColours(var iBGColour: TColor): TDNTokenFontInfoTokenSet;
const
  strBDSEnviroVar = 'BDS';
  strHelpRegKey = 'Software\Embarcadero\%s\%s\Editor\Highlight';
  strTokenHighlightMap: array[TDNTokenType] of string = ('Illegal Char',                          // ttUnknown
    'Whitespace',                            // ttWhiteSpace
    'Reserved word',                         // ttReservedWord
    'Identifier',                            // ttIdentifier
    'Number',                                // ttNumber
    'Symbol',                                // ttSymbol
    'String',                                // ttSingleLiteral
    'Character',                             // ttDoubleLiteral
    'Comment',                               // ttLineComment
    'Reserved word',                         // ttDirective
    'Preprocessor',                          // ttCompilerDirective
    'Plain text',                            // ttPlainText
    'Additional search match highlight'      // ttSelection
    );
var
  strBDSDir: string;
  R: TRegIniFile;
  eTokenType: TDNTokenType;
begin
  Result := strTokenTypeInfo;
  strBDSDir := GetEnvironmentVariable(strBDSEnviroVar);
  if Length(strBDSDir) > 0 then
  begin
    R := TRegIniFile.Create(Format(strHelpRegKey, [GetIDERegPoint(), GetIDEVersionNum(strBDSDir)]));
    try
      for eTokenType := Low(TDNTokenType) to High(TDNTokenType) do
        ReadHighlight(R, strTokenHighlightMap[eTokenType], Result[eTokenType]);
      iBGColour := Result[ttPlainText].FBackColour;
    finally
      R.Free;
    end;
  end;
end;

(**

  This method searches the IDEs command line parameters for an alternate registration point (-rXxxxx)
  and returns that alternate point instead of the standard BDS if found.

  @precon  None.
  @postcon Returns the activty IDEs registration point.

  @return  a String

**)
function TITHIDEEditorColours.GetIDERegPoint: string;
const
  strDefaultRegPoint = 'BDS';
  iSwitchLen = 2;
var
  iParam: Integer;
begin
  Result := strDefaultRegPoint;
  for iParam := 1 to ParamCount do
    if CompareText(Copy(ParamStr(iParam), 1, iSwitchLen), '-r') = 0 then
    begin
      Result := ParamStr(iParam);
      System.Delete(Result, 1, iSwitchLen);
      Break;
    end;
end;

(**

  This method returns the IDEs version number from the end of the BDS environment variable passed.

  @precon  None.
  @postcon the version number is returned.

  @param   strBDSDir as a String as a constant
  @return  a String

**)
function TITHIDEEditorColours.GetIDEVersionNum(const strBDSDir: string): string;
begin
  Result := ExtractFileName(strBDSDir);
end;

(**

  This method reads an IDE Editor Token inforamtion from the given registry.

  @precon  Reg must be a valid instance.
  @postcon The token is read from the registry.

  @note    All values are stored in the registry as STRINGs.

  @param   Reg            as a TRegIniFile as a constant
  @param   strSectionName as a String as a constant
  @param   TokenFontInfo  as a TDNTokenInfo as a reference

**)
procedure TITHIDEEditorColours.ReadHighlight(const Reg: TRegIniFile; const strSectionName: string; var TokenFontInfo: TDNTokenInfo);
const
  strDefaultForeground = 'Default Foreground';
  strForegroundColorNew = 'Foreground Color New';
  strDefaultBackground = 'Default Background';
  strBackgroundColorNew = 'Background Color New';
  strBold = 'Bold';
  strItalic = 'Italic';
  strUnderline = 'Underline';
  strTrue = 'True';
  strFalse = 'False';
begin
  // Foreground
  if CompareText(Reg.ReadString(strSectionName, strDefaultForeground, strTrue), strTrue) = 0 then
    TokenFontInfo.FForeColour := clNone
  else
    TokenFontInfo.FForeColour := StringToColor(Reg.ReadString(strSectionName, strForegroundColorNew, ColorToString(TokenFontInfo.FForeColour)));
  // Background
  if CompareText(Reg.ReadString(strSectionName, strDefaultBackground, strTrue), strTrue) = 0 then
    TokenFontInfo.FBackColour := clNone
  else
    TokenFontInfo.FBackColour := StringToColor(Reg.ReadString(strSectionName, strBackgroundColorNew, ColorToString(TokenFontInfo.FBackColour)));
  // Styles
  TokenFontInfo.FFontStyles := [];
  if CompareText(Reg.ReadString(strSectionName, strBold, strFalse), strTrue) = 0 then
    Include(TokenFontInfo.FFontStyles, fsBold);
  if CompareText(Reg.ReadString(strSectionName, strItalic, strFalse), strTrue) = 0 then
    Include(TokenFontInfo.FFontStyles, fsItalic);
  if CompareText(Reg.ReadString(strSectionName, strUnderline, strFalse), strTrue) = 0 then
    Include(TokenFontInfo.FFontStyles, fsUnderline);
end;

end.

