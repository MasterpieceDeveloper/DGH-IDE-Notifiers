(**

  This module contains an interfaced class which manages module notifier indexes using their filenames.

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
unit DGHIDENotifiers.ModuleNotifierCollection;

interface

uses
  Generics.Collections,
  DGHIDENotifiers.Interfaces;

{$INCLUDE 'CompilerDefinitions.inc'}

type
  (** A class to manage module notifiers. **)
  TDINModuleNotifierList = class(TInterfacedObject, IDINModuleNotifierList)
  strict private
    type
      (** A record to describe the properties of a Module, project or Form notifier. @nohints **)
      TModuleNotifierRec = record
      strict private
        FFileName: string;
        FNotifierIndex: Integer;
      public
        constructor Create(const strFileName: string; const iIndex: Integer);
        (**
          A property to return the filename for the notifier record.
          @precon  None.
          @postcon Returns the filename associated with the notifier.
          @return  a String
        **)
        property FileName: string read FFileName write FFileName;
        (**
          A property to return the notifier index for the notifier record.
          @precon  None.
          @postcon Returns the notifier index associated with the notifier.
          @return  a Integer
        **)
        property NotifierIndex: Integer read FNotifierIndex;
      end;
  strict private
    FModuleNotifierList: TList<TModuleNotifierRec>;
  {$IFDEF D2010}   strict {$ENDIF} protected
    procedure Add(const strFileName: string; const iIndex: Integer);
    function Remove(const strFileName: string): Integer;
    procedure Rename(const strOldFileName: string; const strNewFileName: string);
    function Find(const strFileName: string; var iIndex: Integer): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  SysUtils;

(**

  This is a constructor for the TModNotRec record which describes the attributes
  to be stored for each module / project / form notifier registered.

  @precon  None.
  @postcon Initialises the record.

  @param   strFileName   as a String as a constant
  @param   iIndex        as an Integer as a constant

**)
constructor TDINModuleNotifierList.TModuleNotifierRec.Create(const strFileName: string; const iIndex: Integer {: @ debug Const eNotifierType: TDGHIDENotification } );
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod('TDINModuleNotifierList.TModuleNotifierRec.Create', tmoTiming); {$ENDIF}
  FFileName := strFileName;
  FNotifierIndex := iIndex;
end;

(**

  This method adds the module filename and index to the collection.

  @precon  None.
  @postcon The modules filename and index is added to the list.

  @param   strFileName as a String as a constant
  @param   iIndex      as an Integer as a constant

**)
procedure TDINModuleNotifierList.Add(const strFileName: string; const iIndex: Integer);
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod(Self, 'Add', tmoTiming); {$ENDIF}
  FModuleNotifierList.Add(TModuleNotifierRec.Create(strFileName, iIndex));
end;

(**

  A constructor for the TDINMOduleNotifierList class.

  @precon  None.
  @postcon Initialises the list.

**)
constructor TDINModuleNotifierList.Create;
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod(Self, 'Create', tmoTiming); {$ENDIF}
  FModuleNotifierList := TList<TModuleNotifierRec>.Create;
end;

(**

  A destructor for the TDINModuleNotifierList class.

  @precon  None.
  @postcon Removes the records from the collection and checks for orphans.

**)
destructor TDINModuleNotifierList.Destroy;
resourcestring
  strDestroyOrphanedModuleNotifier = 'Destroy(Orphaned Module Notifier)';
var
  iModule: Integer;
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod(Self, 'Destroy', tmoTiming); {$ENDIF}
  for iModule := FModuleNotifierList.Count - 1 downto 0 do
  begin
      {$IFDEF DEBUG}
    CodeSite.Send(csmWarning, strDestroyOrphanedModuleNotifier, FModuleNotifierList[iModule].FileName);
      {$ENDIF}
    FModuleNotifierList.Delete(iModule);
      //: @note Cannot remove any left over notifiers here as the module
      //:       is most likely closed at ths point however there should not be any anyway.
  end;
  FModuleNotifierList.Free;
  inherited Destroy;
end;

(**

  This method searches for the given filename in the collection and if found returns
  true with the index in iIndex else returns false.

  @precon  None.
  @postcon Either trues the true with the index of the found item or returns false.

  @param   strFileName as a String as a constant
  @param   iIndex      as an Integer as a reference
  @return  a Boolean

**)
function TDINModuleNotifierList.Find(const strFileName: string; var iIndex: Integer): Boolean;
var
  iModNotIdx: Integer;
  R: TModuleNotifierRec;
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod(Self, 'Find', tmoTiming); {$ENDIF}
  Result := False;
  iIndex := -1;
  for iModNotIdx := 0 to FModuleNotifierList.Count - 1 do
  begin
    R := FModuleNotifierList.Items[iModNotIdx];
    if CompareText(R.FileName, strFileName) = 0 then
    begin
      iIndex := iModNotIdx;
      Result := True;
      Break;
    end;
  end;
end;

(**

  This method removes the named file from the notifier list.

  @precon  None.
  @postcon The named file is removed from the notifier list if found.

  @param   strFileName as a String as a constant
  @return  an Integer

**)
function TDINModuleNotifierList.Remove(const strFileName: string): Integer;
var
  iModuleIndex: Integer;
  R: TModuleNotifierRec;
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod(Self, 'Remove', tmoTiming); {$ENDIF}
  Result := -1;
  if Find(strFileName, iModuleIndex) then
  begin
    R := FModuleNotifierList[iModuleIndex];
    Result := R.NotifierIndex;
    FModuleNotifierList.Delete(iModuleIndex);
  end;
end;

(**

  This method renames the module notifier record when the modules name is changed so that the correct
  index can be retrieved when closing the module.

  @precon  None.
  @postcon Updates the modules filename.

  @param   strOldFileName as a String as a constant
  @param   strNewFileName as a String as a constant

**)
procedure TDINModuleNotifierList.Rename(const strOldFileName, strNewFileName: string);
var
  iIndex: Integer;
  R: TModuleNotifierRec;
begin
  {$IFDEF CODESITE}  CodeSite.TraceMethod(Self, 'Rename', tmoTiming); {$ENDIF}
  if Find(strOldFileName, iIndex) then
  begin
    R := FModuleNotifierList[iIndex];
    R.FileName := strNewFileName;
    FModuleNotifierList[iIndex] := R;
  end;
end;

end.

