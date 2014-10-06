(*
** CLARION 2.X TOOLKIT
** Copyright (C) by Dmitry Koudryavtsev
** http://juliasoft.chat.ru
** juliasoft@mail.ru
*)
Program Convert;
{$APPTYPE CONSOLE}
{$A-$X+}
Uses DB, ClDB, Clarion, DBTables, SysUtils, Classes;

type
  PDateRec = ^TDateRec;
  TDateRec = record
    Lo,Hi : Integer;
  end;

function StringToVarArray(Src : String; aDim, aType : Integer) : Variant;
Var
  i, j, k, aVarType : Integer;
  S : String;
begin
  case aType of
    FLD_LONG,
    FLD_BYTE,
    FLD_SHORT:   aVarType := varInteger;
    FLD_REAL,
    FLD_DECIMAL: aVarType := varDouble;
  else  // FLD_PICTURE, FLD_STRING :
    aVarType := varOleStr;
  end;
//  try
    Result := VarArrayCreate([0, aDim], aVarType);
    i := 0; j := 1;
    for k := 0 to aDim - 1 do begin
      i := Pos(';', Copy(Src, j, Length(Src))) + i;
      S := Copy(Src, j, i - j);
      j := i + 1;
      case aVarType of
        varSmallInt,
        varByte,
        varInteger : Result[k] := StrToInt(S);
        varDouble :
          begin
            if Pos('.', S) > 0 then
              S[Pos('.', S)] := DecimalSeparator;
            Result[k] := StrToFloat(S);
          end;
        varOleStr : Result[k] := S;
      end; // case
    end; // for
//  except
//
//  end;
end;

Var
  DbfTable : TTable;
  BadDat, NewDat : TCTClarion;
  i, dbf_no : integer;
  B : Byte;
  Sh : SmallInt;
  Dbl : Real;
  L, K : Integer;
  S : String;
  DT : TDateTime;
  DataHeader : TDataHeader;
  Buf, P : PChar;
  Bcd : array [0..31] of Byte;
  Year, Month, Day : Word;
//
  DataArray : Variant;
  arrI, elmLen : Integer;
  pwdID : Word;
// 1.12
Const
  GroupOffset : Integer = 0;
//  C1, C2 : Byte;
//  FldLen : Integer;
BEGIN
  WriteLn('DBF2DAT: dBASE DBF to Clarion DAT Converter. v1.0');
  WriteLn('Under GNU public license. Volgograd, RUSSIA, 2000-2001');
  WriteLn('Copyright (C) by Dmitry Koudryavtsev, juliasoft@mail.ru');
  if ParamCount <> 3 then begin
    WriteLn('USAGE: DBF2DAT.EXE <Source.Dbf> <Template.Dat> <Destination.Dat>');
    WriteLn('EXAMPLE: DBF2DAT ACC.DBF ACC.DAT ACC.NEW');
    exit;
  end;

  DbfTable := TTable.Create(Nil);
  DbfTable.TableName := ParamStr(1);

  try
    DbfTable.Open;
  except
    WriteLn('ERROR:Can'#39'open ', ParamStr(1));
    exit;
  end;

  BadDat := TCTClarion.Create(Nil);
  BadDat.FileName := ParamStr(2);
  try
    BadDat.Open;
    PwdID := BadDat.PwdID;
  except
    WriteLn('ERROR:Can'#39'open template file ', ParamStr(2));
    exit;
  end;

  NewDat := TCTClarion.Create(Nil);
  NewDat.Assign(BadDat);
  NewDat.Read_Only := False;
  NewDat.Exclusive := True;
  NewDat.FileName := ParamStr(3);
  try
    NewDat.CreateFile;
  except
    WriteLn('ERROR:Can'#39'create destination file ', ParamStr(3));
    exit;
  end;

  BadDat.Close;
  BadDat.Free;

  DataHeader.RHd := 2;
  DataHeader.RPtr := 0;

  GetMem(Buf, NewDat.GetBufLen);
  DbfTable.First;
  while NOT DbfTable.Eof do begin
    dbf_no := 0;
    FillChar(Buf^, NewDat.GetBufLen, #32);
    Move(DataHeader, Buf^, sizeof(TDataHeader)); // write record header
    for i := 0 to NewDat.GetFieldCount - 1 do begin { for all fields do... }
      // 1.12
      if NewDat.Fields[i].GetFieldType = FLD_GROUP then begin
        if NewDat.Fields[i].IsArray then
          GroupOffset := NewDat.Arrays[NewDat.Fields[i].GetArrayNumber-1].GetDimLen(0)
        else
          GroupOffset := 0;
        continue;
      end;
      // array processing
      if NewDat.Fields[i].IsArray then begin
        DataArray := StringToVarArray(DbfTable.Fields[dbf_no].AsString,
                                      NewDat.Arrays[NewDat.Fields[i].GetArrayNumber-1].GetDim(0),
                                      NewDat.Fields[i].GetFieldType);
        case NewDat.Fields[i].GetFieldType of
          FLD_PICTURE,
          FLD_STRING :
            begin
              elmLen := NewDat.Fields[i].GetFieldSize;
              for arrI := 0 to VarArrayHighBound(DataArray, 1) - 1 do begin
                S := CharToOem(DataArray[arrI]);
                if GroupOffset > 0 then
                  P := @Buf[NewDat.Fields[i].GetFieldOffs + REC_HEADER_SIZE + arrI * GroupOffset]
                else
                  P := @Buf[NewDat.Fields[i].GetFieldOffs + REC_HEADER_SIZE + arrI * elmLen];
                Move((@S[1])^, P^, Length(S));
              end;
            end;
          FLD_BYTE:
            begin
              elmLen := NewDat.Fields[i].GetFieldSize;
              for arrI := 0 to VarArrayHighBound(DataArray, 1) - 1 do begin
                B := DataArray[arrI];
                if GroupOffset > 0 then
                  P := @Buf[NewDat.Fields[i].GetFieldOffs + REC_HEADER_SIZE + arrI * GroupOffset]
                else
                  P := @Buf[NewDat.Fields[i].GetFieldOffs + REC_HEADER_SIZE + arrI * elmLen];
                Move(B, P^, NewDat.Fields[i].GetFieldSize);
              end;
            end;
          FLD_SHORT:
            begin
              elmLen := NewDat.Fields[i].GetFieldSize;
              for arrI := 0 to VarArrayHighBound(DataArray, 1) - 1 do begin
                Sh := DataArray[arrI];
                if GroupOffset > 0 then
                  P := @Buf[NewDat.Fields[i].GetFieldOffs + REC_HEADER_SIZE + arrI * GroupOffset]
                else
                  P := @Buf[NewDat.Fields[i].GetFieldOffs + REC_HEADER_SIZE + arrI * elmLen];
                Move(Sh, P^, NewDat.Fields[i].GetFieldSize);
              end;
            end;
          FLD_LONG:
            begin
              elmLen := NewDat.Fields[i].GetFieldSize;
              for arrI := 0 to VarArrayHighBound(DataArray, 1) - 1 do begin
                L := DataArray[arrI];
                if GroupOffset > 0 then
                  P := @Buf[NewDat.Fields[i].GetFieldOffs + REC_HEADER_SIZE + arrI * GroupOffset]
                else
                  P := @Buf[NewDat.Fields[i].GetFieldOffs + REC_HEADER_SIZE + arrI * elmLen];
                Move(L, P^, NewDat.Fields[i].GetFieldSize);
              end;
            end;
          FLD_REAL:
            begin
              elmLen := NewDat.Fields[i].GetFieldSize;
              for arrI := 0 to VarArrayHighBound(DataArray, 1) - 1 do begin
                Dbl := DataArray[arrI];
                if GroupOffset > 0 then
                  P := @Buf[NewDat.Fields[i].GetFieldOffs + REC_HEADER_SIZE + arrI * GroupOffset]
                else
                  P := @Buf[NewDat.Fields[i].GetFieldOffs + REC_HEADER_SIZE + arrI * elmLen];
                Move(Dbl, P^, NewDat.Fields[i].GetFieldSize);
              end;
            end;
          FLD_DECIMAL:
            begin
              elmLen := NewDat.Fields[i].GetFieldSize;
              for arrI := 0 to VarArrayHighBound(DataArray, 1) - 1 do begin
                Dbl := DataArray[arrI];
                if GroupOffset > 0 then
                  P := @Buf[NewDat.Fields[i].GetFieldOffs + REC_HEADER_SIZE + arrI * GroupOffset]
                else
                  P := @Buf[NewDat.Fields[i].GetFieldOffs + REC_HEADER_SIZE + arrI * elmLen];
                FillChar(Bcd, sizeof(Bcd), 0);
                DoubleToBCD(NewDat.Fields[i], Dbl, @Bcd);
                Move(Bcd, P^, NewDat.Fields[i].GetFieldSize);
              end;
            end;
        end;
        DataArray := Unassigned;
        Inc(dbf_no);
        continue;
      end;
      if Pos('DATE', DbfTable.Fields[dbf_no].FieldName) > 0 then begin
        try
          DT := DbfTable.Fields[dbf_no].AsDateTime;
          DecodeDate(DT, Year, Month, Day);
          if (Year = 1800) or (year = 1900) then year := Year;
          DT := EncodeDate(Year, Month, Day);
          K := Trunc(DT + 36161);
        except
          K := DbfTable.Fields[dbf_no].AsInteger;
        end;
        P := @Buf[NewDat.Fields[i].GetFieldOffs+REC_HEADER_SIZE];
        Move(K, P^, NewDat.Fields[i].GetFieldSize);
        { Write FLD_LONG }
      end else
        case NewDat.Fields[i].GetFieldType of
          FLD_PICTURE,
          FLD_STRING :
            begin
              S := CharToOem(DbfTable.Fields[dbf_no].AsString);
              P := @Buf[NewDat.Fields[i].GetFieldOffs+REC_HEADER_SIZE];
              Move((@S[1])^, P^, Length(S));
            end;
          FLD_BYTE:
            begin
              B := DbfTable.Fields[dbf_no].AsInteger;
              P := @Buf[NewDat.Fields[i].GetFieldOffs+REC_HEADER_SIZE];
              Move(B, P^, NewDat.Fields[i].GetFieldSize);
            end;
          FLD_SHORT:
            begin
              Sh := DbfTable.Fields[dbf_no].AsInteger;
              P := @Buf[NewDat.Fields[i].GetFieldOffs+REC_HEADER_SIZE];
              Move(Sh, P^, NewDat.Fields[i].GetFieldSize);
            end;
          FLD_LONG:
            begin
              L := DbfTable.Fields[dbf_no].AsInteger;
              P := @Buf[NewDat.Fields[i].GetFieldOffs+REC_HEADER_SIZE];
              Move(L, P^, NewDat.Fields[i].GetFieldSize);
            end;
          FLD_REAL:
            begin
              Dbl := DbfTable.Fields[dbf_no].AsFloat;
              P := @Buf[NewDat.Fields[i].GetFieldOffs+REC_HEADER_SIZE];
              Move(Dbl, P^, NewDat.Fields[i].GetFieldSize);
            end;
          FLD_DECIMAL:
            begin
              Dbl := DbfTable.Fields[dbf_no].AsFloat;
              P := @Buf[NewDat.Fields[i].GetFieldOffs+REC_HEADER_SIZE];
              FillChar(Bcd, sizeof(Bcd), 0);
              DoubleToBCD(NewDat.Fields[i], Dbl, @Bcd);
              {
              FldLen := NewDat.Fields[i].GetFieldSize +
                       (NewDat.Fields[i].GetFieldSize mod 2);
              S := FloatToStr(Dbl);
              if S[0] = '-' then C1 := $F0 else C1 := Byte(S[0]);
              C2 := S[1];
              Bcd[0] := (C1 XOR 48) AND (C2 SHL 4);
              }
              {
              NewDat.Fields[i].DecDec := Length(S) - Pos(',', S);
              NewDat.Fields[i].DecSig := Pos(',', S);
              if S[1] = '-' then Bcd[0] := Bcd[0] AND $F0;
              }
              Move(Bcd, P^, NewDat.Fields[i].GetFieldSize);
            end;
          else
            WriteLn('Something shit !!!');
        end; // case
      inc(dbf_no);
    end;
    if DbfTable.RecNo mod 100 = 0 then Write(DbfTable.RecNo, #13);
    if NewDat.IsEncrypted then
      DecodeBuffer(Buf[REC_HEADER_SIZE], NewDat.GetBufLen - REC_HEADER_SIZE, pwdID);
    FileWrite(NewDat._File, Buf^, NewDat.GetBufLen);
    DbfTable.Next;
  end;
  WriteLn(DbfTable.RecNo);
  { Old code
  FileSeek(NewDat._File, 5, 0);
  I := DbfTable.RecNo;
  FileWrite(NewDat._File, I, 2);
  } // New Code
  FileSeek(NewDat._File, 0, 0);
  NewDat.NumOfRec := DbfTable.RecNo;
  NewDat.ChkSum := NewDat.CalcCheckSum;
  NewDat.WriteHeader;

  NewDat.Close;
  NewDat.Free;
  FreeMem(Buf);
  DbfTable.Close;
  DbfTable.Free;
END.