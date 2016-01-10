(*
** CLARION TO INTERBASE GDB CONVERTER
** Copyright (C) by Dmitry Koudryavtsev
** GNU Public License
*)
Program dat2gdb;
{$APPTYPE CONSOLE}

{$IFDEF LINUX}
{$I ../d2dx.inc}
{$ELSE}
{$I ..\d2dx.inc}
{$I dat2gdb.inc}
{$ENDIF}

{$H+}

uses
{$IFDEF LINUX}
  Libc,
{$ENDIF}
{$IFDEF WIN32}
  Windows,
{$ENDIF}
  sparser, incinfo, DB, SysUtils, Classes,
  IBDatabase,
  IB,
  IBSQL,
//  IBQuery,
//  IBTable,
  IBDatabaseInfo,
  IBHeader,
  cldb, clarion
{$IFDEF VER140}
{$IFDEF USE_VARIANT}
, Variants
{$ENDIF}
{$ENDIF}
  ;

Var
  IbInfo : TIbDatabaseInfo;

function FindFieldName(S : String; Var FList : TList) : Integer;
Var i : Integer;
begin
  Result := -1;
  for i := 0 to FList.Count - 1 do
    if CompareText(S, PFldRecord(FList[i])^.FldName) = 0 then begin
      Result := i;
      exit;
    end;
end;

(***** Utility Functions / For Internal use in Convert routine *****)

function MakeFieldNames(ATable : TCtClarion; AFldDb : TList) : String;
Var
  i, f_idx : integer;
begin
  Result := 'ID,OWNER,UPDATED,USERID,OFFID,CDBID';
  for i := 0 to ATable.GetFieldCount - 1 do
    if ATable.Fields[i].GetFieldType <> FLD_GROUP then begin
      f_idx := FindFieldName(Trim(ATable.Fields[i].GetFieldName), AFldDb);
      if f_idx > -1 then
        Result := Result + ',' + PFldRecord(AFldDb[f_idx])^.FldNewName
      else
        Result := Result + ',' + PatchName(ATable.Fields[i].GetFieldName);
    end; // if <> FLD_GROUP
end;

function MakeCreateTable(AName : String; ATable : TCtClarion; AFldDb : TList) : String;
Var
  i, f_idx, aFldLen : integer;
  S : String;
begin
  Result := 'CREATE TABLE '+ AName + ' (' +
            'ID INTEGER, OWNER INTEGER, UPDATED DATE, USERID VARCHAR(8),' +
            'OFFID SMALLINT, CDBID SMALLINT';
  for i := 0 to ATable.GetFieldCount - 1 do
    if ATable.Fields[i].GetFieldType <> FLD_GROUP then begin
      f_idx := FindFieldName(Trim(ATable.Fields[i].GetFieldName), AFldDb);
      if f_idx > -1 then
        S := PFldRecord(AFldDb[f_idx])^.FldNewName
      else
        S := Trim(PatchName(ATable.Fields[i].GetFieldName));

      (* if ( Pos('DATE', S) > 0 ) OR ( Pos('TIME', S) > 0 ) then
        S := S + ' DATE' *)
      if ( DateSupport AND IsDateField(S) ) then begin
        FDateFields := FDateFields + [i];
        S := S + ' TIMESTAMP';
      end else
      if ( TimeSupport AND IsTimeField(S) ) then begin
        FTimeFields := FTimeFields + [i];
        S := S + ' TIMESTAMP';
      end else
        if ATable.Fields[i].IsArray then begin
          if ArrayAsStr then begin
            // S := S + ' VARCHAR(250)' // Old code
            // v.1.12 below
            aFldLen := ATable.Arrays[ATable.Fields[i].GetArrayNumber - 1].GetDim(0) *
                  (2 + ATable.Arrays[ATable.Fields[i].GetArrayNumber - 1].GetDimLen(0));
            // if aFldLen > 250 then aFldLen := 250; // removed in v1.14
            S := S + ' VARCHAR(' + IntToStr(aFldLen) + ')';
          end else
            S := S + ' VARCHAR(1)';
        end else
          case ATable.Fields[i].GetFieldType of
            FLD_BYTE,
            FLD_SHORT: S := S + ' SMALLINT';
            FLD_LONG:  S := S + ' INTEGER';
            FLD_PICTURE,
            FLD_STRING:
              S := S + ' VARCHAR(' + IntToStr(ATable.Fields[i].GetFieldSize) + ')';
            FLD_REAL: S := S + ' DOUBLE PRECISION';
            FLD_DECIMAL:
              with ATable.Fields[i] do
                S := S + ' DECIMAL('+ IntToStr( GetDecSig + GetDecDec) + ',' +
                                      IntToStr( GetDecDec ) + ')';
          end; // case
      Result := Result + ',' + S;
    end; // if <> FLD_GROUP
  Result := Result + ');';
end;

procedure OpenClarionTable(Var ATable : TCtClarion);
Var
  err : integer;
  ep : boolean;
  {$IFDEF WIN32}
  Handle : LongWord;
  WVer : LongWord;
  {$ENDIF}
begin
  ep := True;
  repeat
    err := 0;
    try
      ATable.Read_Only := True;
      ATable.Exclusive := False;
      ATable.Open;
    except
      if ep then begin
        WriteLn(' Waiting...');
        ep := False;
      end;
      err := 1;
      {$IFDEF WIN32}
      Handle := FindFirstChangeNotification(
                  PChar(@ATable.FileName[1]),
                  False,
                  FILE_NOTIFY_CHANGE_FILE_NAME
                );
//--- Handle should be SYNCHRONYZE access on WinNT
//--- Code below is just a fast workaround
      WVer := Windows.GetVersion;
      if (WVer < $80000000) AND (MSecWait = INFINITE) then MSecWait := 1000;
//---
      WaitForSingleObject( Handle, MsecWait );
      FindCloseChangeNotification( Handle );
      {$ELSE}
      Sleep(MSecWait);
      {$ENDIF}
    end;
  until (err = 0);
end;

(********************************************
**           CONVERT ROUTINE               **
********************************************)
procedure ConvertTable(Var ADb : TIBDatabase;  // IB Database
                          ACDb : TCDbDatabase; // Clarion Database
                         ATIdx : Byte;         // Table Index in List
                        AFldDb : TList);       // Field aliases
Var
  CDbTableName,
  IbTableName : String;

  IQuery : TIBSQL; // TIBQuery;
  ITrans : TIBTransaction;

  CtTable : TCtClarion;
  CtCur   : TCtCursor;

  T1 : TDateTime;
  S, SNames : String;
  XS : array [0..255] of ShortString;
  XD : array [0..255] of Double;
  XB : array [0..255] of Word;
  N : Longint;
  IbFldNo, i : Byte;
  f_idx : integer;
  P, P2 : PChar; // 1.12.D
  ip1 : PChar;   // 1.14
  ip2 : Pointer; // 1.14
  D : Double; // 1.12.D
  x, y : Cardinal; // 1.14
  TableExists : Boolean;
begin
  T1 := Now;
  CDbTableName := CheckSlash(ACDb.CDbPath) + CheckExt(ACDb.CDbTables[ATIdx]);

  IBTableName := UpperCase(RemoveExt(ACDb.CDbTables[ATIdx]));
  WriteLn('CVT: CDB:', ACDb.CDBID, ' FROM:', CDbTableName, ' TO:', IbTableName);

  FDateFields := []; FTimeFields := [];

  IQuery := TIBSQL.Create(Nil);
  ITrans := TIBTransaction.Create(Nil);

  IQuery.Database := ADb;
  IQuery.Transaction := ITrans;
  ITrans.DefaultDatabase := ADb;
  ITrans.DefaultAction := taCommit; { 1.15.2 }

  // Clarion Table
  CtTable := TCtClarion.Create(Nil);
  CtTable.Read_Only := True;
  CtTable.Exclusive := False;
  CtTable.FileName := CDbTableName;

  // Clarion Open
  OpenClarionTable(CtTable);

  // Create Table (if not Exists)
  IQuery.SQL.Clear;
  if IBInfo.BaseLevel < 6 then
    S := 'Select RDB$RELATION_NAME FROM RDB$RELATIONS ' +
         ' WHERE RDB$RELATION_NAME=''' + IbTableName + ''';'
  else
    S := 'Select RDB$RELATION_NAME FROM RDB$RELATIONS ' +
         ' WHERE RDB$RELATION_NAME=''' + IbTableName + ''';';
  IQuery.SQL.Add(S);
  ITrans.StartTransaction;
  IQuery.Prepare;
  IQuery.ExecQuery;
  TableExists := Not IQuery.Eof;
  IQuery.Close;
  ITrans.Commit;

  if NOT TableExists then begin
    IQuery.SQL.Clear;
    IQuery.SQL.Add( MakeCreateTable(IbTableName, CtTable, AFldDb) );
    ITrans.StartTransaction;
    try
      IQuery.ExecQuery;
      ITrans.Commit;
    except
      on E : EIBError do begin
        WriteLn('CREATE FAILED');
        WriteLn('ERR:', E.Message);
        ITrans.Rollback;
        exit;
      end;
    end;
  end;

  // Clarion Cursor Open
  CtCur := TCtCursor.Create(CtTable, 32767, coFastForw);

  if (NOT ACDb.CDbInc) OR DeleteOld then begin
    IQuery.SQL.Clear;
    S := 'DELETE FROM ' + IbTableName +
         ' WHERE (OFFID=' + IntToStr(ACDb.OFFID) +
           ')AND(CDBID=' + IntToStr(ACDb.CDBID) + ');';
    IQuery.SQL.Add(S);
    ITrans.StartTransaction;
    IQuery.Prepare;
    try
      IQuery.ExecQuery;
      ITrans.Commit;
    except
      on E : EIBError do begin
        WriteLn('DELETE FAILED');
        WriteLn('ERR:', E.Message);
        ITrans.Rollback;
//        raise;
      end;
    end;
  end;

  if ACDb.CDbInc then begin
    N := GetIncInfo(ACDb.OFFID, ACDb.CDBID, IbTableName);
    CtCur.GotoRecord(N);
    if N > 0 then CtCur.GotoNext;
  end else
    CtCur.GotoFirst;

  SNames := MakeFieldNames(CtTable, AFldDb);
  IQuery.SQL.Clear;
  S := 'INSERT INTO '+IbTableName+'('+SNames+')VALUES(';
  if UseSuperGen then
    S := S + 'GEN_ID(SUPER_GEN,1)'
  else
    S := S + ':ID';
  S := S + ',:OWNER,:UPDATED,:USERID,:OFFID,:CDBID';
  for i := 0 to CtTable.GetFieldCount - 1 do
    if CtTable.Fields[i].GetFieldType <> FLD_GROUP then begin
      S := S + ',:PRM' + IntToStr(i);
      if ( DateSupport AND IsDateField(CtTable.Fields[i].GetFieldName) ) then
        FDateFields := FDateFields + [i]
      else
      if ( TimeSupport AND IsTimeField(CtTable.Fields[i].GetFieldName) ) then
        FTimeFields := FTimeFields + [i];
    end;
  S := S + ');';

  IQuery.SQL.Add(S);

  N := 0;

  ITrans.Params.Add('isc_tpb_write');
  ITrans.Params.Add('isc_tpb_nowait');
  ITrans.Params.Add('isc_tpb_consistency');
  ITrans.Params.Add('isc_tpb_no_rec_version');

  ITrans.StartTransaction;

  IQuery.GenerateParamNames := False;
  IQuery.GoToFirstRecordOnExecute := False;
  IQuery.Prepare;

  while NOT CtCur.Eof do begin

    if CtCur.IsDeleted and ( NOT Undelete ) then begin
      CtCur.GotoNext;
      continue;
    end;

    if UseSuperGen then begin
      IQuery.Params[0].AsInteger  := 0;          // OWNER
      IQuery.Params[1].AsDateTime := Now;        // UPDATED
      IQuery.Params[2].AsString   := 'DAT2GDB';  // USERID
      IQuery.Params[3].AsInteger  := ACDb.OFFID; // OFFID
      IQuery.Params[4].AsInteger  := ACDb.CDBID; // CLARION DB ID
      IbFldNo := 5;
    end else begin
      IQuery.Params[0].AsInteger  := 0;          // ID
      IQuery.Params[1].AsInteger  := 0;          // OWNER
      IQuery.Params[2].AsDateTime := Now;        // UPDATED
      IQuery.Params[3].AsString   := 'DAT2GDB';  // USERID
      IQuery.Params[4].AsInteger  := ACDb.OFFID; // OFFICE ID
      IQuery.Params[5].AsInteger  := ACDb.CDBID; // CLARION DB ID
      IbFldNo := 6;
    end;

    for i := 0 to CtTable.GetFieldCount - 1 do begin

      if CtTable.Fields[i].GetFieldType <> FLD_GROUP then begin

        f_idx := FindFieldName(Trim(CtTable.Fields[i].GetFieldName), AFldDb);
        if f_idx > -1 then
          S := PFldRecord(AFldDb[f_idx])^.FldNewName
        else
          S := {Trim(}PatchName(CtTable.Fields[i].GetFieldName){)};

        if DateSupport AND (i in FDateFields) then begin
          if CtCur.GetDate(CtTable.Fields[i]) > 65535 then { v.1.14 }
            IQuery.Params[IbFldNo].AsDateTime := 0
          else
            IQuery.Params[IbFldNo].AsDateTime := CtCur.GetDate(CtTable.Fields[i]);
          Inc(IbFldNo);
          continue;
        end;

        if TimeSupport AND (i in FTimeFields) then begin
          IQuery.Params[IbFldNo].AsDateTime := CtCur.GetTime(CtTable.Fields[i]);
          Inc(IbFldNo);
          continue;
        end;

        if CtTable.Fields[i].IsArray then begin
          if ArrayAsStr then begin
            /// 1.14
            XS[i] := CtCur.GetArrayAsString(CtTable.Fields[i]);
            {$IFDEF IBX6XX}
            IQuery.Params[IbFldNo].Data.sqltype := SQL_TEXT or (IQuery.Params[IbFldNo].Data.sqltype and 1);
            IQuery.Params[IbFldNo].Data.sqllen := Length(XS[i]);
            IQuery.Params[IbFldNo].Data.sqldata := PChar(@XS[i][1]);
            {$ELSE}
            IQuery.Params[IbFldNo].Data^.sqltype := SQL_TEXT or (IQuery.Params[IbFldNo].Data^.sqltype and 1);
            IQuery.Params[IbFldNo].Data^.sqllen := Length(XS[i]);
            IQuery.Params[IbFldNo].Data^.sqldata := PChar(@XS[i][1]);
            {$ENDIF}
            IQuery.Params[IbFldNo].Modified := True;
          end else begin
            {$IFDEF IBX6XX}
            IQuery.Params[IbFldNo].Data.sqltype := SQL_TEXT or (IQuery.Params[IbFldNo].Data.sqltype and 1);
            IQuery.Params[IbFldNo].Data.sqllen := 0;
            {$ELSE}
            IQuery.Params[IbFldNo].Data^.sqltype := SQL_TEXT or (IQuery.Params[IbFldNo].Data^.sqltype and 1);
            IQuery.Params[IbFldNo].Data^.sqllen := 0;
            {$ENDIF}
            IQuery.Params[IbFldNo].Modified := True;
          end;
          Inc(IbFldNo);
          continue;
        end;

        case CtTable.Fields[i].GetFieldType of
          FLD_BYTE:
            begin
              XB[i] := 0; XB[i] := CtCur.GetByte(CtTable.Fields[i]);
              {$IFDEF IBX6XX}
              PByte(IQuery.Params[IbFldNo].Data.sqldata)^ := XB[i];
              IQuery.Params[IbFldNo].Data.sqltype := SQL_SHORT or (IQuery.Params[IbFldNo].Data.sqltype and 1);
              IQuery.Params[IbFldNo].Data.sqllen := 2;
              {$ELSE}
              PByte(IQuery.Params[IbFldNo].Data^.sqldata)^ := XB[i];
              IQuery.Params[IbFldNo].Data^.sqltype := SQL_SHORT or (IQuery.Params[IbFldNo].Data^.sqltype and 1);
              IQuery.Params[IbFldNo].Data^.sqllen := 2;
              {$ENDIF}
//              P := CtCur.GetRawDataPointer(CtTable.Fields[i]);
//              PByte(IQuery.Params[IbFldNo].Data^.sqldata)^ := XB[i];
              IQuery.Params[IbFldNo].Modified := True;
            end;
          FLD_SHORT:
            begin
              {$IFDEF IBX6XX}
              IQuery.Params[IbFldNo].Data.sqltype := SQL_SHORT or (IQuery.Params[IbFldNo].Data.sqltype and 1);
              IQuery.Params[IbFldNo].Data.sqllen := 2;
              P := CtCur.GetRawDataPointer(CtTable.Fields[i]);
              IQuery.Params[IbFldNo].Data.sqldata := P;
              {$ELSE}
              IQuery.Params[IbFldNo].Data^.sqltype := SQL_SHORT or (IQuery.Params[IbFldNo].Data^.sqltype and 1);
              IQuery.Params[IbFldNo].Data^.sqllen := 2;
              P := CtCur.GetRawDataPointer(CtTable.Fields[i]);
              IQuery.Params[IbFldNo].Data^.sqldata := P;
              {$ENDIF}
              IQuery.Params[IbFldNo].Modified := True;
            end;
          FLD_LONG:
            begin
              {$IFDEF IBX6XX}
              IQuery.Params[IbFldNo].Data.sqltype := SQL_LONG or (IQuery.Params[IbFldNo].Data.sqltype and 1);
              IQuery.Params[IbFldNo].Data.sqllen := 4;
              P := CtCur.GetRawDataPointer(CtTable.Fields[i]);
              IQuery.Params[IbFldNo].Data.sqldata := P;
              {$ELSE}
              IQuery.Params[IbFldNo].Data^.sqltype := SQL_LONG or (IQuery.Params[IbFldNo].Data^.sqltype and 1);
              IQuery.Params[IbFldNo].Data^.sqllen := 4;
              P := CtCur.GetRawDataPointer(CtTable.Fields[i]);
              IQuery.Params[IbFldNo].Data^.sqldata := P;
              {$ENDIF}
              IQuery.Params[IbFldNo].Modified := True;
            end;
          FLD_PICTURE,
          FLD_STRING:
            begin
              {$IFDEF IBX6XX}
              IQuery.Params[IbFldNo].Data.sqltype := SQL_TEXT or (IQuery.Params[IbFldNo].Data.sqltype and 1);
              P := CtCur.GetRawDataPointer(CtTable.Fields[i]);
              IQuery.Params[IbFldNo].Data.sqllen := CtTable.Fields[i].GetFieldSize;
              {$ELSE}
              IQuery.Params[IbFldNo].Data^.sqltype := SQL_TEXT or (IQuery.Params[IbFldNo].Data^.sqltype and 1);
              P := CtCur.GetRawDataPointer(CtTable.Fields[i]);
              IQuery.Params[IbFldNo].Data^.sqllen := CtTable.Fields[i].GetFieldSize;
              {$ENDIF}
              // right-trim
              {$IFDEF IBX6XX}
              while (IQuery.Params[IbFldNo].Data.sqllen > 0) and
                    (P[IQuery.Params[IbFldNo].Data.sqllen-1] = #$20) do
                IQuery.Params[IbFldNo].Data.sqllen := IQuery.Params[IbFldNo].Data.sqllen - 1;
              if IQuery.Params[IbFldNo].Data.sqllen > 0 then begin
              {$ELSE}
              while (IQuery.Params[IbFldNo].Data^.sqllen > 0) and
                    (P[IQuery.Params[IbFldNo].Data^.sqllen-1] = #$20) do
                Dec(IQuery.Params[IbFldNo].Data^.sqllen);
              if IQuery.Params[IbFldNo].Data^.sqllen > 0 then begin
              {$ENDIF}
              //
                {$IFDEF LINUX}
                {$IFDEF IBX6XX}
                x := IQuery.Params[IbFldNo].Data.sqllen; y := x;
                {$ELSE}
                x := IQuery.Params[IbFldNo].Data^.sqllen; y := x;
                {$ENDIF}
                ip1 := p; ip2 := p;
                case iconv(IcvtID, ip1, x, ip2, y) of
                  E2BIG  : WriteLn('Iconv - Destination buffer too small');
                  EILSEQ : WriteLn('Iconv - Illegal sequence');
                  EINVAL : WriteLn('Iconv - Invalid input sequence');
                end;
                {$ENDIF}
                {$IFDEF WIN32}
                OemToCharBuff(P, P, IQuery.Params[IbFldNo].Data^.sqllen);
                {$ENDIF}
                {$IFDEF IBX6XX}
                IQuery.Params[IbFldNo].Data.sqldata := P;
                {$ELSE}
                IQuery.Params[IbFldNo].Data^.sqldata := P;
                {$ENDIF}
              end;
              IQuery.Params[IbFldNo].Modified := True;
            end;
          FLD_DECIMAL:
            begin
              // XD[i]tMem(IQuery.Params[IbFldNo].Data^.sqldata, SizeOf(Double));
              XD[i] := CtCur.GetDecimal(CtTable.Fields[i]);
              {$IFDEF IBX6XX}
              PDouble(IQuery.Params[IbFldNo].Data.sqldata)^ := XD[i];
              IQuery.Params[IbFldNo].Data.sqltype := SQL_DOUBLE or (IQuery.Params[IbFldNo].Data.sqltype and 1);
              IQuery.Params[IbFldNo].Data.sqllen := SizeOf(Double);
              IQuery.Params[IbFldNo].Data.sqlscale := 0;
              {$ELSE}
              PDouble(IQuery.Params[IbFldNo].Data^.sqldata)^ := XD[i];
              IQuery.Params[IbFldNo].Data^.sqltype := SQL_DOUBLE or (IQuery.Params[IbFldNo].Data^.sqltype and 1);
              IQuery.Params[IbFldNo].Data^.sqllen := SizeOf(Double);
              IQuery.Params[IbFldNo].Data^.sqlscale := 0;
              {$ENDIF}
              IQuery.Params[IbFldNo].Modified := True;
            end;
          FLD_REAL:
            begin
              {$IFDEF IBX6XX}
              IQuery.Params[IbFldNo].Data.sqltype := SQL_DOUBLE or (IQuery.Params[IbFldNo].Data.sqltype and 1);
              IQuery.Params[IbFldNo].Data.sqllen := SizeOf(Double);
              P := CtCur.GetRawDataPointer(CtTable.Fields[i]);
              IQuery.Params[IbFldNo].Data.sqlscale := 0;
              IQuery.Params[IbFldNo].Data.sqldata := P;
              {$ELSE}
              IQuery.Params[IbFldNo].Data^.sqltype := SQL_DOUBLE or (IQuery.Params[IbFldNo].Data^.sqltype and 1);
              IQuery.Params[IbFldNo].Data^.sqllen := SizeOf(Double);
              P := CtCur.GetRawDataPointer(CtTable.Fields[i]);
              IQuery.Params[IbFldNo].Data^.sqlscale := 0;
              IQuery.Params[IbFldNo].Data^.sqldata := P;
              {$ENDIF}
              IQuery.Params[IbFldNo].Modified := True;
            end;
          else
            begin
              IQuery.Params[IbFldNo].Clear;
              IQuery.Params[IbFldNo].IsNull := True;
            end;
        end; // case
        Inc(IbFldNo);
      end; // if <> FLD_GROUP
    end; // for

    try
      IQuery.ExecQuery;
    except
      on E : EIBError do begin
        WriteLn;
        WriteLn('ERR:on record ', N);
        WriteLn('ERR:', E.Message);
        raise;
      end;
    end;
    Inc(N);
    CtCur.GotoNext;
    {$IFDEF WIN32}
      {$IFDEF TIME_SLICE}
        Sleep(0);
      {$ENDIF}
    {$ENDIF}
    if (N mod CommitAfter) = 0 then begin
      Write(N, #13);
      ITrans.CommitRetaining;
    end; // if CommitAfter
  end; // while

  ITrans.CommitRetaining; { 1.15.2 }
  ITrans.Commit;
  WriteLn(N);

  UpdateIncInfo(ACDb.OFFID, ACDb.CDBID, IbTableName, CtCur.GetCurrRecNo);

  CtCur.Free;
  CtTable.Close;
  CtTable.Free;

//  try
//    {$IFDEF WIN32} IQuery.Free; {$ENDIF}
//  except
    // Workaround of Freeing invalid pointer in PXSQLDA
//  end;
  ITrans.Free;

  WriteLn('CVT: END:', IbTableName, ' for ', TimeToStr(Now-T1));
end;

Var
  CfgFile : String;
  IDb  : TIBDatabase;
  IDbTrans : TIBTransaction;
  CDbDb : TList;
  FldDb : TList;
  CDb_i,
  Tbl_i,
  CDbCount,
  TblCount : Byte;
  T1, T2 : TDateTime;
  n : integer;

BEGIN
  WriteLn('DAT2GDB Clarion to Interbase GDB packet converter v' + TOOLKIT_VERSION);
  WriteLn('Under GNU Public License. Volgograd, RUSSIA, 1999-2002');
  WriteLn('Copyright (C) by Dmitry Koudryavtsev, juliasoft@mail.ru');

  if ParamCount > 0 then
    CfgFile := ParamStr(1)
  else begin
    WriteLn('Use: DAT2GDB [Configuration file]'#10#13);
    exit;
  end;

  CDbDb := TList.Create;
  FldDb := TList.Create;

  IDb := TIBDatabase.Create(Nil);
  IDb.SqlDialect := 3;
  IDbTrans := TIBTransaction.Create(Nil);
  IDbTrans.DefaultAction := taCommit;

  IDbTrans.DefaultDatabase := IDb;
  IDb.DefaultTransaction := IDbTrans;

  IbInfo := TIbDatabaseInfo.Create(Nil);
  IbInfo.Database := IDb;

  ReadSetup(CfgFile, IDb, CDbDb, FldDb);

  try
    IDb.Open;
  except
    on E : EIBError do begin
      WriteLn('D2G: Database open error');
      WriteLn('ERR:', E.Message);
      exit;
    end;
  end;

  WriteLn('D2G: Connected');

  try
    T1 := Now;
    CDbCount := CDbDb.Count;
    {$IFDEF LINUX}
    IcvtID := iconv_open(PChar(@TargetLocale[1]), PChar(@SourceLocale[1]));
    if IcvtID = iconv_t(-1) then begin
      WriteLn('ERR: Invalid locale definition');
      exit;
    end;
    {$ENDIF}
    for CDb_i := 0 to CDbCount - 1 do begin // 1.15.3
      n := 0;
      while n < PCDbDatabase(CDbDb[CDb_i])^.CDbTables.Count do begin
        if PCDbDatabase(CDbDb[CDb_i])^.CDbTables[n] = '' then begin
          PCDbDatabase(CDbDb[CDb_i])^.CDbTables.Delete(n);
          continue;
        end;
        inc(n);
      end; // while
      TblCount := PCDbDatabase(CDbDb[CDb_i])^.CDbTables.Count;
      Write('D2G: CDb:', PCDbDatabase(CDbDb[CDb_i])^.CDBID);
      if PCDbDatabase(CDbDb[CDb_i])^.CDbInc then
        WriteLn(' INCREMENTAL MODE')
      else
        WriteLn(' NORMAL MODE');
      T2 := Now;
      for Tbl_i := 0 to TblCount - 1 do
        ConvertTable(IDb, PCDbDatabase(CDbDb[CDb_i])^, Tbl_i, FldDb);
      WriteLn('D2G: END CDb:', PCDbDatabase(CDbDb[CDb_i])^.CDBID,' FOR:', TimeToStr(Now-T2));
    end; // CDb_i
    WriteLn('D2G: ALL DONE FOR:', TimeToStr(Now-T1));
  finally
    {$IFDEF LINUX}
    if IcvtID <> iconv_t(-1) then
      iconv_close(IcvtID);
    {$ENDIF}
    FldDb.Free;
    CDbDb.Free;
    IDbTrans.Free;
    IbInfo.Free;
    IDb.Close; WriteLn('D2G: Closed');
    IDb.Free; WriteLn('D2G: Done');
  end;

END.
