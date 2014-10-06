(*
** Clarion DAT table to dBASE DBF packet converter 
** Copyright (C) by Dmitry Koudryavtsev    
** http://juliasoft.chat.ru
** juliasoft@mail.ru
**
** DBF UNIT
*)
unit ctdbf;

INTERFACE

Uses Classes, SysUtils;

type
  EdBASEError = class(Exception);

type
  Char2  = array[0..1] of Char;
  Char4  = array[0..3] of Char;
  Char5  = array[0..4] of Char;
  Char11 = array[0..10] of Char;

type
  PdbHeader = ^TdbHeader;
  TdbHeader = record
    DBType     : Byte;
    Year       : Byte;
    Month      : Byte;
    Day        : Byte;
    RecordCount: LongInt;
    DataOffset : Word;
    RecordLen  : Word;
    Reserved1  : Char2;
    TransFlag  : byte;
    Encrypted  : byte;
    MultiUser  : Longint;
    UserIDLast : Longint;
    Reserved2  : Char4;
    TableFlag  : Byte;
    LangID     : Byte;
    Reserved3  : Char2;
  end;

  TFieldType = ( ftChar, ftDate, ftFloat, ftLogic, ftUnknown );

  PdbFieldRec = ^TdbFieldRec;
  TdbFieldRec = record
    FldName    : Char11;
    FldType    : Char;
    FldOffset  : Longint;
    FldLength  : Byte;
    FldDec     : Byte;
    FldFlag    : Byte;
    Reserved1  : Char5;
    Reserved2  : word;
    FldNum     : word;
    Reserved3  : Char4;
  end;

const
  DBASE_EOF : Byte = $1A;
  FIELD_TERMINATOR : Byte = $0D;
  SIZEOF_HEADER = sizeof(TdbHeader);
  SIZEOF_FIELD = sizeof(TdbFieldRec);
  RECORD_NEW = $20;
  RECORD_DEL = $2A;

type
  TdBASEField = class;

  PdBASE = ^TdBASE;
  TdBASE = class
//  private
  public
    FFileName  : String;
    FMode,
    FFile      : Integer;
    FRead_Only,
    FExclusive,
    FActive    : Boolean;
    FHeader    : TdbHeader;
    FFields    : TList;
    procedure FillHeader;
    function GetField(Index : Integer) : TdBASEField;
//  public
    constructor Create;
    destructor Destroy; override;
    procedure Open;
    procedure Close;
    procedure CreateTable;
    procedure AddField(AType : TFieldType; AName : String; ALen, ADec : Byte);
    procedure ReadHeader;
    procedure ReadFields;
    procedure WriteHeader;
    procedure WriteFields;
    procedure WriteEOF;
    function GetDBType : Byte;
    function GetDBYear : Byte;
    function GetDBMonth : Byte;
    function GetDBDay : Byte;
    function GetDBRecCount : LongInt;
    function GetDBOffset : Word;
    function GetDBRecLen : Word;
    function GetFieldCount : Integer;
    function CalcBufSize : Word;
    property Fields[Index : Integer] : TdBASEField read GetField;
  published
    property FileName  : String read FFileName write FFileName;
    property Active    : Boolean read FActive;
    property Read_Only : Boolean read FRead_Only write FRead_Only default True;
    property Exclusive : Boolean read FExclusive write FExclusive default False;
  end;

  PdBASEField = ^TdBASEField;
  TdBASEField = class
  private
    FOwner : TdBASE;
    FFieldRec : TdbFieldRec;
  public
    constructor Create(AOwner : TdBASE);
    destructor Destroy; override;
    function GetFieldName : String;
    function GetFieldType : TFieldType;
    function GetFieldOffset : Longint;
    function GetFieldDec : Byte;
    function GetFieldNum : word;
    function GetFieldLen : Byte;
  end;

IMPLEMENTATION

(***** TdBASEField *****)

constructor TdBASEField.Create(AOwner : TdBASE);
begin
  FOwner := AOwner;
  FillChar(FFieldRec, SIZEOF_FIELD, 0);
end;

destructor TdBASEField.Destroy;
begin
  FOwner := Nil;
  inherited;
end;

function TdBASEField.GetFieldName : String;
begin
  SetLength(Result, 11);
  Move( FFieldRec.FldName, Result[1], sizeof(Char11) );
  Result := Trim(Result);
end;

function TdBASEField.GetFieldType : TFieldType;
begin
  case FFieldRec.FldType of
    'C' : Result := ftChar;
    'D' : Result := ftDate;
    'N' : Result := ftFloat;
    'L' : Result := ftLogic;
  else
    Result := ftUnknown;
  end; // case
end;

function TdBASEField.GetFieldOffset : Longint;
begin
  Result := FFieldRec.FldOffset;
end;

function TdBASEField.GetFieldDec : Byte;
begin
  Result := FFieldRec.FldDec;
end;

function TdBASEField.GetFieldNum : word;
begin
  Result := FFieldRec.FldNum;
end;

function TdBASEField.GetFieldLen : Byte;
begin
  Result := FFieldRec.FldLength;
end;

(***** TdBASE *****)

constructor TdBASE.Create;
begin
  FActive := False;
  FFields := TList.Create;
  FillChar( FHeader, SIZEOF_HEADER, 0 );
end;

destructor TdBASE.Destroy;
Var i : Integer;
begin
  FActive := False;
  if Assigned(FFields) then begin
    for i := 0 to FFields.Count - 1 do
      TdBASEField(FFields[i]).Free;
    FFields.Clear;
    FFields.Free;
  end;
  inherited;
end;

procedure TdBASE.Open;
begin
  if not FActive then begin

    if FRead_Only then
      FMode := fmOpenRead
    else
      FMode := fmOpenReadWrite;

    if FExclusive then
      FMode := FMode OR fmShareExclusive
    else
      FMode := FMode OR fmShareDenyNone;

    FFile := FileOpen( FFileName, FMode );

    FActive := (FFile > 0);

    if FActive then begin
      ReadHeader;
      ReadFields;
    end else
      raise EdBASEError.Create('Cant open file');
  end else
    raise EdBASEError.Create('File already opened');
end;

procedure TdBASE.Close;
begin
  FileClose(FFile);
  FFields.Free;
  FActive := False;
end;

function TdBASE.CalcBufSize : Word;
Var i : Byte;
begin
  Result := 0;
  if FFields.Count > 0 then
    for i := 0 to FFields.Count - 1 do
      Result := Result + Fields[i].GetFieldLen;
end;

procedure TdBASE.CreateTable;
begin
  if not FActive then begin
    FFile := FileCreate( FFileName );
    FActive := (FFile > 0);
    if not FActive then
      raise EdBASEError.Create('Cant create file');
  end else
    raise EdBASEError.Create('File already opened');
end;

procedure TdBASE.ReadHeader;
begin
  if FActive then
    FileRead( FFile, FHeader, SIZEOF_HEADER )
  else
    raise EdBASEError.Create('File not opened');
end;

procedure TdBASE.WriteHeader;
begin
  if FActive then begin
    FillHeader;
    FileWrite( FFile, FHeader, SIZEOF_HEADER );
  end else
    raise EdBASEError.Create('File not opened');
end;

procedure TdBASE.ReadFields;
Var
  Fld : TdBASEField;
  NFlds, i : Byte;
begin
  if FActive then begin
    NFlds := (FHeader.DataOffset - SIZEOF_HEADER) div SIZEOF_FIELD;
    for i := 0 to NFlds - 1 do begin
      Fld := TdBASEField.Create(Self);
      FileRead( FFile, Fld.FFieldRec, SIZEOF_FIELD );
      FFields.Add(Fld);
    end; // for
  end else
    raise EdBASEError.Create('File not opened');
end;

procedure TdBASE.WriteFields;
Var i : byte;
begin
  if FActive then begin
    for i := 0 to FFields.Count - 1 do
      FileWrite( FFile, Fields[i].FFieldRec, SIZEOF_FIELD );
    FileWrite( FFile, FIELD_TERMINATOR, 1 );
  end else
    raise EdBASEError.Create('File not opened');
end;

procedure TdBASE.WriteEOF;
begin
  if FActive then
    FileWrite( FFile, DBASE_EOF, 1 )
  else
    raise EdBASEError.Create('File not opened');
end;

function TdBASE.GetField(Index : Integer) : TdBASEField;
begin
  Result := FFields[Index];
end;

function TdBASE.GetDBType : Byte;
begin
  Result := FHeader.DBType;
end;

function TdBASE.GetDBYear : Byte;
begin
  Result := FHeader.Year;
end;

function TdBASE.GetDBMonth : Byte;
begin
  Result := FHeader.Month;
end;

function TdBASE.GetDBDay : Byte;
begin
  Result := FHeader.Day;
end;

function TdBASE.GetDBRecCount : LongInt;
begin
  Result := FHeader.RecordCount;
end;

function TdBASE.GetDBOffset : Word;
begin
  Result := FHeader.DataOffset;
end;

function TdBASE.GetDBRecLen : Word;
begin
  Result := FHeader.RecordLen;
end;

function TdBASE.GetFieldCount : Integer;
begin
  Result := FFields.Count;
end;

procedure TdBASE.AddField(AType : TFieldType; AName : String; ALen, ADec : Byte);
Var
  Fld : TdBASEField;
  S, jS : String;
  al : Byte;
  i, j : integer;
  Dupe : Boolean;
begin
  Fld := TdBASEField.Create(Self);
  with Fld.FFieldRec do begin
    al := Length(AName);
    if al > 10 then al := 10;
    S := Copy(AName, 1, al);
    //
    // Check dupes !
    if FFields.Count > 0 then begin
      j := 0;
      repeat
        Dupe := False;      
        for i := 0 to FFields.Count - 1 do
          if AnsiCompareText(TdBASEField(FFields[i]).GetFieldName, S) = 0 then begin
            Dupe := True;
            jS := IntToStr(j);
            if (Length(S) + Length(jS)) > 10 then
              Delete(S, 11 - Length(jS), Length(jS));
            S := S + jS;
            Inc(j);
            break;
          end;
      until NOT Dupe;
    end;
    //
    Move( S[1], FldName, al );
    case AType of
      ftChar  : FldType := 'C';
      ftDate  : FldType := 'D';
      ftFloat : FldType := 'N';
      ftLogic : FldType := 'L';
    end; // case
    FldOffset := CalcBufSize;
    FldLength := ALen;
    FldDec    := ADec;
    FldNum    := FFields.Count;
  end; // with
  FFields.Add(Fld);
end;

procedure TdBASE.FillHeader;
Var Y, M, D : Word;
begin
  with FHeader do begin
    DBType := $03;
    DecodeDate(Now, Y, M, D);
    if Y > 1900 then Year := Y - 1900 else Year := Y;
    Month := M;
    Day := D;
    DataOffset := SIZEOF_HEADER + FFields.Count * SIZEOF_FIELD + 1;
    RecordLen := CalcBufSize + 1;
  end;
end;

END.
