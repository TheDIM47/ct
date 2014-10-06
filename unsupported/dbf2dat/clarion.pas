(*
** CLARION 2.X TOOLKIT
** Copyright (C) by Dmitry Koudryavtsev
** http://juliasoft.chat.ru
** juliasoft@mail.ru
**
** THIS UNIT ONLY FOR DBF->DAT CONVERTER
*)
unit Clarion;

interface

uses SysUtils, Classes, ClDb;

type
  TCacheBalance = ( coFastBack, coBackward, coNormal, coForward, coFastForw );

const
  DAT_HEADER_SIZE = SizeOf(THeader);     { of DAT file   }
  REC_HEADER_SIZE = SizeOf(TDataHeader); { for Record    }
  DELTA_DAYS      = 36161;               { for fast DATE conversion }

  ERR_TRN_WAIT = 'Try to wait owned transaction';
  ERR_TRN_DIR  = 'Invalid Transaction Directory';
  ERR_CT_CANT_OPEN_FILE  = 'Can`t open file or access denied';
  ERR_CT_INVALID_FLDNAME = 'Invalid Field Name';
  ERR_CT_INVALID_VERSION = 'Invalid file version';
  ERR_CT_STRANGE_ENCRYPT = 'Strange header encryption algorythm';

// type EClarionError = class(Exception);

type
  TctKey = class;      { forward declarations }
  TctField = class;
  TctArray = class;
  TctPicture = class;
  TctCursor = class;

  PctTransaction = ^TctTransaction;
  TctTransaction = class(TComponent)
  private
    FPath, FName : String;
    FActive : Boolean;
    FFile : Integer;
    function MakeTrnName : String;
    function GetPath : String;
    procedure SetPath( S : String );
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    function InTransaction : Boolean;
    function BeginTransaction : Boolean;
    function EndTransaction : Boolean;
    procedure WaitTransaction(WaitMs : LongWord); // Use 0..INFINITE
  published
    property AppName : string read FName write FName;
    property AppPath : string read GetPath write SetPath;
  end;

(***** TctClarion *****)

  PctClarion = ^TctClarion;
  TctClarion = class(TComponent)
  private
    FFileName : String;  { File Name   }
    FPassword : String;  { Password    }
    FFile,               { File handler     }
    FMode     : Integer; { Access Mode      }
    FRead_Only,          { Read only access }
    FExclusive: Boolean; { Exclusive access }
    FActive   : Boolean; { Is Opened }
    FId       : Word;    { Encryption ID }
    FHeader   : THeader; { File Header }
    FFields   : TList;   { of TctField   }
    FKeys     : TList;   { of TctKey     }
    FPictures : TList;   { of TctPicture }
    FArrays   : TList;   { of TctArray   }
    procedure SetFileName(Name : String);
//    function  CalcCheckSum : Word;
    procedure DecodeHeader(ID : Word);
    function  CheckHeader(ID : Word) : Boolean;
    procedure SetPassword(APwd : String);
  protected
    procedure ReadHeader;
    procedure ReadFields;
    procedure ReadKeys;
    procedure ReadPictures;
    procedure ReadArrays;
  public
    procedure WriteHeader;
    procedure WriteFields;
    procedure WriteKeys;
    procedure WritePictures;
    procedure WriteArrays;
    function  CalcCheckSum : Word;
//
    constructor Create(AOWner : TComponent); override;
    destructor Destroy; override;
    procedure Assign(ASrc : TPersistent); override; { 1.05 }
    procedure Close; virtual;
    procedure Open; virtual;
    procedure CreateFile; virtual;
//    procedure WriteNumRecs(aNRecs : Integer);
    function IsLocked : Boolean;
    function IsEncrypted : Boolean;
    function IsMemoExist : Boolean;
    function GetPicture(Index : Integer) : TctPicture; { 1.05 }
    function GetBufLen : Integer;
    function GetKey(Index : Integer) : TctKey;         { 1.05 }
    function GetField(Index : Integer) : TctField;
    function GetArray(Index : Integer) : TctArray;
    function FieldByName(AFName : String) : TctField;
    function GetFieldCount : Integer;
    function GetRecordCount : Integer;
    function GetFilePrefix : String;
    property Fields[Index : Integer] : TctField read GetField;
    property Arrays[Index : Integer] : TctArray read GetArray;
    property Pics[Index : Integer] : TctPicture read GetPicture; { 1.05 }
    property Keys[Index : Integer] : TctKey read GetKey;         { 1.05 }
  published
    property Active : Boolean read FActive;
    property FileName : string read FFileName write SetFileName;
    property Password : string read FPassword write SetPassword;
    property Read_Only : Boolean read FRead_Only write FRead_Only default True;
    property Exclusive : Boolean read FExclusive write FExclusive default False;
    property _File : Integer read FFile;
    property PwdID : Word read FID write FID;
    property NumOfRec : Integer read FHeader.NumRecs write FHeader.NumRecs;
    property ChkSum : Word read FHeader.CheckSum write FHeader.CheckSum;
  end;

(***** Fields, Keys, Pictures, Arrays *****)

  PctField = ^TctField;
  TctField = class
  private
    FOwner : TctClarion;
    FFieldRecord : TFieldRecord;
  public
    constructor Create(AOwner : TctClarion);
    function GetFieldSize : Word;
    function GetFieldOffs : Word;
    function GetFieldType : Byte;
    function GetFieldName : String;
    function GetArrayNumber : Word;
    function GetPictureNumber : Word;
    function GetDecSig : Byte;
    function GetDecDec : Byte;
    function IsArray : Boolean;
  published
    property DecDec : Byte read FFieldRecord.DecDec write FFieldRecord.DecDec;
    property DecSig : Byte read FFieldRecord.DecSig write FFieldRecord.DecSig;
  end;

  PctKey = ^TctKey;
  TctKey = class
    FOwner : TctClarion;
    FKeyRecord : TKeyRecord;
    FKeyItems  : TList;
    function GetKeyItem(Index : Integer) : PKeyItem;
  public
    constructor Create(AOwner : TctClarion);
    destructor Done;
    property Items[Index : Integer] : PKeyItem read GetKeyItem;  { 1.05 }
  end;

  PctPicture = ^TctPicture;
  TctPicture = class
    FOwner : TctClarion;
    FPictureRecord : TPictureRecord;
    constructor Create(AOwner : TctClarion);
  end;

  PctArray = ^TctArray;
  TctArray = class
    FOwner : TctClarion;
    FArrayRecord : TArrayRecord;
    FArrayItems  : TList;
    function GetArrayItem(Index : Integer) : PArrayItem;
  public
    constructor Create(AOwner : TctClarion);
    destructor Done;
    function GetBufLen : Integer;                // total size of array record
    function GetDim(Index : Byte) : Integer;     // returns ARRPART[Index].MaxDim
    function GetDimLen(Index : Byte) : Integer;  // returns ARRPART[Index].LenDim
    property Items[Index : Integer] : PArrayItem read GetArrayItem;  { 1.05 }
  end;

(***** TctCursor - table navigation and record access *****)

  PctCursor = ^TctCursor;
  TctCursor = class
  private
    FOwner : TctClarion;
    FFile : Integer; { Actual file }
    FCacheBuffer  : PChar;  { Cache Buffer }
    FCacheSize    : Word;   { Aligned to Data Record Length }
    FCacheBalance : TCacheBalance;    { Allocation Strategy }
    FCMaxRecsInCache,      { Max Records in Cache   }
    FCRecsInCache,         { Total Records in Cache }
    FCMinRecNo,            { Min RecNo in Cache     }
    FCMaxRecNo : LongInt;  { Max RecNo in Cache     }
    FCurrRecNo : LongInt;  { Curren RecNo -> [0..NumRecs-1] }
    function  CheckInCache : Boolean;
    procedure ReadCache;
  public
    constructor Create( AOwner : TctClarion; ACSize : Word; ACBalance : TCacheBalance );
    destructor Done;
    procedure GotoFirst;
    procedure GotoLast;
    procedure GotoNext;
    procedure GotoPrev;
    procedure GotoRecord(RecNo : LongInt); { from 0 to NumRecs-1 !!! }
    function EOF : Boolean;
    function BOF : Boolean;
    function GetDate(Fld : TctField) : TDateTime;
    function GetTime(Fld : TctField) : TDateTime;
    function GetString(Fld : TctField) : String;
    function GetByte(Fld : TctField) : Byte;
    function GetShort(Fld : TctField) : SmallInt;
    function GetDouble(Fld : TctField) : Double;
    function GetInteger(Fld : TctField) : Integer;
    function GetDecimal(Fld : TctField) : Double;
    function GetVariant(Fld : TctField) : Variant;
    function IsNew : Boolean;
    function IsOld : Boolean;
    function IsRevised : Boolean;
    function IsDeleted : Boolean;
    function IsHeld : Boolean;      // Is Record Locked
    procedure SetBalance(ACBalance : TCacheBalance);
    function GetBalance : TCacheBalance;
    function GetCurrRecNo : Integer;
  end;

procedure Register;
procedure DecodeBuffer(Var Buf; BufSize, Id : Word);
function OemToChar(Const S : String) : String;
function CharToOem(Const S : String) : String;
procedure DoubleToBCD(Const Fld: TCtField; Const Dbl : Double; Buffer : PChar);

implementation

Uses FileCtrl, Windows;

procedure Register;
begin
  RegisterComponents( 'Data Access', [TctClarion] );
  RegisterComponents( 'Data Access', [TctTransaction] );
end;

{ 1.05 start }

procedure DoubleToBCD(Const Fld: TCtField; Const Dbl : Double; Buffer : PChar);
var
   i       ,
   FldLen  ,
   CurDec  ,
   NumBytes: integer;
   sHold   : string;
   bChar1, bChar2: byte;
begin
   sHold := FloatToStrF(Dbl, ffFixed, Fld.DecSig+Fld.DecDec+1, Fld.DecDec);
   FldLen := Fld.FFieldRecord.Length;// + (Fld.FFieldRecord.Length mod 2);
   NumBytes := FldLen;
   CurDec := NumBytes - 1;
   i := Length(sHold);
   while i >= 1 do begin
      bchar1 := 0;
      bchar2 := 0;
{!}   if sHold[i] = DECIMALSEPARATOR then Dec(i);
      if sHold[i] in ['0'..'9'] then
        bChar1 := Byte(sHold[i]) mod $30;
      Dec(i);
{!}   if sHold[i] = DECIMALSEPARATOR then Dec(i);
      if (i >= 0) and (sHold[i] in ['0'..'9']) then
        bChar2 := byte(sHold[i]) mod $30;
      PByte(Buffer+CurDec)^ := (bChar2 shl 4) or (bChar1);
      Dec(CurDec);
      Dec(i);
   end;
   if sHold[1] = '-' then
     Byte(Buffer[0]) := Byte(Buffer[0]) OR $F0;
end;

function TCTClarion.GetBufLen : Integer;
begin
  Result := FHeader.RecLen;
end;

procedure TCTClarion.Assign(ASrc : TPersistent);
Var
  i,j : Integer;
  Fld : TctField;
  Pic : TctPicture;
  Key : TctKey;
  KeyItem : PKeyItem;
  Arr : TctArray;
  ArrItem : PArrayItem;
begin
  if ASrc is TctClarion then begin
    FileName := TctClarion(ASrc).FileName;
    Password := TctClarion(ASrc).Password;
    FID := TctClarion(ASrc).PwdID;           /// !!!
    Read_Only:= TctClarion(ASrc).Read_Only;
    Exclusive:= TctClarion(ASrc).Exclusive;
    { Header }
    Move( TctClarion(ASrc).FHeader, FHeader, sizeof(FHeader));
//    if IsEncrypted then FHeader.SFAtr := FHeader.SFAtr XOR SIGN_ENCRYPTED;

    { Fields }
    for i := 0 to TctClarion(ASrc).FHeader.NumFlds - 1 do begin
      Fld := TctField.Create(Self);
      Move( TctClarion(aSrc).Fields[i].FFieldRecord,
            Fld.FFieldRecord,
            sizeof(TFieldRecord) );
      FFields.Add( Fld );
    end;
    { Pictures }
    for i := 0 to FHeader.NumPics - 1 do begin
      Pic := TctPicture.Create(Self);
      FileRead( FFile, Pic.FPictureRecord, sizeof(TPictureRecord) );
      Move( TctClarion(aSrc).Pics[i].FPictureRecord,
            Pic.FPictureRecord,
            sizeof(TPictureRecord) );
      FPictures.Add( Pic );
    end;
    {    FKeys     }
    for i := 0 to FHeader.NumKeys - 1 do begin
      Key := TctKey.Create(Self);
      Move( TctClarion(aSrc).Keys[i].FKeyRecord,
            Key.FKeyRecord,
            sizeof(TKeyRecord) );
      for j := 0 to Key.FKeyRecord.NumComps - 1 do begin
        New( KeyItem );
        Move( TctClarion(aSrc).Keys[i].Items[j]^,
              KeyItem^,
              sizeof(TKeyItem) );
        Key.FKeyItems.Add( KeyItem );
      end;
      FKeys.Add( Key );
    end;
    {   FArrays    }
    for i := 0 to FHeader.NumArrs - 1 do begin
      Arr := TctArray.Create(Self);
      Move( TctClarion(aSrc).Arrays[i].FArrayRecord,
            Arr.FArrayRecord,
            sizeof(TArrayRecord) );
      for j := 0 to Arr.FArrayRecord.TotDim - 1 do begin
        New( ArrItem );
        Move( TctClarion(aSrc).Arrays[i].Items[j]^,
              ArrItem^,
              sizeof(TArrayItem) );
        Arr.FArrayItems.Add(ArrItem);
      end;
      FArrays.Add( Arr );
    end;
  end else
    inherited Assign(ASrc);
end;

function TctClarion.GetPicture(Index : Integer) : TctPicture;
begin
  Result := FPictures[Index];
end;

function TctClarion.GetKey(Index : Integer) : TctKey;
begin
  Result := FKeys[Index];
end;

procedure TctClarion.CreateFile;
begin
  FFile := FileCreate( FFileName );
  if FFile > 0 then begin
    WriteHeader;
    WriteFields;
    WriteKeys;
    WritePictures;
    WriteArrays;
  end else
    Exception.Create('Cant open file');
end;
{
procedure TctClarion.WriteNumRecs(aNRecs : Integer);
begin
  FileSeek( FFile, sizeof(Word)+sizeof(Word)+sizeof(Byte), 0);
  FileWrite( FFile, aNRecs, sizeof(aNRecs) );
end;
}
procedure TctClarion.WriteHeader;
begin
  if IsEncrypted then DecodeHeader(FID);
  FileWrite( FFile, FHeader, sizeof(THeader) );
  if IsEncrypted then DecodeHeader(FID);
end;

procedure TctClarion.WriteFields;
Var i : integer;
begin
  for i := 0 to FHeader.NumFlds - 1 do begin
    if IsEncrypted then DecodeBuffer(Fields[i].FFieldRecord, SizeOf(Fields[i].FFieldRecord), FID);
    FileWrite( FFile, Fields[i].FFieldRecord, sizeof(TFieldRecord) );
    if IsEncrypted then DecodeBuffer(Fields[i].FFieldRecord, SizeOf(Fields[i].FFieldRecord), FID);
  end;
end;

procedure TctClarion.WritePictures;
Var i : integer;
begin
  for i := 0 to FHeader.NumPics - 1 do begin
    if IsEncrypted then DecodeBuffer(Pics[i].FPictureRecord, SizeOf(TPictureRecord), FID);
    FileWrite( FFile, Pics[i].FPictureRecord, sizeof(TPictureRecord) );
    if IsEncrypted then DecodeBuffer(Pics[i].FPictureRecord, SizeOf(TPictureRecord), FID);
  end;
end;

procedure TctClarion.WriteKeys;
Var i, j : integer;
begin
  for i := 0 to FHeader.NumKeys - 1 do begin
    if IsEncrypted then DecodeBuffer(Keys[i].FKeyRecord, sizeof(TKeyRecord), FID);
    FileWrite( FFile, Keys[i].FKeyRecord, sizeof(TKeyRecord) );
    if IsEncrypted then DecodeBuffer(Keys[i].FKeyRecord, sizeof(TKeyRecord), FID);
    for j := 0 to Keys[i].FKeyRecord.NumComps - 1 do begin
      if IsEncrypted then DecodeBuffer(Keys[i].Items[j]^, sizeof(TKeyItem), FID);
      FileWrite( FFile, Keys[i].Items[j]^, sizeof(TKeyItem) );
      if IsEncrypted then DecodeBuffer(Keys[i].Items[j]^, sizeof(TKeyItem), FID);
    end;
  end;
end;

procedure TctClarion.WriteArrays;
Var i, j : integer;
begin
  for i := 0 to FHeader.NumArrs - 1 do begin
//    if IsEncrypted then DecodeBuffer(Arrays[i].FArrayRecord, sizeof(TArrayRecord), FID);
    FileWrite( FFile, Arrays[i].FArrayRecord, sizeof(TArrayRecord) );
//    if IsEncrypted then DecodeBuffer(Arrays[i].FArrayRecord, sizeof(TArrayRecord), FID);
    for j := 0 to Arrays[i].FArrayRecord.TotDim - 1 do begin
//      if IsEncrypted then DecodeBuffer(Arrays[i].Items[j]^, sizeof(TArrayItem), FID);
      FileWrite( FFile, Arrays[i].Items[j]^, sizeof(TArrayItem) );
//      if IsEncrypted then DecodeBuffer(Arrays[i].Items[j]^, sizeof(TArrayItem), FID);
    end;
  end;
end;

function TctKey.GetKeyItem(Index : Integer) : PKeyItem;
begin
  Result := FKeyItems[Index];
end;

function TctArray.GetArrayItem(Index : Integer) : PArrayItem;
begin
  Result := FArrayItems[Index];
end;

{ 1.05 stop }

procedure DecodeBuffer(Var Buf; BufSize, Id : Word);
var i : integer;
begin
  for i := 0 to ( BufSize div 2 ) - 1 do TWordArray(Buf)[i] := TWordArray(Buf)[i] XOR Id;
end;

function OemToChar(Const S : String) : String;
begin
  SetLength( Result, Length(S) );
  if Length(Result) > 0 then
    OemToCharBuff( PChar(S), PChar(Result), Length(Result) );
end;

function CharToOem(Const S : String) : String;
begin
  SetLength( Result, Length(S) );
  if Length(Result) > 0 then
    CharToOemBuff( PChar(S), PChar(Result), Length(Result) );
end;

(***** Transaction support *****)

constructor TctTransaction.Create(AOwner : TComponent);
begin
  Inherited Create(AOwner);
  FActive := False;
end;

destructor TctTransaction.Destroy;
begin
  if FActive then EndTransaction;
  Inherited Destroy;
end;

function TctTransaction.InTransaction : Boolean;
begin
  Result := FileExists( MakeTrnName );
end;

function TctTransaction.BeginTransaction : Boolean;
begin
  if NOT InTransaction then begin
    FFile := FileCreate( MakeTrnName );
    FActive := ( FFile > 0 );
    Result := FActive;
  end else
    Result := False;
end;

function TctTransaction.EndTransaction : Boolean;
begin
  if FActive then begin
    FileClose( FFile );
    FActive := SysUtils.DeleteFile( MakeTrnName );
  end;
  Result := FActive;
end;

procedure TctTransaction.WaitTransaction(WaitMs : LongWord);
Var
  Handle : LongWord;
  P : array [0..255] of Char;
begin
  if InTransaction then
    if FActive then
      raise Exception.Create( ERR_TRN_WAIT )
    else begin
      StrPCopy( P, MakeTrnName );
      Handle := FindFirstChangeNotification( P, False, FILE_NOTIFY_CHANGE_FILE_NAME );
      WaitForSingleObject( Handle, WaitMs );
      CloseHandle( Handle );
    end;
end;

function TctTransaction.GetPath : String;
begin
  Result := FPath;
end;

procedure TctTransaction.SetPath( S : String );
begin
  FPath := '';
  if DirectoryExists(S) then begin
    if S[Length(S)] <> '\' then S := S + '\';
    FPath := S;
  end else
    raise Exception.Create( ERR_TRN_DIR );
end;

function TctTransaction.MakeTrnName : String;
begin
  Result := FPath + FName + '.TRN';
end;

(***** TctCursor *****)

constructor TctCursor.Create(AOwner : TctClarion;
                           ACSize : Word;
                           ACBalance : TCacheBalance);
begin
  FOwner := AOwner;

  FCacheBalance := ACBalance;
  with FOwner.FHeader do begin
    if ACSize < RecLen then ACSize := RecLen;
    FCMaxRecsInCache := ACSize div RecLen;
    if FCMaxRecsInCache > FOwner.FHeader.NumRecs then
      FCMaxRecsInCache := FOwner.FHeader.NumRecs;
    FCacheSize := FCMaxRecsInCache * RecLen;
  end;
  GetMem( FCacheBuffer, FCacheSize );

  FCurrRecNo := 0;
  FCMinRecNo := 0;
  FCMaxRecNo := -1;
  FCRecsInCache := 0;

  FFile := FileOpen( FOwner.FFileName, FOwner.FMode );
end;

destructor TctCursor.Done;
begin
  if FFile > 0 then FileClose( FFile );
  FreeMem( FCacheBuffer );
end;

(***** Cache *****)

function TctCursor.CheckInCache : Boolean;
begin
  Result := ( FCurrRecNo >= FCMinRecNo ) AND ( FCurrRecNo <= FCMaxRecNo );
end;

procedure TctCursor.ReadCache;
Var
  BufSize, i : Word;
  P : PChar;
begin
  { Balance Cache }
  case FCacheBalance of
    coFastBack : begin
      FCMaxRecNo := FCurrRecNo;
      FCMinRecNo := FCMaxRecNo - FCMaxRecsInCache;
    end;
    coBackward : begin
      FCMaxRecNo := FCurrRecNo + ( FCMaxRecsInCache div 3 );
      FCMinRecNo := FCMaxRecNo - FCMaxRecsInCache;
    end;
    coNormal : begin
      FCMinRecNo := FCurrRecNo - ( FCMaxRecsInCache div 2 );
      FCMaxRecNo := FCMinRecNo + FCMaxRecsInCache;
    end;
    coForward : begin
      FCMinRecNo := FCurrRecNo - ( FCMaxRecsInCache div 3 );
      FCMaxRecNo := FCMinRecNo + FCMaxRecsInCache;
    end;
    coFastForw : begin
      FCMinRecNo := FCurrRecNo;
      FCMaxRecNo := FCMinRecNo + FCMaxRecsInCache;
    end;
  end; // Case FCacheBalance

  { Improve CMin/CMax RecNums }
  if ( FCMinRecNo < 0 ) then begin
    FCMinRecNo := 0;
    FCMaxRecNo := FCMinRecNo + FCMaxRecsInCache - 1;
  end else
    if ( FCMaxRecNo > ( FOwner.FHeader.NumRecs - 1 ) ) then begin
      FCMaxRecNo := FOwner.FHeader.NumRecs;
      FCMinRecNo := FCMaxRecNo - FCMaxRecsInCache;
    end else
      Dec(FCMaxRecNo);

  { Seek To Start }
  FileSeek( FFile, FOwner.FHeader.Offset + FOwner.FHeader.RecLen * FCMinRecNo, 0 );

  { Read Cache Buffer & Calculate Total Records In Buffer }
  BufSize := FCacheSize;
  FileRead( FFile, FCacheBuffer^, BufSize ); // Result );
  FCRecsInCache := BufSize div FOwner.FHeader.RecLen;

  { Encrypt Cache Buffer }
  if ( FOwner.IsEncrypted ) AND ( FCRecsInCache > 0 ) then
    for i := 0 to FCRecsInCache - 1 do begin
      P := @FCacheBuffer[ REC_HEADER_SIZE + i * FOwner.FHeader.RecLen ];
      DecodeBuffer( P^, FOwner.FHeader.RecLen - REC_HEADER_SIZE, FOwner.FId );
    end; // if - for
end;

function TctCursor.GetByte(Fld : TctField) : Byte;
begin
  Result := 0;
  if NOT CheckInCache then ReadCache;
  Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                      Fld.GetFieldOffs + REC_HEADER_SIZE ], Result, Fld.GetFieldSize );
end;

function TctCursor.GetShort(Fld : TctField) : SmallInt;
begin
  Result := 0;
  if NOT CheckInCache then ReadCache;
  Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                      Fld.GetFieldOffs + REC_HEADER_SIZE ], Result, Fld.GetFieldSize );
end;

function TctCursor.GetInteger(Fld : TctField) : Integer;
begin
  Result := 0;
  if NOT CheckInCache then ReadCache;
  Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                      Fld.GetFieldOffs + REC_HEADER_SIZE ], Result, Fld.GetFieldSize );
end;

function TctCursor.GetDate(Fld : TctField) : TDateTime;
begin
  Result := GetInteger(Fld) - DELTA_DAYS;
end;

function TctCursor.GetTime(Fld : TctField) : TDateTime;
Var
  Seconds : Integer;
  Hr, Mn, Sc, Ms : Word;
begin
  Seconds := GetInteger(Fld);
  Hr := Seconds div 360000;
  Mn := (Seconds mod 360000) div 6000;
  Sc := ((Seconds mod 360000) mod 6000) div 100;
  Ms := ((Seconds mod 360000) mod 6000) mod 100;
  Result := EncodeTime( Hr, Mn, Sc, Ms );
end;

function TctCursor.GetVariant(Fld : TctField) : Variant;
Var
  S : String;
  i, j, k : Integer;
  b : byte;
  m : smallint;
  d : Double;
  buf : array [0..31] of Byte;
  LoBound, HiBound : Integer;
begin
  if NOT CheckInCache then ReadCache;
  if Fld.GetArrayNumber = 0 then
    case Fld.GetFieldType of
      FLD_LONG:    Result := GetInteger(Fld);
      FLD_BYTE:    Result := GetByte(Fld);
      FLD_SHORT:   Result := GetShort(Fld);
      FLD_PICTURE,
      FLD_STRING : Result := OemToChar(GetString(Fld));
      FLD_REAL:    Result := GetDouble(Fld);
      FLD_DECIMAL: Result := GetDecimal(Fld);
      FLD_GROUP:   Result := Null;
    end // case
  else begin // Array
    LoBound := 0;
    HiBound := FOwner.Arrays[Fld.GetArrayNumber-1].GetDim(0)-1;
    case Fld.GetFieldType of
      FLD_SHORT:
        begin
          Result := VarArrayCreate([LoBound, HiBound], varSmallInt);
          for i := 0 to HiBound do begin
            m := 0;
            Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                                Fld.GetFieldOffs + REC_HEADER_SIZE + i * Fld.GetFieldSize ] ,
                                m, Fld.GetFieldSize );
            Result[i] := m;
          end; // for
        end;
      FLD_BYTE:
        begin
          Result := VarArrayCreate([LoBound, HiBound], varByte);
          for i := 0 to HiBound do begin
            b := 0;
            Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                                Fld.GetFieldOffs + REC_HEADER_SIZE + i * Fld.GetFieldSize ] ,
                                b, Fld.GetFieldSize );
            Result[i] := b;
          end; // for
        end;
      FLD_LONG:
        begin
          Result := VarArrayCreate([LoBound, HiBound], varInteger);
          for i := 0 to HiBound do begin
            j := 0;
            Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                                Fld.GetFieldOffs + REC_HEADER_SIZE + i * Fld.GetFieldSize ] ,
                                j, Fld.GetFieldSize );
            Result[i] := j;
          end; // for
        end;
      FLD_PICTURE,
      FLD_STRING :
        begin
          Result := VarArrayCreate([LoBound, HiBound], varString);
          for i := 0 to HiBound do begin
            SetLength(S, Fld.GetFieldSize);
            Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                                Fld.GetFieldOffs + REC_HEADER_SIZE + i * Fld.GetFieldSize ],
                                S[1], Fld.GetFieldSize );
            Result[i] := S;
          end; // for
        end;
      FLD_REAL:
        begin
          Result := VarArrayCreate([LoBound, HiBound], varDouble);
          for i := 0 to HiBound do begin
            d := 0;
            Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                                Fld.GetFieldOffs + REC_HEADER_SIZE + i * Fld.GetFieldSize ],
                                d, Fld.GetFieldSize );
            Result[i] := d;
          end; // for
        end;
      FLD_DECIMAL:
        begin
          Result := VarArrayCreate([LoBound, HiBound], varDouble);
          for i := 0 to HiBound do begin
            Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                                Fld.GetFieldOffs + REC_HEADER_SIZE + i * Fld.GetFieldSize ],
                                buf, Fld.GetFieldSize );
            S := '';
            if ( buf[0] div 16 ) <> 0 then S := '-';
            S := S + Chr( (buf[0] mod 16) + $30 );
            for k := 1 to Fld.GetFieldSize - 1 do begin
              S := S + Chr( (buf[k] div 16) + $30 );
              S := S + Chr( (buf[k] mod 16) + $30 );
            end;
            Insert( DECIMALSEPARATOR, S, Length(S) - Fld.GetDecDec + 1 );
            d := StrToFloat(S);
            Result[i] := d;
          end; // for
        end;
      FLD_GROUP: Result := Null;
    end; // case
  end;
end;

function TctCursor.GetString(Fld : TctField) : String;
begin
  SetLength(Result, Fld.GetFieldSize);
  if NOT CheckInCache then ReadCache;
  Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                      Fld.GetFieldOffs + REC_HEADER_SIZE ], Result[1], Fld.GetFieldSize );
end;

function TctCursor.GetDouble(Fld : TctField) : Double;
begin
  Result := 0;
  if NOT CheckInCache then ReadCache;
  Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                      Fld.GetFieldOffs + REC_HEADER_SIZE ], Result, Fld.GetFieldSize );
end;

function TctCursor.GetDecimal(Fld : TctField) : Double;
Var
  S : String;
  buf : array [0..31] of Byte;
  i : Byte;
begin
  if NOT CheckInCache then ReadCache;
  Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                      Fld.GetFieldOffs + REC_HEADER_SIZE ], buf, Fld.GetFieldSize );
  S := '';
  if ( buf[0] div 16 ) <> 0 then S := '-';
  S := S + Chr( (buf[0] mod 16) + $30 );
  for i := 1 to Fld.GetFieldSize - 1 do begin
    S := S + Chr( (buf[i] div 16) + $30 );
    S := S + Chr( (buf[i] mod 16) + $30 );
  end;
  Insert( DECIMALSEPARATOR, S, Length(S) - Fld.GetDecDec + 1 );

  Result := StrToFloat(S);
end;

(***** Record Status *****)

function TctCursor.IsNew : Boolean;
begin
  if NOT CheckInCache then ReadCache;
  Result := Boolean( PByteArray(@FCacheBuffer)^[
                       ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen ] AND DATA_NEW );
end;

function TctCursor.IsOld : Boolean;
begin
  if NOT CheckInCache then ReadCache;
  Result := Boolean( PByteArray(@FCacheBuffer)^[
                       ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen ] AND DATA_OLD );
end;

function TctCursor.IsRevised : Boolean;
begin
  if NOT CheckInCache then ReadCache;
  Result := Boolean( PByteArray(@FCacheBuffer)^[
                       ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen ] AND DATA_REV );
end;

function TctCursor.IsDeleted : Boolean;
begin
  if NOT CheckInCache then ReadCache;
  Result := Boolean( PByteArray(@FCacheBuffer)^[
                       ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen ] AND DATA_DEL );
end;

function TctCursor.IsHeld : Boolean;
begin
  if NOT CheckInCache then ReadCache;
  Result := Boolean( PByteArray(@FCacheBuffer)^[
                       ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen ] AND DATA_HLD );
end;

(***** Record Navigation *****)

procedure TctCursor.GotoRecord(RecNo : LongInt);
begin
  if ( RecNo > ( FOwner.FHeader.NumRecs - 1 ) ) then
    RecNo := FOwner.FHeader.NumRecs - 1;
  FCurrRecNo := RecNo;
end;

procedure TctCursor.GotoFirst;
begin
  FCurrRecNo := 0;
end;

procedure TctCursor.GotoLast;
begin
  FCurrRecNo := FOwner.FHeader.NumRecs - 1;
end;

procedure TctCursor.GotoNext;
begin
  if NOT EOF then Inc( FCurrRecNo );
end;

procedure TctCursor.GotoPrev;
begin
  if NOT BOF then Dec( FCurrRecNo );
end;

function TctCursor.EOF : Boolean;
begin
  Result := ( FOwner.FHeader.NumRecs = 0 ) OR ( FCurrRecNo = ( FOwner.FHeader.NumRecs ) );
end;

function TctCursor.BOF : Boolean;
begin
  Result := ( FCurrRecNo < 0 );
end;

procedure TctCursor.SetBalance(ACBalance : TCacheBalance);
begin
  FCacheBalance := ACBalance;
end;

function TctCursor.GetBalance : TCacheBalance;
begin
  Result := FCacheBalance;
end;

function TctCursor.GetCurrRecNo : Integer;
begin
  Result := FCurrRecNo;
end;

(***** TctField *****)

constructor TctField.Create(AOwner : TctClarion);
begin
  FOwner := AOwner;
end;

function TctField.GetFieldSize : Word;
begin
  Result := FFieldRecord.Length;
end;

function TctField.GetFieldType : Byte;
begin
  Result := FFieldRecord.FldType;
end;

function TctField.GetFieldName : String;
begin
  Result := FFieldRecord.FldName;
end;

function TctField.GetFieldOffs : Word;
begin
  Result := FFieldRecord.FOffset;
end;

function TctField.GetArrayNumber : Word;
begin
  Result := FFieldRecord.ArrNum;
end;

function TctField.IsArray : Boolean;
begin
  Result := ( FFieldRecord.ArrNum > 0 );
end;

function TctField.GetPictureNumber : Word;
begin
  Result := FFieldRecord.PicNum;
end;

function TctField.GetDecSig : Byte;
begin
  Result := FFieldRecord.DecSig;
end;

function TctField.GetDecDec : Byte;
begin
  Result := FFieldRecord.DecDec;
end;

(***** TctKey *****)

constructor TctKey.Create(AOwner : TctClarion);
begin
  FOwner := AOwner;
  FKeyItems := TList.Create;
end;

destructor TctKey.Done;
begin
  if FKeyItems <> nil then FKeyItems.Clear;
  FKeyItems.Free;
end;

(***** TctPicture *****)

constructor TctPicture.Create(AOwner : TctClarion);
begin
  FOwner := AOwner;
end;

(***** TctArray *****)

constructor TctArray.Create(AOwner : TctClarion);
begin
  FOwner := AOwner;
  FArrayItems := TList.Create;
end;

destructor TctArray.Done;
begin
  if FArrayItems <> nil then FArrayItems.Clear;
  FArrayItems.Free;
end;

function TctArray.GetDim(Index : Byte) : Integer;
begin
  Result := PArrayItem(FArrayItems[Index])^.MaxDim;
end;

function TctArray.GetDimLen(Index : Byte) : Integer;
begin
  Result := PArrayItem(FArrayItems[Index])^.LenDim;
end;

function TctArray.GetBufLen : Integer;
begin
  Result := FArrayRecord.ElmSiz;
end;

(***** TctClarion *****)

constructor TctClarion.Create(AOwner : TComponent);
begin
  Inherited Create(AOwner);
  FFile := 0; FMode := 0; FActive := False;

  if FRead_Only then
    FMode := fmOpenRead
  else
    FMode := fmOpenReadWrite;

  if FExclusive then
    FMode := FMode OR fmShareExclusive
  else
    FMode := FMode OR fmShareDenyNone;

  FFields := TList.Create;
  FKeys := TList.Create;
  FPictures := TList.Create;
  FArrays := TList.Create;

  FFileName := '';
  FPassword := '';
end;

destructor TctClarion.Destroy;
begin
  if FActive then Close;
  Inherited Destroy;
end;

procedure TctClarion.SetFileName(Name : String);
begin
  FFileName := Name;
end;

function TctClarion.GetField(Index : Integer) : TctField;
begin
  Result := FFields[Index];
end;

function TctClarion.GetArray(Index : Integer) : TctArray;
begin
  Result := FArrays[Index];
end;

function TctClarion.FieldByName(AFName : String) : TctField;
var i : integer;
begin
//  Result := Nil;
  for i := 0 to FFields.Count - 1 do
    if CompareText(AFName, Fields[i].GetFieldName) = 0 then begin
      Result := FFields[i];
      exit;
    end;
  raise Exception.Create( ERR_CT_INVALID_FLDNAME );
end;

(***** CRACK *****)

(* Decoding routines "C" Source Copyright by Yuri Nesterenko, 1995 *)

procedure TctClarion.SetPassword(APwd : String);
Var
  i, k : Byte;
begin
  FPassword := APwd;
  k := Length(APwd);
  if k > 0 then begin
    k := k SHR 1;
    FId := $7F7F;
    for i := 1 to k do
      FId := FId + PWord(@APwd[i])^;
  end else FId := 0;
end;

function TctClarion.CalcCheckSum : Word;
Var i : Byte;
begin
  Result := 0;
  for i := 0 to DAT_HEADER_SIZE - 3 do Result := Result + PByteArray(@FHeader)^[i];
end;

procedure TctClarion.DecodeHeader(ID : Word);
Var i : byte;
begin
  for i := 2 to 41 do
    PWordArray(@FHeader)^[i] := PWordArray(@FHeader)^[i] XOR ID;
end;

function TctClarion.CheckHeader(ID : Word) : Boolean;
Var ChkSum : Word;
begin
  DecodeHeader(ID);
  ChkSum := FHeader.CheckSum;
  FHeader.CheckSum := 0;
  Result := True;
  if CalcCheckSum <> ChkSum then begin
    FHeader.CheckSum := ChkSum;
    DecodeHeader( ID );
    Result := False;
  end;
end;

(***** READ DATA STRUCTURE *****)

procedure TctClarion.ReadHeader;
begin
  FileRead( FFile, FHeader, sizeof(THeader) );
end;

procedure TctClarion.ReadFields;
Var
  i : integer;
  Fld : TctField;
begin
  for i := 1 to FHeader.NumFlds do begin
    Fld := TctField.Create(Self);
    FileRead( FFile, Fld.FFieldRecord, sizeof(TFieldRecord) );
    if IsEncrypted then DecodeBuffer(Fld.FFieldRecord, sizeof(TFieldRecord), FId);
    FFields.Add( Fld );
  end;
end;

procedure TctClarion.ReadKeys;
Var
  i, j : integer;
  Key : TctKey;
  KeyItem : PKeyItem;
begin
  for i := 1 to FHeader.NumKeys do begin
    Key := TctKey.Create(Self);
    FileRead( FFile, Key.FKeyRecord, sizeof(TKeyRecord) );
    if IsEncrypted then DecodeBuffer(Key.FKeyRecord, sizeof(TKeyRecord), FId);
    for j := 1 to Key.FKeyRecord.NumComps do begin
      New( KeyItem );
      FileRead( FFile, KeyItem^, sizeof(TKeyItem) );
      if IsEncrypted then DecodeBuffer(KeyItem^, sizeof(TKeyItem), FId);
      Key.FKeyItems.Add( KeyItem );
    end;
    FKeys.Add( Key );
  end;
end;

procedure TctClarion.ReadPictures;
Var
  i : integer;
  Pic : TctPicture;
begin
  for i := 1 to FHeader.NumPics do begin
    Pic := TctPicture.Create(Self);
    FileRead( FFile, Pic.FPictureRecord, sizeof(TPictureRecord) );
    if IsEncrypted then DecodeBuffer(Pic.FPictureRecord, sizeof(TPictureRecord), FId);
    FPictures.Add( Pic );
  end;
end;

procedure TctClarion.ReadArrays;
var
  i, j : integer;
  Arr : TctArray;
  ArrItem : PArrayItem;
begin
  for i := 1 to FHeader.NumArrs do begin
    Arr := TctArray.Create(Self);
    FileRead( FFile, Arr.FArrayRecord, sizeof(TArrayRecord) );
    for j := 1 to Arr.FArrayRecord.TotDim do begin
      New( ArrItem );
      FileRead( FFile, ArrItem^, sizeof(TArrayItem) );
      Arr.FArrayItems.Add(ArrItem);
    end;
    FArrays.Add( Arr );
  end;
end;

(***** MISC ROUTINES *****)

function TctClarion.GetFieldCount : Integer;
begin
  Result := FHeader.NumFlds;
end;

function TctClarion.GetRecordCount : Integer;
begin
  Result := FHeader.NumRecs;
end;

function TctClarion.GetFilePrefix : String;
begin
  Result := FHeader.FilPrefx;
end;

function TctClarion.IsLocked : Boolean;
begin
  Result := Boolean( FHeader.SFAtr AND SIGN_LOCKED );
end;

function TctClarion.IsEncrypted : Boolean;
begin
  Result := Boolean( FHeader.SFAtr AND SIGN_ENCRYPTED );
end;

function TctClarion.IsMemoExist : Boolean;
begin
  Result := Boolean( FHeader.SFAtr AND SIGN_MEMO );
end;

(***** Open/Close *****)

procedure TctClarion.Open;

 Procedure Crack;
 begin
   if IsMemoExist then begin // memo
     FId := Swap( FHeader.Offset SHR 16 );
     if NOT CheckHeader(FId) then begin
       FId := Swap( PWordArray(@FHeader.RecName)[5] XOR $2020 );
       if NOT CheckHeader(FId) then begin
         FId := Swap( PWordArray(@FHeader.MemName)[5] XOR $2020 );
         if NOT CheckHeader(FId) then begin
           Close;
           raise Exception.Create( ERR_CT_STRANGE_ENCRYPT );
         end;
       end; // Offset
     end; // RecName
   end else begin // no memo
     FId := Swap( FHeader.MemoLen );
     if NOT CheckHeader( FId ) then begin
       FId := Swap( PWordArray(@FHeader.MemName)[5] XOR $2020 );
       if NOT CheckHeader(FId) then begin
         Close;
         raise Exception.Create( ERR_CT_STRANGE_ENCRYPT );
       end;
     end; // MemoLen
   end; // isMemoExist - IsEncrypted
 end;

begin
  if FActive then Close;

  {$I-}
  FFile := FileOpen( FFileName, FMode );
  {$I+}
  if FFile > 0 then begin
    FActive := True;
    ReadHeader;
    if FHeader.FileSIG <> VERSION_21_SIG then begin
      Close;
      raise Exception.Create( ERR_CT_INVALID_VERSION );
    end;
    if IsEncrypted then begin
      if FId <> 0 then begin
        if NOT CheckHeader(FId) then Crack
      end else
        Crack;
    end;
    ReadFields;
    ReadKeys;
    ReadPictures;
    ReadArrays;
  end else
    raise Exception.Create( ERR_CT_CANT_OPEN_FILE );// file opened
end;

procedure TctClarion.Close;
begin
  if FActive then
    FileClose(FFile);
  FActive := False;
  if FFields <> nil then begin
    FFields.Clear;
    FFields.Free;
  end;
  if FKeys <> nil then begin
    FKeys.Clear;
    FKeys.Free;
  end;
  if FPictures <> nil then begin
    FPictures.Clear;
    FPictures.Free;
  end;
  if FArrays <> nil then begin
    FArrays.Clear;
    FArrays.Free;
  end;
end;

END.