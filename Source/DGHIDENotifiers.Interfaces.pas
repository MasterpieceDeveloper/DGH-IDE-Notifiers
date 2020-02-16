(**

  This module contains interfaces for implementing functionality in the plug-in along with simple types
  that the interfaces rely upon.

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
unit DGHIDENotifiers.Interfaces;

interface

uses
  VCL.Graphics;

type
  (** An enumerate to define the token types for the notification information output. **)
  TDNTokenType = (ttUnknown, ttWhiteSpace, ttReservedWord, ttIdentifier, ttNumber, ttSymbol, ttSingleLiteral, ttDoubleLiteral, ttComment, ttDirective, ttCompilerDirective, ttPlainText, ttSelection);

  (** A recofrd to descrieb the font information required for rendering then text. **)
  TDNTokenInfo = record
    FForeColour: TColor;
    FBackColour: TColor;
    FFontStyles: TFontStyles;
  end;

  (** A type which defines an array of token information records for each token type./ **)
  TDNTokenFontInfoTokenSet = array[TDNTokenType] of TDNTokenInfo;

  (** This interface allows a module notifier to have the indexed file renamed for removing the
      notifier from the IDE. **)
  IDINModuleNotifierList = interface
    ['{60E0D688-F529-4798-A06C-C283F800B7FE}']
    procedure Add(const strFileName: string; const iIndex: Integer);
    function Remove(const strFileName: string): Integer;
    procedure Rename(const strOldFileName, strNewFileName: string);
  end;

  (** An interface to get the IDE Editor Colours from the Registry. **)
  IDNIDEEditorColours = interface
    ['{F22B94E8-CAEC-4BD8-B877-C793CA1308AA}']
    function GetIDEEditorColours(var iBGColour: TColor): TDNTokenFontInfoTokenSet;
  end;

  (** This is an event signature that need to the implemented by module and project notifiers so that
      the module notifier lists can be updated. **)
  TDNModuleRenameEvent = procedure(const strOldFilename, strNewFilename: string) of object;

implementation

end.

