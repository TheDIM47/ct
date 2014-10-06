(*
** CLARION TO INTERBASE GDB CONVERTER
** Copyright (C) by Dmitry Koudryavtsev
** Under GNU Public License
*)
Unit incinfo;
{$APPTYPE CONSOLE}
interface

Uses Classes, SysUtils;

function GetIncInfo(AOffID, ACDbID : Byte; AName : String) : Longint;
{- Get incremental information }

procedure UpdateIncInfo(AOffID, ACDbID : Byte; AName : String; ACnt : Longint);
{- Update incremental information }

implementation

type
  PIIRecord = ^TIIRecord;
  TIIRecord = record
    OffID,
    CDbID   : Byte;
    TblName : String[8];
    RecNum  : LongInt;
  end;

Const
  II_FILE = 'incinfo.bin';

Var
  IIList : TList;

function GetIncInfo(AOffID, ACDbID : Byte; AName : String) : Longint;
var
  i : integer;
begin
  Result := 0;
  if IIList.Count > 0 then begin
    i := IIList.Count - 1;
    repeat
      with PIIRecord(IIList[i])^ do
        if (OffID = AOffID) AND (CDbID = ACDbID) AND
           (CompareText(Trim(AName), TblName) = 0) then begin
          Result := RecNum;
          exit;
        end;
      Dec(i);
    until i < 0;
  end;
end;

procedure UpdateIncInfo(AOffID, ACDbID : Byte; AName : String; ACnt : Longint);
var
  i : integer;
  P : PIIRecord;
begin
  if IIList.Count > 0 then begin
    i := IIList.Count - 1;
    repeat
      with PIIRecord(IIList[i])^ do
        if (OffID = AOffID) AND (CDbID = ACDbID) AND
           (CompareText(Trim(AName), TblName) = 0) then begin
          RecNum := ACnt;
          exit;
        end;
      Dec(i);
    until i < 0;
  end;
  New(P);
  FillChar(P^, sizeof(P^), 0);
  with P^ do begin
    OffID  := AOffID;
    CDbID  := ACDbID;
    TblName:= Trim(AName);
    RecNum := ACnt;
  end;
  IIList.Add(P);
end;

// Internal Use Only

procedure ReadIncInfo;
Var
  F : File;
  R : TIIRecord;
begin
  if FileExists(II_FILE) then begin
    Assign(F, II_FILE);
    ReSet(F, 1);
    while not Eof(F) do begin
      BlockRead(F, R, Sizeof(TIIRecord));
      with R do
        UpdateIncInfo(OffID, CDbID, TblName, RecNum);
    end;
    Close(F);
  end;
end;

procedure WriteIncInfo;
Var
  i : integer;
  F : File;
begin
  Assign(F, II_FILE);
  ReWrite(F, 1);
  for i := 0 to IIList.Count - 1 do
    with PIIRecord(IIList[i])^ do
      BlockWrite(F, PIIRecord(IIList[i])^, Sizeof(TIIRecord));
  Close(F);
end;

initialization
  IIList := TList.Create;
  ReadIncInfo;
finalization
  WriteIncInfo;
  IIList.Free;
end.