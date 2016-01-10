(*
** Clarion DAT table to dBASE DBF ActiveX converter
** Copyright (C) by Dmitry Koudryavtsev
** http://juliasoft.nm.ru
** juliasoft@mail.ru
*)
unit d2dx;
{$H-}{$J+}
interface

{$INCLUDE d2dx.inc}

uses
{$IFDEF WIN32}
  Windows,
  Controls,
{$ENDIF}
  SysUtils, Classes, clarion, cldb, ctdbf
{$IFDEF VER140}
  {$IFDEF USE_VARIANT}
    ,Variants
  {$ENDIF}
{$ENDIF}
;


{.$DEFINE DBF_TIME} (* Target dBASE field type should be... ???? *)

const
  SUCCESS   =  0;
  EXTENSION = '.DAT';
  DIM_INFINITE = {$IFDEF WIN32}High(Longint){$ELSE}1000{$ENDIF};

type
  TFieldNoSet = set of Byte;
  TOemCvtType = ( ocOemToChar, ocCharToOem, ocNone );

  TD2DX = class(
          {$IFDEF WIN32}
	    {$IFDEF D2D_OCX}
              TWinControl
	    {$ELSE}
              TObject
	    {$ENDIF}
	  {$ELSE}
	    TObject
	  {$ENDIF}
	  )
   private
    FRepeatable : Boolean;
    FDateSupport : Boolean;
    {$IFDEF DBF_TIME}
    FTimeSupport : Boolean;
    {$ENDIF}
    FAppendMode : Boolean;
    FUnDelMode : Boolean;
    FArraySupport : Boolean;
    FOemConvert : TOemCvtType;
    FMsecWait : Longint; // INFINITE;
    //
    FDateContains, FDateStarted : TStringList;
    FDateFields : TFieldNoSet;
    //
    FTimeContains, FTimeStarted : TStringList;
    FTimeFields : TFieldNoSet;
    //
    procedure SetDateContains(Value : String);
    procedure SetDateStarted(Value : String);
    function GetDateContains : String;
    function GetDateStarted : String;
    //
    {$IFDEF DBF_TIME}
    procedure SetTimeContains(Value : String);
    procedure SetTimeStarted(Value : String);
    function GetTimeContains : String;
    function GetTimeStarted : String;
    {$ENDIF}
   protected
    function IsDateField(Value : String) : Boolean;
    {$IFDEF DBF_TIME}
    function IsTimeField(Value : String) : Boolean;
    {$ENDIF}
   public
    {$IFDEF WIN32}
      {$IFDEF D2D_OCX}
        constructor Create(AOwner : TComponent); override;
      {$ELSE}
        constructor Create;
      {$ENDIF}
    {$ELSE}
      constructor Create;
    {$ENDIF}
    destructor Destroy; override;
    procedure Go(InFile, OutFile : String);
    //
    property Repeatable   : Boolean read FRepeatable write FRepeatable;
    property AppendMode   : Boolean read FAppendMode write FAppendMode;
    property UnDelMode    : Boolean read FUnDelMode write FUnDelMode;
    property MsecWait     : Longint read FMsecWait write FMsecWait;
    property ArraySupport : Boolean read FArraySupport write FArraySupport;
    // 1.15.4
    property OemConvert   : TOemCvtType read FOemConvert write FOemConvert;
    //
    property DateSupport  : Boolean read FDateSupport write FDateSupport;
    property DateContains : String read GetDateContains write SetDateContains;
    property DateStarted  : String read GetDateStarted  write SetDateStarted;
    //
    {$IFDEF DBF_TIME}
    property TimeSupport  : Boolean read FTimeSupport write FTimeSupport;
    property TimeContains : String read GetTimeContains write SetTimeContains;
    property TimeStarted  : String read GetTimeStarted  write SetTimeStarted;
    {$ENDIF}
  end;

{$IFDEF D2D_OCX}
procedure Register;
{$ENDIF}

implementation

{$IFDEF D2D_OCX}
procedure Register;
begin
  RegisterComponents('Data Access', [TD2DX]);
end;
{$ENDIF}

{$IFDEF WIN32}
  {$IFDEF D2D_OCX}
    constructor TD2DX.Create(AOwner : TComponent);
  {$ELSE}
    constructor TD2DX.Create;
  {$ENDIF}
{$ELSE}
  constructor TD2DX.Create;
{$ENDIF}
begin
  Inherited; // Create(AOwner);
// init variables
  FRepeatable := False;
{$IFDEF D2D_DEFAULTS}
  FAppendMode  := False;
  FArraySupport := False;
  FDateSupport := False;
{$ELSE}
  FAppendMode  := True;
  FArraySupport := True;
  FDateSupport := True;
{$ENDIF}
  FUnDelMode := False;
  FMsecWait := DIM_INFINITE;
  FOemConvert := ocNone;
//
  FDateContains := TStringList.Create;
  FDateStarted := TStringList.Create;
  FDateFields := [];
//
  FTimeContains := TStringList.Create;
  FTimeStarted := TStringList.Create;
  FTimeFields := [];
end;

destructor TD2DX.Destroy;
begin
  if Assigned(FDateContains) then FDateContains.Free;
  if Assigned(FDateStarted) then FDateStarted.Free;
  if Assigned(FTimeContains) then FTimeContains.Free;
  if Assigned(FTimeStarted) then FTimeStarted.Free;
  Inherited;
end;

// Date begins

function TD2DX.IsDateField(Value : String) : Boolean;
Var i : Byte;
begin
  Result := False;
  if FDateStarted.Count > 0 then begin
    for i := 0 to FDateStarted.Count - 1 do
      if Pos(FDateStarted[i], Value) = 1 then begin
        Result := True;
        exit;
      end;
  end;
  if FDateContains.Count > 0 then begin
    for i := 0 to FDateContains.Count - 1 do
      if Pos(FDateContains[i], Value) > 0 then begin
        Result := True;
        exit;
      end;
  end;
end;

procedure TD2DX.SetDateContains(Value : String);
Var S : String;
    i : Byte;
begin
  FDateContains.Clear;
  S := UpperCase(Trim(Value));
  if Length(S) > 0 then begin
    repeat
      i := Pos(';', S);
      if i > 0 then begin
        FDateContains.Add(Copy(S, 1, i-1));
        System.Delete(S, 1, i);
      end else begin
        FDateContains.Add(S);
      end;
    until i = 0;
  end;
end;

procedure TD2DX.SetDateStarted(Value : String);
Var S : String;
    i : Byte;
begin
  FDateStarted.Clear;
  S := UpperCase(Trim(Value));
  if Length(S) > 0 then begin
    repeat
      i := Pos(';', S);
      if i > 0 then begin
        FDateStarted.Add(Copy(S, 1, i-1));
        System.Delete(S, 1, i);
      end else begin
        FDateStarted.Add(S);
      end;
    until i = 0;
  end;
end;

function TD2DX.GetDateContains : String;
Var i : Byte;
begin
  Result := '';
  if FDateContains.Count > 0 then begin
    for i := 0 to FDateContains.Count - 1 do
      Result := Result + FDateContains[i] + ';';
//    SetLength(Result, Length(Result) - 1);
//    Result := Copy(Result, 1, Length(Result) - 1);
  end;
end;

function TD2DX.GetDateStarted : String;
Var i : Byte;
begin
  Result := '';
  if FDateStarted.Count > 0 then begin
    for i := 0 to FDateStarted.Count - 1 do
      Result := Result + FDateStarted[i] + ';';
//    SetLength(Result, Length(Result) - 1);
//    Result := Copy(Result, 1, Length(Result) - 1);
  end;
end;

// Date end

// Time begins
{$IFDEF DBF_TIME}
function TD2DX.IsTimeField(Value : String) : Boolean;
Var i : Byte;
begin
  Result := False;
  if FTimeStarted.Count > 0 then begin
    for i := 0 to FTimeStarted.Count - 1 do
      if Pos(FTimeStarted[i], Value) = 1 then begin
        Result := True;
        exit;
      end;
  end;
  if FTimeContains.Count > 0 then begin
    for i := 0 to FTimeContains.Count - 1 do
      if Pos(FTimeContains[i], Value) > 0 then begin
        Result := True;
        exit;
      end;
  end;
end;

procedure TD2DX.SetTimeContains(Value : String);
Var S : String;
    i : Byte;
begin
  FTimeContains.Clear;
  S := UpperCase(Trim(Value));
  if Length(S) > 0 then begin
    repeat
      i := Pos(';', S);
      if i > 0 then begin
        FTimeContains.Add(Copy(S, 1, i-1));
        Delete(S, 1, i);
      end else
        FTimeContains.Add(S);
    until i = 0;
  end;
end;

procedure TD2DX.SetTimeStarted(Value : String);
Var S : String;
    i : Byte;
begin
  FTimeStarted.Clear;
  S := UpperCase(Trim(Value));
  if Length(S) > 0 then begin
    repeat
      i := Pos(';', S);
      if i > 0 then begin
        FTimeStarted.Add(Copy(S, 1, i-1));
        Delete(S, 1, i);
      end else
        FTimeStarted.Add(S);
    until i = 0;
  end;
end;

function TD2DX.GetTimeContains : String;
Var i : Byte;
begin
  Result := '';
  if FTimeContains.Count > 0 then begin
    for i := 0 to FTimeContains.Count - 1 do
      Result := Result + FTimeContains[i] + ';';
    SetLength(Result, Length(Result) - 1);
  end;
end;

function TD2DX.GetTimeStarted : String;
Var i : Byte;
begin
  Result := '';
  if FTimeStarted.Count > 0 then begin
    for i := 0 to FTimeStarted.Count - 1 do
      Result := Result + FTimeStarted[i] + ';';
    SetLength(Result, Length(Result) - 1);
  end;
end;
{$ENDIF}
// Time end

procedure TD2DX.Go(InFile, OutFile : String);
Var
   db : TctClarion;
  cur : TctCursor;
  db2 : TdBASE;
    i : Byte;
  err : Byte;
   ep : Boolean;
  buf : PChar;
   bs : Word;
   lc : Longint;
FldNo : Byte;
    p : PChar; // v.1.11
//    S : String;
Handle : Longint;
NumOfCvt : LongInt;
// v.1.11
FieldFormats : array [0..255] of String;
Year, Month, Day : Word;
c : Char;
aFldLen : Integer;
// v.1.10
//WVer : Longint;
//
{$H+}PS : String;{$H-}
begin
  // 1.15.3
  for i := 0 to 255 do FieldFormats[i] := '';
  FDateFields := [];
  FTimeFields := [];

  db := TctClarion.Create(nil);
  db.Read_Only := True;
  db.Exclusive := False;  
  db.FileName := InFile;

  ep := True;
  if FRepeatable then begin
    repeat
      err := 0;
      try
        db.Open;
      except
        on E : Exception do begin
          if (E.Message = ERR_CT_STRANGE_ENCRYPT) (*or (E.Message = ERR_CT_INVALID_VERSION)*) then
            raise
          else begin
            if ep then
              ep := False;
          {$IFDEF LINUX}
            Sleep(FMsecWait);
          {$ELSE}
            err := 1;
            Handle := FindFirstChangeNotification( PChar(@OutFile[1]), False, FILE_NOTIFY_CHANGE_FILE_NAME );
    //--- Handle should be SYNCHRONYZE access on WinNT  // v.1.10
    //--- Code below is just a fast workaround
    //        WVer := Windows.GetVersion;
            if (Windows.GetVersion < $80000000) AND (FMSecWait = High(Longint)) then FMSecWait := 1000;
    //---
            WaitForSingleObject( Handle, FMsecWait );
            FindCloseChangeNotification( Handle );
          {$ENDIF}
          end;
        end; // on E
      end; // try
    until (err = 0);
  end else
//    try
      db.Open;
//    except
//      on E : Exception do WriteLn(' ERROR: Can''''t open file. ', E.Message);
//      raise;
//    end;

  db2 := TdBASE.Create;
  db2.FileName := OutFile;

  if FAppendMode And FileExists(OutFile) then begin
    db2.Open;
    FileSeek(db2.FFile, -1, 2);
    FldNo := 0;
    //////////////////////////////////////////////////
    for i := 0 to db.GetFieldCount - 1 do begin
      if db.Fields[i].GetFieldType = FLD_GROUP then continue;
      if db.Fields[i].IsArray AND FArraySupport then begin
        FieldFormats[FldNo] := '%s'#0;
      end else
      case db.Fields[i].GetFieldType of
        FLD_BYTE:
            FieldFormats[FldNo] :=
              '%' + IntToStr(db2.Fields[FldNo].GetFieldLen) + 'd'#0;
        FLD_SHORT:
            FieldFormats[FldNo] :=
              '%' + IntToStr(db2.Fields[FldNo].GetFieldLen) + 'd'#0;
        FLD_LONG:
          if FDateSupport AND IsDateField(PatchName(db.Fields[i].GetFieldName)) then begin
            FDateFields := FDateFields + [i];
            FieldFormats[FldNo] := '%4d%2d%2d'#0;
          end else begin
            FieldFormats[FldNo] :=
              '%' + IntToStr(db2.Fields[FldNo].GetFieldLen) + 'd'#0;
          end;
        FLD_PICTURE,
        FLD_STRING :
            FieldFormats[FldNo] := '%s'#0;
        FLD_REAL:
            FieldFormats[FldNo] :=
              '%' + IntToStr(db2.Fields[FldNo].GetFieldLen) + '.' +
              IntToStr(db2.Fields[FldNo].GetFieldDec) + 'f'#0;
        FLD_DECIMAL:
            FieldFormats[FldNo] :=
              '%' + IntToStr(db2.Fields[FldNo].GetFieldLen) + '.' +
              IntToStr(db2.Fields[FldNo].GetFieldDec) + 'f'#0;
      end; // case
      Inc(FldNo);
    end; // for
    //////////////////////////////////////////////////

  end else begin
    ep := True;
    if FRepeatable then
      repeat
        err := 0;
        try
          db2.CreateTable;
        except
          if ep then begin
            raise Exception.Create(' Target table busy...');
            ep := False;
          end;
          err := 1;
          {$IFDEF LINUX}
          Sleep(FMsecWait);
          {$ELSE}
          Handle := FindFirstChangeNotification( PChar(@InFile[1]), False, FILE_NOTIFY_CHANGE_FILE_NAME );
          if (Windows.GetVersion < $80000000) AND (FMSecWait = High(LongInt)) then FMSecWait := 1000;
          WaitForSingleObject( Handle, FMsecWait );
          CloseHandle( Handle );
          {$ENDIF}
        end;
      until (err = 0)
    else
      try
        db2.CreateTable;
      except
        raise Exception.Create(' ERROR: Can not create target table');
        exit;
      end;

    for i := 0 to db.GetFieldCount - 1 do begin
      if db.Fields[i].GetFieldType = FLD_GROUP then continue;
      if db.Fields[i].IsArray AND FArraySupport then begin
        aFldLen := db.Arrays[db.Fields[i].GetArrayNumber - 1].GetDim(0) *
                   (2 + db.Arrays[db.Fields[i].GetArrayNumber - 1].GetDimLen(0));
        if aFldLen > 254 then aFldLen := 254;
        db2.AddField(ftChar, PatchName(db.Fields[i].GetFieldName), aFldLen, 0);
        FieldFormats[db2.FFields.Count - 1] := '%s'#0;
      end else
      case db.Fields[i].GetFieldType of
        FLD_BYTE:
          begin
            db2.AddField(ftFloat, PatchName(db.Fields[i].GetFieldName),  4, 0);
            FieldFormats[db2.FFields.Count - 1] :=
              '%' + IntToStr(db2.Fields[db2.FFields.Count - 1].GetFieldLen) + 'd'#0;
          end;
        FLD_SHORT:
          begin
            db2.AddField(ftFloat, PatchName(db.Fields[i].GetFieldName),  6, 0);
            FieldFormats[db2.FFields.Count - 1] :=
              '%' + IntToStr(db2.Fields[db2.FFields.Count - 1].GetFieldLen) + 'd'#0;
          end;
        FLD_LONG:
          if FDateSupport AND IsDateField(PatchName(db.Fields[i].GetFieldName)) then begin
            FDateFields := FDateFields + [i];
            db2.AddField(ftDate, PatchName(db.Fields[i].GetFieldName), 8, 0);
            FieldFormats[db2.FFields.Count - 1] := '%4d%2d%2d'#0;
          end else
          begin
            db2.AddField(ftFloat, PatchName(db.Fields[i].GetFieldName), 11, 0);
            FieldFormats[db2.FFields.Count - 1] :=
              '%' + IntToStr(db2.Fields[db2.FFields.Count - 1].GetFieldLen) + 'd'#0;
          end;
        FLD_PICTURE,
        FLD_STRING :
          begin
            db2.AddField(ftChar, PatchName(db.Fields[i].GetFieldName),
                               db.Fields[i].GetFieldSize, 0);
            FieldFormats[db2.FFields.Count - 1] := '%s'#0;
          end;
        FLD_REAL:
          begin
            db2.AddField(ftFloat, PatchName(db.Fields[i].GetFieldName), 19, 10);
            FieldFormats[db2.FFields.Count - 1] :=
              '%' + IntToStr(db2.Fields[db2.FFields.Count - 1].GetFieldLen) + '.' +
              IntToStr(db2.Fields[db2.FFields.Count - 1].GetFieldDec) + 'f'#0;
          end;
        FLD_DECIMAL:
          begin
            db2.AddField(ftFloat, PatchName(db.Fields[i].GetFieldName),
                                  db.Fields[i].GetDecSig + db.Fields[i].GetDecDec + 2,
                                  db.Fields[i].GetDecDec);
            FieldFormats[db2.FFields.Count - 1] :=
              '%' + IntToStr(db2.Fields[db2.FFields.Count - 1].GetFieldLen) + '.' +
              IntToStr(db2.Fields[db2.FFields.Count - 1].GetFieldDec) + 'f'#0;
          end;
      end; // case
    end;

    db2.WriteHeader;
    db2.WriteFields;
  end; // if Append mode

  cur := TctCursor.Create(db, 56000, coFastForw);
  cur.GotoFirst;

  bs := db2.CalcBufSize + 1;
  GetMem( buf, bs );

  NumOfCvt := 0;

  while not cur.Eof do begin

    if (NOT FUnDelMode) AND (cur.IsDeleted) then begin
      cur.GotoNext;
      continue;
    end;

    FillChar( buf^, bs, $20 );

    FldNo := 0;

    for i := 0 to db.GetFieldCount - 1 do begin
      if db.Fields[i].GetFieldType = FLD_GROUP then continue;
      if db.Fields[i].IsArray AND FArraySupport  then begin
        {$H+}
        PS := cur.GetArrayAsString(db.Fields[i]);
        Move(PS[1], buf[db2.Fields[FldNo].GetFieldOffset+1], Length(PS));
        {$H-}
        Inc(FldNo);
      end else
      case db.Fields[i].GetFieldType of
        FLD_BYTE:
          begin
            // v.1.11
            c := buf[db2.Fields[FldNo].GetFieldOffset];
            FormatBuf( buf[db2.Fields[FldNo].GetFieldOffset],
                       db2.Fields[FldNo].GetFieldLen + 1,
                       FieldFormats[FldNo],
                       Length(FieldFormats[FldNo]) + 1,
                       [cur.GetByte(db.Fields[i])] );
            buf[db2.Fields[FldNo].GetFieldOffset] := c;
            Inc(FldNo);
          end;
        FLD_SHORT:
          begin
            c := buf[db2.Fields[FldNo].GetFieldOffset];
            FormatBuf( buf[db2.Fields[FldNo].GetFieldOffset],
                       db2.Fields[FldNo].GetFieldLen + 1,
                       FieldFormats[FldNo],
                       Length(FieldFormats[FldNo]) + 1,
                       [cur.GetShort(db.Fields[i])] );
            buf[db2.Fields[FldNo].GetFieldOffset] := c;
            Inc(FldNo);
          end;
        FLD_LONG:
          begin
            c := buf[db2.Fields[FldNo].GetFieldOffset];
            if FDateSupport AND ( i in FDateFields ) then begin
              DecodeDate(Cur.GetDate(db.Fields[i]), Year, Month, Day);
              try
              FormatBuf( buf[db2.Fields[FldNo].GetFieldOffset],
                         db2.Fields[FldNo].GetFieldLen + 1,
                         FieldFormats[FldNo],
                         Length(FieldFormats[FldNo]) + 1,
                         [Year, Month, Day] );
              except
              //  ShowMessage('Field = '+db.Fields[i].GetFieldName);
              end;
              if buf[db2.Fields[FldNo].GetFieldOffset + 5] = ' ' then
                buf[db2.Fields[FldNo].GetFieldOffset + 5] := '0';
              if buf[db2.Fields[FldNo].GetFieldOffset + 7] = ' ' then
                buf[db2.Fields[FldNo].GetFieldOffset + 7] := '0';
            end else begin
              try
              FormatBuf( buf[db2.Fields[FldNo].GetFieldOffset],
                         db2.Fields[FldNo].GetFieldLen + 1,
                         FieldFormats[FldNo],
                         Length(FieldFormats[FldNo]) + 1,
                         [cur.GetInteger(db.Fields[i])] );
              except
              //  ShowMessage('Field = '+db.Fields[i].GetFieldName);
              end;
            end;
            buf[db2.Fields[FldNo].GetFieldOffset] := c;
            Inc(FldNo);
          end;
        FLD_PICTURE,
        FLD_STRING :
          begin
            p := cur.GetRawDataPointer(db.Fields[i]);
            {$IFDEF WIN32}
            if FOemConvert = ocCharToOem then
              CharToOemBuff(p, p, db.Fields[i].GetFieldSize)
            else
            if FOemConvert = ocOemToChar then
              OemToCharBuff(p, p, db.Fields[i].GetFieldSize);
            {$ENDIF}
            Move(p[0], buf[db2.Fields[FldNo].GetFieldOffset+1], db.Fields[i].GetFieldSize);
            Inc(FldNo);
          end;
        FLD_REAL:
          begin
            c := buf[db2.Fields[FldNo].GetFieldOffset];
            FormatBuf( buf[db2.Fields[FldNo].GetFieldOffset],
                       db2.Fields[FldNo].GetFieldLen + 1,
                       FieldFormats[FldNo],
                       Length(FieldFormats[FldNo]) + 1,
                       [cur.GetDouble(db.Fields[i])] );
            if db2.Fields[FldNo].GetFieldDec > 0 then
              buf[db2.Fields[FldNo].GetFieldOffset +
                  db2.Fields[FldNo].GetFieldLen -
                  db2.Fields[FldNo].GetFieldDec ] := '.';
            buf[db2.Fields[FldNo].GetFieldOffset] := c;
            Inc(FldNo);
          end;
        FLD_DECIMAL:
          begin
            c := buf[db2.Fields[FldNo].GetFieldOffset];
            FormatBuf( buf[db2.Fields[FldNo].GetFieldOffset],
                       db2.Fields[FldNo].GetFieldLen + 1,
                       FieldFormats[FldNo],
                       Length(FieldFormats[FldNo]) + 1,
                       [cur.GetDecimal(db.Fields[i])] );
            if db2.Fields[FldNo].GetFieldDec > 0 then
              buf[db2.Fields[FldNo].GetFieldOffset +
                  db2.Fields[FldNo].GetFieldLen -
                  db2.Fields[FldNo].GetFieldDec ] := '.';
            buf[db2.Fields[FldNo].GetFieldOffset] := c;
            Inc(FldNo);
          end;
      end; // case
    end; // for

    FileWrite( db2.FFile, buf^, bs);

    Inc(NumOfCvt);

    cur.GotoNext;
  end; // while/for

  FreeMem(buf);
//  cur.Done;
  cur.Free;

  db2.WriteEOF;
  FileSeek( db2.FFile, 4, 0 );
  lc := db2.GetDBRecCount + NumOfCvt;
  FileWrite( db2.FFile, lc, sizeof(lc) );

  db2.Close;

  db.Close;
end;

end.
