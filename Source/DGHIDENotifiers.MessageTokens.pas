(**

  This module contains a class which tokenizes a message string into different types of token and
  returns a collection of those tokens for the log view to render as required.

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
unit DGHIDENotifiers.MessageTokens;

interface

{$INCLUDE 'CompilerDefinitions.inc'}

{$IFDEF DXE00}
{$DEFINE REGULAREXPRESSIONS}
{$ENDIF}

uses
  {$IFDEF REGULAREXPRESSIONS}
  RegularExpressions,
  {$ENDIF}
  Generics.Collections,
  DGHIDENotifiers.Interfaces;

type
  (** A record to describe the information required to be stored for a message token. **)
  TDNToken = record
  strict private
    //: @nohints
    FToken: string;
    //: @nohints
    FTokenType: TDNTokenType;
    //: @nohints
    FRegExMatch: Boolean;
  public
    constructor Create(const strToken: string; const eTokenType: TDNTokenType; const boolRegExMatch: Boolean);
    (**
      This property returns the text of the token.
      @precon  None
      @postcon Returns the text of the token.
      @return  a String
    **)
    property Text: string read FToken;
    (**
      This property returns the type of the token.
      @precon  None
      @postcon Returns the type of the token.
      @return  a TDNTokenType
    **)
    property TokenType: TDNTokenType read FTokenType;
    (**
      This property returns whether the token is a regular expression match.
      @precon  None.
      @postcon Returns whether the token is a regular expression match.
      @return  a Boolean
    **)
    property RegExMatch: Boolean read FRegExMatch;
  end;

  (** A class to tokenize the message streams. **)
  TDNMessageTokenizer = class
  strict private
    FTokens: TList<TDNToken>;
    FMessage: string;
    FMsgPos: Integer;
    {$IFDEF REGULAREXPRESSIONS}
    FRegEx: TRegEx;
    FMatches: TMatchCollection;
    {$ENDIF}
    FIsFiltering: Boolean;
  strict protected
    function GetCount: Integer;
    function GetToken(const iIndex: Integer): TDNToken;
    function GetCurChar: Char; inline;
    procedure TokenizeStream;
    procedure ParseInterface;
    procedure ParseIdentifier;
    procedure ParseMethodName;
    procedure ParseModuleName;
    procedure ParseParameters;
    procedure ParseSpace;
    procedure ParseParameter;
    procedure ParseRemainingCharacters;
    procedure AddToken(const strToken: string; const eTokenType: TDNTokenType; const iPosition: Integer); overload;
    procedure AddToken(const strToken: string; const eTokenType: TDNTokenType; const boolMatch: Boolean); overload;
  public
    constructor Create(const strMessage, strRegEx: string);
    destructor Destroy; override;
    (**
      This property returns the number of tokens in the collection.
      @precon  None.
      @postcon Returns the number of tokens in the collection.
      @return  an Integer
    **)
    property Count: Integer read GetCount;
    (**
      This property returns the indexed token from the collection.
      @precon  iIndex must be a valid index between 0 and Count - 1.
      @postcon Returns the indexed token from the collection.
      @param   iIndex as an Integer as a constant
      @return  a TDNToken
    **)
    property Token[const iIndex: Integer]: TDNToken read GetToken; Default;
  end;

implementation

uses
  {$IFDEF REGULAREXPRESSIONS}
  RegularExpressionsCore,
  {$ENDIF}
  SysUtils;

{ TDNToken }

(**

  A constructor for the TDNToken record.

  @precon  None.
  @postcon Initialises the record.

  @param   strToken       as a String as a constant
  @param   eTokenType     as a TDNTokenType as a constant
  @param   boolRegExMatch as a Boolean as a constant

**)
constructor TDNToken.Create(const strToken: string; const eTokenType: TDNTokenType; const boolRegExMatch: Boolean);
begin
  FToken := strToken;
  FTokenType := eTokenType;
  FRegExMatch := boolRegExMatch;
end;

{ TDNMessageTokenizer }

(**

  This method adds the passed token to the collection is it is not empty.

  @precon  None.
  @postcon The token is added to the collection if not empty.

  @param   strToken   as a String as a constant
  @param   eTokenType as a TDNTokenType as a constant
  @param   boolMatch  as a Boolean as a constant

**)
procedure TDNMessageTokenizer.AddToken(const strToken: string; const eTokenType: TDNTokenType; const boolMatch: Boolean);
begin
  if Length(strToken) > 0 then
    FTokens.Add(TDNToken.Create(strToken, eTokenType, boolMatch));
end;

(**

  This method breaks down the token into sub tokens if it matches the search criteria.

  @precon  None.
  @postcon the token is brokwn down by the search criteria.

  @param   strToken   as a String as a constant
  @param   eTokenType as a TDNTokenType as a constant
  @param   iPosition  as an Integer as a constant

**)
procedure TDNMessageTokenizer.AddToken(const strToken: string; const eTokenType: TDNTokenType; const iPosition: Integer); //FI:O804

{$IFDEF REGULAREXPRESSIONS}
var
  iMatch: Integer;
  M: TMatch;
  iStart: Integer;
  iEnd: Integer;
  iIndex: Integer;
{$ENDIF}

begin
  if Length(strToken) > 0 then
    {$IFDEF REGULAREXPRESSIONS}
    if FIsFiltering and (FMatches.Count > 0) then
    begin
      iStart := 1;
      for iMatch := 0 to FMatches.Count - 1 do
      begin
        M := FMatches[iMatch];
        iIndex := M.Index - iPosition + 1;
        if iIndex > iStart then
        begin
                // Non match at start of token
          iEnd := iIndex; // One passed end point
          AddToken(Copy(strToken, iStart, iEnd - iStart), eTokenType, False);
          iStart := iEnd;
                // Match
          Inc(iEnd, M.Length);
          AddToken(Copy(strToken, iStart, iEnd - iStart), eTokenType, True);
          iStart := iEnd;
        end
        else            // Match at start of token
if iIndex + M.Length - 1 > iStart then
        begin
          iEnd := iIndex + M.Length;
          AddToken(Copy(strToken, iStart, iEnd - iStart), eTokenType, True);
          iStart := iEnd;
        end;
      end;
        // Check end...
      if Length(strToken) >= iStart then
        AddToken(Copy(strToken, iStart, Length(strToken) - iStart + 1), eTokenType, False);
    end
    else    {$ENDIF}
      AddToken(strToken, eTokenType, False);
end;

(**

  A constructor for the TDNMessageTokenizer class.

  @precon  None.
  @postcon Intialises the class as an empty collection and starts the parsing of the message.

  @param   strMessage as a String as a constant
  @param   strRegEx   as a String as a constant

**)
constructor TDNMessageTokenizer.Create(const strMessage, strRegEx: string);
begin
  FTokens := TList<TDNToken>.Create;
  FMessage := strMessage;
  FMsgPos := 1;
  FIsFiltering := False;
  if Length(strRegEx) > 0 then
  begin
      {$IFDEF REGULAREXPRESSIONS}
    try
      FRegEx := TRegEx.Create(strRegEx, [roIgnoreCase, roCompiled, roSingleLine]);
      FMatches := FRegEx.Matches(strMessage);
      {$ENDIF}
      FIsFiltering := True;
      {$IFDEF REGULAREXPRESSIONS}
    except
      on E: ERegularExpressionError do
        FIsFiltering := False;
    end;
      {$ENDIF}
  end;
  if Length(FMessage) > 0 then
    TokenizeStream;
end;

(**

  A destructor for the TDMMessageTokenizer class.

  @precon  None.
  @postcon Frees the memory used by the class.

**)
destructor TDNMessageTokenizer.Destroy;
begin
  FTokens.Free;
  inherited;
end;

(**

  This is a getter method for the Count property.

  @precon  None.
  @postcon Returns the number of tokens in the collection.

  @return  an Integer

**)
function TDNMessageTokenizer.GetCount: Integer;
begin
  Result := FTokens.Count;
end;

(**

  This method returns the current character in the message stream if valid else will return a null
  character.

  @precon  None.
  @postcon Returns the current character in the stream else a null character to indicate the end of the
           stream.

  @return  a Char

**)
function TDNMessageTokenizer.GetCurChar: Char;
begin
  Result := #0;
  if FMsgPos <= Length(FMessage) then
    Result := FMessage[FMsgPos];
end;

(**

  This is a getter method for the Token property.

  @precon  iIndex must be a valid index between 0 and Count - 1.
  @postcon Returns the indexed token from the collection.

  @param   iIndex as an Integer as a constant
  @return  a TDNToken

**)
function TDNMessageTokenizer.GetToken(const iIndex: Integer): TDNToken;
begin
  Result := FTokens[iIndex];
end;

(**

  This method parses the identifier at the current position in the message stream.

  @precon  None.
  @postcon The identifier at the current stream position is parsed and the stream position advanced to
           the end of the identifier.

**)
procedure TDNMessageTokenizer.ParseIdentifier;
var
  strToken: string;
  iTokenLen: Integer;
  iPosition: Integer;
begin
  SetLength(strToken, Length(FMessage));
  iTokenLen := 0;
  if GetCurChar <> #0 then
  begin
    iPosition := FMsgPos;
    case FMessage[FMsgPos] of
      'a'..'z', 'A'..'Z':
        begin
          Inc(iTokenLen);
          strToken[iTokenLen] := FMessage[FMsgPos];
          Inc(FMsgPos);
        end;
    end;
    while FMsgPos <= Length(FMessage) do
    begin
      case FMessage[FMsgPos] of
        'a'..'z', 'A'..'Z', '0'..'9':
          begin
            Inc(iTokenLen);
            strToken[iTokenLen] := FMessage[FMsgPos];
            Inc(FMsgPos);
          end;
      else
        Break;
      end;
    end;
    SetLength(strToken, iTokenLen);
    AddToken(strToken, ttReservedWord, iPosition);
  end;
end;

(**

  This method parse the initial interface of the message by delegating the task to the sub-method for
  parsing identifiers.

  @precon  None.
  @postcon The interface is parsed.

**)
procedure TDNMessageTokenizer.ParseInterface;
begin
  ParseIdentifier;
end;

(**

  This method parse a methodname in the message by delegating the task to the sub-method for
  parsing identifiers.

  @precon  None.
  @postcon The methodname is parsed.

**)
procedure TDNMessageTokenizer.ParseMethodName;
begin
  ParseIdentifier;
end;

(**

  This method parses the a modulename at the current position in the message stream.

  @precon  None.
  @postcon The modulename at the current stream position is parsed and the stream position advanced to
           the end of the modulename.

**)
procedure TDNMessageTokenizer.ParseModuleName;
var
  strToken: string;
  iTokenLen: Integer;
  iPosition: Integer;
begin
  if GetCurChar = '(' then
  begin
    AddToken(GetCurChar, ttSymbol, FMsgPos);
    Inc(FMsgPos);
    iPosition := FMsgPos;
    SetLength(strToken, Length(FMessage));
    iTokenLen := 0;
    while not CharInSet(GetCurChar, [#0, ')']) do
    begin
      Inc(iTokenLen);
      strToken[iTokenLen] := FMessage[FMsgPos];
      Inc(FMsgPos);
    end;
    SetLength(strToken, iTokenLen);
    AddToken(strToken, ttIdentifier, iPosition);
    if GetCurChar = ')' then
    begin
      AddToken(GetCurChar, ttSymbol, FMsgPos);
      Inc(FMsgPos);
    end;
  end;
end;

(**

  This method parses the a parameter at the current position in the message stream.

  @precon  None.
  @postcon The parameter at the current stream position is parsed and the stream position advanced to
           the end of the parameter.

**)
procedure TDNMessageTokenizer.ParseParameter;
var
  strToken: string;
  iTokenLen: Integer;
  iPosition: Integer;
  dblValue: Double;
  iErrorCode: Integer;
begin
  ParseIdentifier;
  while GetCurChar = '.' do // Handle qualified tokens.
  begin
    AddToken(GetCurChar, ttSymbol, FMsgPos);
    Inc(FMsgPos);
    ParseIdentifier;
  end;
  if GetCurChar = ':' then
  begin
    AddToken(GetCurChar, ttSymbol, FMsgPos);
    Inc(FMsgPos);
    iPosition := FMsgPos;
    SetLength(strToken, Length(FMessage));
    iTokenLen := 0;
    while not CharInSet(GetCurChar, [#0, ',']) do
    begin
      Inc(iTokenLen);
      strToken[iTokenLen] := FMessage[FMsgPos];
      Inc(FMsgPos);
    end;
    SetLength(strToken, iTokenLen);
    Val(strToken, dblValue, iErrorCode);
    if iErrorCode = 0 then
      AddToken(strToken, ttNumber, iPosition)
    else
      AddToken(strToken, ttIdentifier, iPosition);
  end;
end;

(**

  This method parses the a sequence of parameters at the current position in the message stream.

  @precon  None.
  @postcon The parameters at the current stream position are parsed and the stream position advanced to
           the end of the parameters.

**)
procedure TDNMessageTokenizer.ParseParameters;
begin
  ParseSpace;
  if GetCurChar = '=' then
  begin
    AddToken(GetCurChar, ttSymbol, FMsgPos);
    Inc(FMsgPos);
    ParseSpace;
    ParseParameter;
    while GetCurChar = ',' do
    begin
      AddToken(GetCurChar, ttSymbol, FMsgPos);
      Inc(FMsgPos);
      ParseSpace;
      ParseParameter;
    end;
  end;
end;

(**

  This method parses any remaining characters as unknown to signify that the parser has failed to parse
  all the text.

  @precon  None.
  @postcon The remaining unparsed characters in the message are parsed.

**)
procedure TDNMessageTokenizer.ParseRemainingCharacters;
var
  strToken: string;
  iTokenLen: Integer;
  iPosition: Integer;
begin
  iPosition := FMsgPos;
  SetLength(strToken, Length(FMessage));
  iTokenLen := 0;
  while GetCurChar <> #0 do
  begin
    Inc(iTokenLen);
    strToken[iTokenLen] := GetCurChar;
    Inc(FMsgPos);
  end;
  SetLength(strToken, iTokenLen);
  AddToken(strToken, ttUnknown, iPosition);
end;

(**

  This method will eat a single space character in the message stream.

  @precon  None.
  @postcon A space in the message stream is eaten and added as a token.

**)
procedure TDNMessageTokenizer.ParseSpace;
begin
  if GetCurChar = #32 then
  begin
    AddToken(GetCurChar, ttWhiteSpace, FMsgPos);
    Inc(FMsgPos);
  end;
end;

(**

  This method starts the parsing of the messafe text based on the grammar.

  @see     See the grammar file "Message Parser Grammar.bnf"

  @precon  None.
  @postcon The message is parsed and tokenized into the token collection.

**)
procedure TDNMessageTokenizer.TokenizeStream;
begin
  ParseInterface;
  ParseModuleName;
  if GetCurChar = '.' then
  begin
    AddToken(GetCurChar, ttSymbol, FMsgPos);
    Inc(FMsgPos);
    ParseMethodName;
    ParseParameters;
  end;
  ParseRemainingCharacters;
end;

end.

