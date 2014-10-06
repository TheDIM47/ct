(*
** CLARION 2.1 TOOLKIT
** Copyright (C) by Dmitry Koudryavtsev
** http://juliasoft.chat.ru
** juliasoft@mail.ru
*)
unit clarion;
{$H-}
interface
{$INCLUDE d2dx.inc}
uses SysUtils, Classes, cldb
{$IFDEF VER140}
{$IFDEF USE_VARIANT}
,Variants
{$ENDIF}
{$ENDIF};

type
  TCacheBalance = ( coFastBack, coBackward, coNormal, coForward, coFastForw );

  PWord = ^Word;

const
  DAT_HEADER_SIZE = SizeOf(THeader);     { of DAT file   }
  REC_HEADER_SIZE = SizeOf(TDataHeader); { for Record    }
  DELTA_DAYS      = 36161;               { for fast DATE conversion }

  TOOLKIT_VERSION = '1.14';

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
    procedure WaitTransaction(WaitMs : LongInt); // Use 0..INFINITE
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
    function  CalcCheckSum : Word;
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
    constructor Create(AOWner : TComponent); override;
    destructor Destroy; override;
    procedure Close; virtual;
    procedure Open; virtual;
    function IsLocked : Boolean;
    function IsEncrypted : Boolean;
    function IsMemoExist : Boolean;
    function GetField(Index : Integer) : TctField;
    function GetArray(Index : Integer) : TctArray;
    function FieldByName(AFName : String) : TctField;
    function GetFieldCount : Integer;
    function GetRecordCount : Integer;
    function GetFilePrefix : String;
    property Fields[Index : Integer] : TctField read GetField;
    property Arrays[Index : Integer] : TctArray read GetArray;
  published
    property Active : Boolean read FActive;
    property FileName : string read FFileName write SetFileName;
    property Password : string read FPassword write SetPassword;
    property Read_Only : Boolean read FRead_Only write FRead_Only default True;
    property Exclusive : Boolean read FExclusive write FExclusive default False;
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
  end;

  PctKey = ^TctKey;
  TctKey = class
    FOwner : TctClarion;
    FKeyRecord : TKeyRecord;
    FKeyItems  : TList;
  public
    constructor Create(AOwner : TctClarion);
    destructor Destroy; override;
  end;

  PctPicture = ^TctPicture;
  TctPicture = class
    FOwner : TctClarion;
    FPictureRecord : TPictureRecord;
    constructor Create(AOwner : TctClarion);
  end;

  PctArray = ^TctArray;
  TctArray = class(TObject)
    FOwner : TctClarion;
    FArrayRecord : TArrayRecord;
    FArrayItems  : TList;
  public
    constructor Create(AOwner : TctClarion);
    destructor Destroy; override;
    function GetBufLen : Integer;                // total size of array record
    function GetDim(Index : Byte) : Integer;     // returns ARRPART[Index].MaxDim
    function GetDimLen(Index : Byte) : Integer;  // returns ARRPART[Index].LenDim
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
    destructor Destroy; override;
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
    function GetDecimalX(Fld : TctField; DS, DD : Integer) : Double;
    {$IFDEF USE_VARIANT}
    function GetVariant(Fld : TctField) : Variant;
    {$ENDIF}
    {$H+}
    function GetArrayAsString(Fld : TctField) : String;
    {$H-}
    function GetRawDataPointer(Fld : TctField) : Pointer;
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

{$IFDEF WIN32}
function OemToChar(Const S : String) : String;
function CharToOem(Const S : String) : String;
{$ENDIF}

(* Utility functions *)

function PatchName( S : String ) : String;
{$IFDEF USE_VARIANT}
function GetVarAsString(ATbl : TCtClarion; ACur : TCtCursor; x : integer) : String;
{$ENDIF}
function CheckSlash(Var S : String) : String;
function CheckExt(S : String) : String;
function RemoveExt(S : String) : String;

(*  BCD structure and conversion functions  *)
(*  Copyright (C) by Borland International  *)
(*   (from %Delphi%\sources\vcl\db.pas)     *)

type
  PBcd = ^TBcd;
  TBcd  = packed record
    Precision: Byte;                        { 1..64 }
    SignSpecialPlaces: Byte;                { Sign:1, Special:1, Places:6 }
    Fraction: packed array [0..31] of Byte; { BCD Nibbles, 00..99 per Byte, high Nibble 1st }
  end;

function BCDToCurr(const BCD: TBcd; var Curr: Currency): Boolean;

implementation

{$IFDEF WIN32}
Uses Windows
  {$IFNDEF VER140}
  ,FileCtrl
  {$ENDIF}
;
{$ENDIF}

procedure Register;
begin
  RegisterComponents( 'Data Access', [TctClarion] );
  RegisterComponents( 'Data Access', [TctTransaction] );
end;

function CheckExt(S : String) : String;
begin
  Result := S;
  if Pos('.DAT', UpperCase(S)) = 0 then Result := S + '.DAT';
end;

function RemoveExt(S : String) : String;
begin
  if Pos('.', S) > 0 then
    Result := Copy( S, 1, Pos('.', S) - 1 )
  else
    Result := S;
end;

function CheckSlash(Var S : String) : string;
begin
  {$IFDEF WIN32}
  if S[Length(S)] <> '\' then S := S + '\';
  {$ELSE}
  if S[Length(S)] <> '/' then S := S + '/';
  {$ENDIF}
  Result := S;
end;

function PatchName( S : String ) : String;
begin
  Result := Trim(Copy(S, Pos(':', S) + 1, Length(S)));
  if Result = '' then Result := FormatDateTime('nnsszzz',Time);
end;

{$IFDEF USE_VARIANT}
function GetVarAsString(ATbl : TCtClarion; ACur : TCtCursor; x : integer) : String;
Var
  A : Variant;
  i : Word;
  S : String;
begin
  A := ACur.GetVariant(ATbl.Fields[x]);
  Result := '';
  VarArrayLock(A);
  for i := 0 to VarArrayHighBound(A, 1) do
    case VarType(A[i]) of
      varSmallInt: Result := Result + IntToStr(A[i]) + ';';
      varByte:     Result := Result + IntToStr(A[i]) + ';';
      varInteger:  Result := Result + IntToStr(A[i]) + ';';
      varOleStr:   Result := Result + A[i] + ';';
      varDouble: begin
        S := FloatToStr(A[i]);
        if Pos(DecimalSeparator, S) > 0 then
          S[Pos(DecimalSeparator, S)] := '.';
        Result := Result + S + ';';
      end;
    end;
  VarArrayUnLock(A);
  VarClear(A);
  FreeAndNil(A);
end;
{$ENDIF}

procedure DecodeBuffer(Var Buf; BufSize, Id : Word);
var i : integer;
begin
  for i := 0 to ( BufSize div 2 ) - 1 do
    TWordArray(Buf)[i] := TWordArray(Buf)[i] XOR Id;
end;

{$IFDEF WIN32}
function OemToChar(Const S : String) : String;
begin
  SetLength( Result, Length(S) );
  if Length(Result) > 0 then
    OemToCharBuff( @S[1], @Result[1], Length(S) );
end;
{$ENDIF}

{$IFDEF WIN32}
function CharToOem(Const S : String) : String;
begin
  SetLength( Result, Length(S) );
  if Length(Result) > 0 then
    CharToOemBuff( @S[1], @Result[1], Length(S) );
end;
{$ENDIF}

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
    Result := Factive;
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

procedure TctTransaction.WaitTransaction(WaitMs : LongInt);
Var
  {$IFDEF WIN32}  Handle : LongInt; {$ENDIF}
  P : array [0..255] of Char;
begin
  if InTransaction then
    if FActive then
      raise Exception.Create( ERR_TRN_WAIT )
    else begin
      StrPCopy( P, MakeTrnName );
      {$IFDEF WIN32}
      Handle := FindFirstChangeNotification( P, False, FILE_NOTIFY_CHANGE_FILE_NAME );
      WaitForSingleObject( Handle, WaitMs );
      CloseHandle( Handle );
      {$ENDIF}
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

destructor TctCursor.Destroy;
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

function TctCursor.GetRawDataPointer(Fld : TctField) : Pointer;
begin
  if NOT CheckInCache then ReadCache;
  Result := @FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                           Fld.GetFieldOffs + REC_HEADER_SIZE ];
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

{$H+}
function TctCursor.GetArrayAsString(Fld : TctField) : String;
Var
  S, T : String;
  i, HiBound : Word;
  b : byte;
  m : smallint;
  j : integer;
  d : Double;
  Bcd : TBcd;
  c : currency;
begin
  if NOT CheckInCache then ReadCache;
  if Fld.GetArrayNumber = 0 then
    case Fld.GetFieldType of
      FLD_LONG:    Result := IntToStr(GetInteger(Fld));
      FLD_BYTE:    Result := IntToStr(GetByte(Fld));
      FLD_SHORT:   Result := IntToStr(GetShort(Fld));
      FLD_PICTURE,
      FLD_STRING : Result := GetString(Fld);
      FLD_REAL:    begin
                     S := FloatToStr(GetDouble(Fld));
                     if Pos(DecimalSeparator, S) > 0 then
                       S[Pos(DecimalSeparator, S)] := '.';
                     Result := S;
                   end;
      FLD_DECIMAL: begin
                     S := FloatToStr(GetDecimal(Fld));
                     if Pos(DecimalSeparator, S) > 0 then
                       S[Pos(DecimalSeparator, S)] := '.';
                     Result := S;
                   end;
      FLD_GROUP:   Result := '';
    end // case
  else begin // Array
    HiBound := FOwner.Arrays[Fld.GetArrayNumber-1].GetDim(0)-1;
    case Fld.GetFieldType of
      FLD_GROUP: Result := '';
      FLD_SHORT:
        begin
          for i := 0 to HiBound do begin
            m := 0;
            Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                                Fld.GetFieldOffs + REC_HEADER_SIZE + i * Fld.GetFieldSize ] ,
                                m, Fld.GetFieldSize );
            S := S + IntToStr(m) + ';';
          end; // for
        end;
      FLD_BYTE:
        begin
          for i := 0 to HiBound do begin
            b := 0;
            Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                                Fld.GetFieldOffs + REC_HEADER_SIZE + i * Fld.GetFieldSize ] ,
                                b, Fld.GetFieldSize );
            S := S + IntToStr(b) + ';';
          end; // for
        end;
      FLD_LONG:
        begin
          for i := 0 to HiBound do begin
            j := 0;
            Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                                Fld.GetFieldOffs + REC_HEADER_SIZE + i * Fld.GetFieldSize ] ,
                                j, Fld.GetFieldSize );
            S := S + IntToStr(j) + ';';
          end; // for
        end;
      FLD_PICTURE,
      FLD_STRING :
        begin
          for i := 0 to HiBound do begin
            SetLength(T, Fld.GetFieldSize);
            Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                                Fld.GetFieldOffs + REC_HEADER_SIZE + i * Fld.GetFieldSize ],
                                T[1], Fld.GetFieldSize );
            S := S + Trim(T) + ';';
          end; // for
        end;
      FLD_REAL:
        begin
          for i := 0 to HiBound do begin
            d := 0;
            Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                                Fld.GetFieldOffs + REC_HEADER_SIZE + i * Fld.GetFieldSize ],
                                d, Fld.GetFieldSize );
            T := FloatToStr(d);
            if Pos(DecimalSeparator, T) > 0 then
              T[Pos(DecimalSeparator, T)] := '.';
            S := S + T + ';';
          end; // for
        end;
      FLD_DECIMAL:
        begin
          for i := 0 to HiBound do begin
            { New Code }
            with Bcd do begin
              Precision := Fld.GetDecSig + Fld.GetDecDec;
              Inc(Precision);
              SignSpecialPlaces := Fld.GetDecDec;
              Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                                Fld.GetFieldOffs + REC_HEADER_SIZE + i * Fld.GetFieldSize ],
                                Fraction, Fld.GetFieldSize );
              if Byte(Fraction[0]) > $0F then
                SignSpecialPlaces := SignSpecialPlaces OR $80;
              if Byte(Fraction[0]) > 0 then
                Byte(Fraction[0]) := Byte(Fraction[0]) AND $0F;
            end;
            BCDToCurr(Bcd, c);
            T := FloatToStr(c);
            if Pos(DecimalSeparator, T) > 0 then
              T[Pos(DecimalSeparator, T)] := '.';
            S := S + T + ';';
          end; // for
        end;
    end; // case
    Result := S;
  end;
end;
{$H-}

{$IFDEF USE_VARIANT}
function TctCursor.GetVariant(Fld : TctField) : Variant;
Var
  S : String;
  i, j : Integer;
  b : byte;
  m : smallint;
  d : Double;
//  buf : array [0..31] of Byte;
  LoBound, HiBound : Integer;
  Bcd : TBcd;
  c : currency;
  A : Variant;
begin
  if NOT CheckInCache then ReadCache;
  if Fld.GetArrayNumber = 0 then
    case Fld.GetFieldType of
      FLD_LONG:    A := GetInteger(Fld);
      FLD_BYTE:    A := GetByte(Fld);
      FLD_SHORT:   A := GetShort(Fld);
      FLD_PICTURE,
      FLD_STRING : A := {$IFDEF WIN32}
                        OemToChar(GetString(Fld));
                        {$ELSE}
                        GetString(Fld);
                        {$ENDIF}
      FLD_REAL:    A := GetDouble(Fld);
      FLD_DECIMAL: A := GetDecimal(Fld);
      FLD_GROUP:   A := Null;
    end // case
  else begin // Array
    LoBound := 0;
    HiBound := FOwner.Arrays[Fld.GetArrayNumber-1].GetDim(0)-1;
    case Fld.GetFieldType of
      FLD_GROUP: A := Null;
      FLD_SHORT:
        begin
          A := VarArrayCreate([LoBound, HiBound], varSmallInt);
          for i := 0 to HiBound do begin
            m := 0;
            Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                                Fld.GetFieldOffs + REC_HEADER_SIZE + i * Fld.GetFieldSize ] ,
                                m, Fld.GetFieldSize );
            A[i] := m;
          end; // for
        end;
      FLD_BYTE:
        begin
          A := VarArrayCreate([LoBound, HiBound], varByte);
          for i := 0 to HiBound do begin
            b := 0;
            Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                                Fld.GetFieldOffs + REC_HEADER_SIZE + i * Fld.GetFieldSize ] ,
                                b, Fld.GetFieldSize );
            A[i] := b;
          end; // for
        end;
      FLD_LONG:
        begin
          A := VarArrayCreate([LoBound, HiBound], varInteger);
          for i := 0 to HiBound do begin
            j := 0;
            Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                                Fld.GetFieldOffs + REC_HEADER_SIZE + i * Fld.GetFieldSize ] ,
                                j, Fld.GetFieldSize );
            A[i] := j;
          end; // for
        end;
      FLD_PICTURE,
      FLD_STRING :
        begin
          A := VarArrayCreate([LoBound, HiBound], varOleStr);
          for i := 0 to HiBound do begin
            SetLength(S, Fld.GetFieldSize);
            Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                                Fld.GetFieldOffs + REC_HEADER_SIZE + i * Fld.GetFieldSize ],
                                S[1], Fld.GetFieldSize );
            A[i] := S;
          end; // for
        end;
      FLD_REAL:
        begin
          A := VarArrayCreate([LoBound, HiBound], varDouble);
          for i := 0 to HiBound do begin
            d := 0;
            Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                                Fld.GetFieldOffs + REC_HEADER_SIZE + i * Fld.GetFieldSize ],
                                d, Fld.GetFieldSize );
            A[i] := d;
          end; // for
        end;
      FLD_DECIMAL:
        begin
          A := VarArrayCreate([LoBound, HiBound], varDouble);
          for i := 0 to HiBound do begin
            { New Code }
            with Bcd do begin
              Precision := Fld.GetDecSig + Fld.GetDecDec;
              Inc(Precision);
              SignSpecialPlaces := Fld.GetDecDec;
              Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                                Fld.GetFieldOffs + REC_HEADER_SIZE + i * Fld.GetFieldSize ],
                                Fraction, Fld.GetFieldSize );
              if Byte(Fraction[0]) > $0F then
                SignSpecialPlaces := SignSpecialPlaces OR $80;
              if Byte(Fraction[0]) > 0 then
                Byte(Fraction[0]) := Byte(Fraction[0]) AND $0F;
            end;
            BCDToCurr(Bcd, c);
            A[i] := c;
          end; // for
        end;
    end; // case
  end;
  Result := A;
end;
{$ENDIF}

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

function TctCursor.GetDecimalX(Fld : TctField; DS, DD : Integer) : Double;
Var
//  buf : array [0..31] of Byte;
  Bcd : TBcd;
  c : Currency;
begin
  if NOT CheckInCache then ReadCache;
(* Old code ( before 1.10 )
  Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                      Fld.GetFieldOffs + REC_HEADER_SIZE ], buf, Fld.GetFieldSize );
  with Bcd do begin
    Precision := DS + DD + 1;
    SignSpecialPlaces := DD;
    if buf[0] > $0F then SignSpecialPlaces := SignSpecialPlaces OR $80;
    Move(buf, Fraction, Fld.GetFieldSize);
    if Byte(Fraction[0]) > 0 then
    Byte(Fraction[0]) := Byte(Fraction[0]) AND $0F;
  end;
*)
 { Newest code }
  with Bcd do begin
    Move( FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen +
                        Fld.GetFieldOffs + REC_HEADER_SIZE ], Fraction, Fld.GetFieldSize );
    Precision := DS + DD;
    Inc(Precision);
    SignSpecialPlaces := DD;
    if Byte(Fraction[0]) > $0F then
      SignSpecialPlaces := SignSpecialPlaces OR $80;
    if Byte(Fraction[0]) > 0 then
      Byte(Fraction[0]) := Byte(Fraction[0]) AND $0F;
  end;
  BCDToCurr(Bcd, c);

  Result := c;
end;

function TctCursor.GetDecimal(Fld : TctField) : Double;
begin
  Result := GetDecimalX(Fld, Fld.GetDecSig, Fld.GetDecDec);
end;

(***** Record Status *****)

function TctCursor.IsNew : Boolean;
begin
  if NOT CheckInCache then ReadCache;
  Result := Boolean( Byte(FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen ]) AND DATA_NEW );
end;

function TctCursor.IsOld : Boolean;
begin
  if NOT CheckInCache then ReadCache;
  Result := Boolean( Byte(FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen ]) AND DATA_OLD );
end;

function TctCursor.IsRevised : Boolean;
begin
  if NOT CheckInCache then ReadCache;
  Result := Boolean( Byte(FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen ]) AND DATA_REV );
end;

function TctCursor.IsDeleted : Boolean;
begin
  if NOT CheckInCache then ReadCache;
  Result := Boolean( Byte(FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen ]) AND DATA_DEL );
end;

function TctCursor.IsHeld : Boolean;
begin
  if NOT CheckInCache then ReadCache;
  Result := Boolean( Byte(FCacheBuffer[ ( FCurrRecNo - FCMinRecNo ) * FOwner.FHeader.RecLen ]) AND DATA_HLD );
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

destructor TctKey.Destroy;
Var i : Integer;
begin
  if Assigned(FKeyItems) then begin
    if FKeyItems.Count > 0 then begin
      for i := 0 to FKeyItems.Count - 1 do
        FreeMem(FKeyItems[i]);
      FKeyItems.Clear;
    end;
    FKeyItems.Free;
  end;
  inherited;
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

destructor TctArray.Destroy;
Var i : Integer;
begin
  if Assigned(FArrayItems) then begin
    if FArrayItems.Count > 0 then begin
      for i := 0 to FArrayItems.Count - 1 do
        FreeMem(FArrayItems[i]);
      FArrayItems.Clear;
    end;
    FArrayItems.Free;
  end;
  inherited;
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

  FFileName := '';
  FPassword := '';
end;

destructor TctClarion.Destroy;
begin
  if FActive then Close;
  Inherited;
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
    if CompareText(AFName, Trim(Fields[i].GetFieldName)) = 0 then begin
      Result := FFields[i];
      exit;
    end;
  raise Exception.Create( ERR_CT_INVALID_FLDNAME );
end;

(***** CRACK *****)

(* Decoding routines "C" Source Copyright by Yuri Nesterenko, 1995 *)

{$IFNDEF VER100}

{ D4, D5 Version }

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

{$ELSE}

{ D3 Version by Igor Zakhrebetkov and Dennis Chertkov }

procedure TctClarion.SetPassword(APwd : String);
var L, i: integer;
begin
  FPassword := APwd;
  L := Length(APwd);
  APwd[L+1] := #0;
  L := L div 2;
  Fid := $7F7F;
  for i:=0 to L-1 do
    Fid := Fid + PWord(@APwd[i])^;
end;

{$ENDIF}

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
      GetMem( KeyItem, sizeof(TKeyItem) );
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
      GetMem( ArrItem, sizeof(TArrayItem) );
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
  Result := TrimRight(FHeader.FilPrefx);
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

  FFields := TList.Create;
  FKeys := TList.Create;
  FPictures := TList.Create;
  FArrays := TList.Create;

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
Var i : Integer;
begin
  if FActive then
    FileClose(FFile);
  FActive := False;
  if Assigned(FFields) then begin
    for i := 0 to FFields.Count - 1 do
      TctField(FFields[i]).Free;
    FFields.Clear;
    FFields.Free;
  end;
  if Assigned(FKeys) then begin
    for i := 0 to FKeys.Count - 1 do
      TctKey(FKeys[i]).Free;
    FKeys.Clear;
    FKeys.Free;
  end;
  if Assigned(FPictures) then begin
    for i := 0 to FPictures.Count - 1 do
      TctPicture(FPictures[i]).Free;
    FPictures.Clear;
    FPictures.Free;
  end;
  if Assigned(FArrays) then begin
    for i := 0 to FArrays.Count - 1 do
      TctArray(FArrays[i]).Free;
    Farrays.Clear;
    FArrays.Free;
  end;
end;

(* BCD Conversion routines (C) by Borland International *)

function BCDToCurr(const BCD: TBcd; var Curr: Currency): Boolean;
const
  FConst10: Single = 10;
  CWNear: Word = $133F;
var
  CtrlWord: Word;
  Temp: Integer;
  Digits: array[0..63] of Byte;
asm
        PUSH    EBX
        PUSH    ESI
        MOV     EBX,EAX
        MOV     ESI,EDX
        MOV     AL,0
        MOVZX   EDX,[EBX].TBcd.Precision
        OR      EDX,EDX
        JE      @@8
        LEA     ECX,[EDX+1]
        SHR     ECX,1
@@1:    MOV     AL,[EBX].TBcd.Fraction.Byte[ECX-1]
        MOV     AH,AL
        SHR     AL,4
        AND     AH,0FH
        MOV     Digits.Word[ECX*2-2],AX
        DEC     ECX
        JNE     @@1
        XOR     EAX,EAX
@@2:    MOV     AL,Digits.Byte[ECX]
        OR      AL,AL
        JNE     @@3
        INC     ECX
        CMP     ECX,EDX
        JNE     @@2
        FLDZ
        JMP     @@7
@@3:    MOV     Temp,EAX
        FILD    Temp
@@4:    INC     ECX
        CMP     ECX,EDX
        JE      @@5
        FMUL    FConst10
        MOV     AL,Digits.Byte[ECX]
        MOV     Temp,EAX
        FIADD   Temp
        JMP     @@4
@@5:    MOV     AL,[EBX].TBcd.SignSpecialPlaces
        OR      AL,AL
        JNS     @@6
        FCHS
@@6:    AND     EAX,3FH
        SUB     EAX,4
        NEG     EAX
        CALL    FPower10
@@7:    FSTCW   CtrlWord
        FLDCW   CWNear
        FISTP   [ESI].Currency
        FSTSW   AX
        NOT     AL
        AND     AL,1
        FCLEX
        FLDCW   CtrlWord
        FWAIT
@@8:    POP     ESI
        POP     EBX
end;


END.
