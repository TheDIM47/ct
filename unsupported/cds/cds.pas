(*
**         Clarion Toolkit v2
** Copyright (C) by Dmitry Kudryavtsev
**       Volgograd, RUSSIA, 2000
** juliasoft@mail.ru, FIDO: 2:5055/24
*)

{ TClarionDataSet }

unit CDS;

INTERFACE

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Db, ClDb2;

type
  PBCD = ^TBCD;

  PRecInfo = ^TRecInfo;           // Bookmark Holder
  TRecInfo = packed record
    Bookmark: LongInt;
    BookmarkFlag: TBookmarkFlag;
  end;

(* TCDSKey *)

  PCDSKey = ^TCDSKey;
  TCDSKey = record
    FKeyRecord : TKeyRecord;
    FKeyItems  : TList; // of TKeyItem
  end;

(* TCDSArray *)

  PCDSArray = ^TCDSArray;
  TCDSArray = record
    FArrayRecord : TArrayRecord;
    FArrayItems  : TList; // of TArrayItem
  end;

(* TClarionDataSet *)

  TClarionDataSet = class(TDataSet)
  private
    { Private declarations }
    FFile : TStream;
    FPassword  : String;
    FID : Word;
    FHeader : THeader;

    FCDSFields : TList;   // of TFieldRecord;
    FCDSKeys : TList;     // of TCDSKey
    FCDSPictures : TList; // of TPictureRecord;
    FCDSArrays : TList;   // of TCDSArray

    FTableName : String;

    FReadOnly : Boolean;
    FExclusive : Boolean;
    FBlobToCache : Boolean;
    FOpenMode : Byte;
    FShareMode : Byte;

    FOemConvert : Boolean;
    FCurRec : LongInt;
    FRecBufSize : LongInt;
    FDataOffset : LongInt;
    function  CalcCheckSum : Word;
    function  CheckHeader(ID : Word) : Boolean;
    procedure DecodeHeader(ID : Word);
    procedure SetPassword(APwd : String);
    procedure SetReadOnly(Value : Boolean);
    procedure SetExclusive(Value : Boolean);
    procedure SetBlobToCache(Value : Boolean);
  protected
    { Protected declarations }
    procedure InternalOpen; override;
    procedure InternalClose; override;
    function  IsCursorOpen: Boolean; override;
    function  GetCanModify: Boolean; override;
    procedure InternalInitFieldDefs; override;
    procedure InternalHandleException; override;
    function  GetRecordSize : Word; override;
    function  AllocRecordBuffer : PChar; override;
    procedure FreeRecordBuffer(var Buffer : PChar); override;
    function  GetRecordCount : LongInt; override;
    function  GetRecNo: LongInt; override;
    procedure SetRecNo(Value : LongInt); override;
    procedure InternalFirst; override;
    procedure InternalLast; override;
    procedure InternalPost; override;
    procedure InternalAddRecord(Buffer: Pointer; Append: Boolean); override;
    procedure InternalDelete; override;
    procedure InternalGotoBookmark(Bookmark: Pointer); override;
    procedure InternalSetToRecord(Buffer: PChar); override;
    function  GetBookmarkFlag(Buffer: PChar): TBookmarkFlag; override;
    procedure SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag); override;
    procedure GetBookmarkData(Buffer: PChar; Data: Pointer); override;
    procedure SetBookmarkData(Buffer: PChar; Data: Pointer); override;
    function  GetRecord(Buffer: PChar; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    procedure InternalInitRecord(Buffer: PChar); override;
    procedure SetFieldData(Field: TField; Buffer: Pointer); override;
  private // Internal TClarionDataSet routines
    procedure _InternalWriteHeader;
    procedure _InternalReadHeader;
  public
    { Public declarations }
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    function GetFieldData(Field: TField; Buffer: Pointer): Boolean; override;
    function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;
    function GetBlobFieldData(FieldNo: Integer; var Buffer: TBlobByteData): Integer; override;
    { IsTable... }
    function IsTableLocked : Boolean;
    function IsTableOwned : Boolean;
    function IsTableEncrypted : Boolean;
    function IsTableHaveMemo : Boolean;
    function IsTableCompressed : Boolean;
    function IsTableReclaim : Boolean;
    function IsTableReadonly : Boolean;
    function IsTableCreated : Boolean;
    { IsRecord... }
    function IsRecordNew : Boolean;
    function IsRecordOld : Boolean;
    function IsRecordRevised : Boolean;
    function IsRecordDeleted : Boolean;
    function IsRecordHeld : Boolean;
  published
    { Published declarations }
    property TableName : String read FTableName write FTableName;
    property Password : String read FPassword write SetPassword;
    property ReadOnly : Boolean read FReadOnly write SetReadOnly;
    property Exclusive : Boolean read FExclusive write SetExclusive;
    property OemConvert : Boolean read FOemConvert write FOemConvert;
    property BlobToCache : Boolean read FBlobToCache write SetBlobToCache;
    { Events }
    property Active;
    property BeforeOpen;
    property AfterOpen;
    property BeforeClose;
    property AfterClose;
    property BeforeInsert;
    property AfterInsert;
    property BeforeEdit;
    property AfterEdit;
    property BeforePost;
    property AfterPost;
    property BeforeCancel;
    property AfterCancel;
    property BeforeDelete;
    property AfterDelete;
    property BeforeScroll;
    property AfterScroll;
    property BeforeRefresh;
    property AfterRefresh;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;
  end;

(* TClarionMemoStream *)

type
  TClarionMemoStream = class(TFileStream)
    FField : TBlobField;
    FDataSet : TClarionDataSet;
    FMode : TBlobStreamMode;
    FOpened : Boolean;
    FModified : Boolean;
    FPosition : Longint;
    FRPtr : Word;
    FBlobData : TBlobData;
    FHeader : TMemoHeader;
    function GetBlobSize: Longint;
    function RPtrToOffset(RPtr : Integer) : LongInt;
    function OffsetToRPtr(Offset : Integer) : LongInt;
  public
    constructor Create(Field: TBlobField; Mode: TBlobStreamMode);
    destructor Destroy; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
  end;

procedure Register;

procedure DecodeBuffer( Var Buf; BufSize, Id : Word );
function PatchFieldName( S : String ) : String;

IMPLEMENTATION

(* TDataSet overrides *)

constructor TClarionDataSet.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FShareMode := fmShareDenyNone;
  FOpenMode  := fmOpenReadWrite;
  FReadOnly := False;
  FCDSFields := TList.Create;
  FCDSKeys := TList.Create;
  FCDSPictures := TList.Create;
  FCDSArrays := TList.Create;
end;

destructor TClarionDataSet.Destroy;
begin
  inherited;
  FCDSFields.Free;
  FCDSKeys.Free;
  FCDSPictures.Free;
  FCDSArrays.Free;
end;

procedure TClarionDataSet.InternalOpen;
Var
  i, j : Integer;

  PCDSField : PFieldRecord;
  PCDSPicture : PPictureRecord;

  iKey    : PCDSKey;
  iKeyItem : PKeyItem;
  iArray    : PCDSArray;
  iArrayItem : PArrayItem;
begin
  FFile := TFileStream.Create( FTableName, FShareMode OR FOpenMode );

  _InternalReadHeader;

  // Fields
  if FHeader.NumFlds > 0 then
    for i := 0 to FHeader.NumFlds - 1 do begin
      New(PCDSField);
      FFile.Read( PCDSField^, sizeof(TFieldRecord) );
      if IsTableEncrypted then DecodeBuffer(PCDSField^, sizeof(TFieldRecord), FId);
      FCDSFields.Add(PCDSField);
    end;

  // Keys
  if FHeader.NumKeys > 0 then
    for i := 0 to FHeader.NumKeys - 1 do begin
      New(iKey);
      FFile.Read( iKey^.FKeyRecord, sizeof(TKeyRecord) );
      if IsTableEncrypted then DecodeBuffer(iKey^.FKeyRecord, sizeof(TKeyRecord), FId);
      iKey^.FKeyItems := TList.Create;
      if iKey^.FKeyRecord.NumComps > 0 then
        for j := 0 to iKey^.FKeyRecord.NumComps - 1 do begin
          New( iKeyItem );
          FFile.Read( iKeyItem^, sizeof(TKeyItem) );
          if IsTableEncrypted then DecodeBuffer(iKeyItem^, sizeof(TKeyItem), FId);
          iKey^.FKeyItems.Add( iKeyItem );
        end;
      FCDSKeys.Add( iKey );
    end;

  // Pictures
  if FHeader.NumPics > 0 then
    for i := 0 to FHeader.NumPics - 1 do begin
      New(PCDSPicture);
      FFile.Read( PCDSPicture^, sizeof(TPictureRecord) );
      if IsTableEncrypted then DecodeBuffer(PCDSPicture^, sizeof(TPictureRecord), FId);
      FCDSPictures.Add(PCDSPicture);
    end;

  // Arrays
  if FHeader.NumArrs > 0 then
    for i := 0 to FHeader.NumArrs - 1 do begin
      New(iArray);
      FFile.Read( iArray^.FArrayRecord, sizeof(TArrayRecord) );
      if IsTableEncrypted then DecodeBuffer(iArray^.FArrayRecord, sizeof(TArrayRecord), FId);
      iArray^.FArrayItems := TList.Create;
      if iArray^.FArrayRecord.TotDim > 0 then
        for j := 0 to iArray^.FArrayRecord.TotDim - 1 do begin
          New( iArrayItem );
          FFile.Read( iArrayItem^, sizeof(TArrayItem) );
          if IsTableEncrypted then DecodeBuffer(iArrayItem^, sizeof(TArrayItem), FId);
          iArray^.FArrayItems.Add(iArrayItem);
        end;
      FCDSArrays.Add( iArray );
    end;

  FDataOffset := FHeader.Offset;
  FCurRec := -1;
  FRecBufSize := GetRecordSize + SizeOf(TRecInfo);
  BookmarkSize := SizeOf(LongInt);
  InternalInitFieldDefs;
  if DefaultFields then CreateFields;
  BindFields(True);
end;

procedure TClarionDataSet.InternalClose;
Var i : Integer;
begin
  FFile.Free;
  FFile := Nil;

  FCDSFields.Clear;
  if FHeader.NumKeys > 0 then begin
    for i := 0 to FCDSKeys.Count - 1 do
      PCDSKey(FCDSKeys[i])^.FKeyItems.Clear;
    FCDSKeys.Clear;
  end;
  if FHeader.NumArrs > 0 then begin
    for i := 0 to FCDSArrays.Count - 1 do
      PCDSArray(FCDSArrays[i])^.FArrayItems.Clear;
    FCDSArrays.Clear;
  end;
  FCDSPictures.Clear;

  BindFields(False);
  if DefaultFields then DestroyFields;

  FCurRec := -1;
end; // InternalClose

function TClarionDataSet.IsCursorOpen: Boolean;
begin
  Result := Assigned(FFile) AND (TFileStream(FFile).Handle > 0);
end;

procedure TClarionDataSet.InternalInitFieldDefs;
Var i : Integer;
begin
  if DefaultFields then begin
    FieldDefs.Clear;
    for i := 0 to FHeader.NumFlds - 1 do
      with FieldDefs.AddFieldDef do begin
        Name := PatchFieldName(PFieldRecord(FCDSFields[i])^.FldName);
        FieldNo := i + 1;
        Precision := 0;
        Size := 0;
        case PFieldRecord(FCDSFields[i])^.FldType of
          FLD_BYTE, FLD_SHORT : DataType := ftSmallInt;
          FLD_LONG : DataType := ftInteger;
          FLD_REAL :
            begin
              DataType := ftFloat;
              Precision := PFieldRecord(FCDSFields[i])^.DecDec;
            end;
          FLD_DECIMAL :
            begin
              DataType := ftBCD;
              Precision := PFieldRecord(FCDSFields[i])^.DecSig +
                           PFieldRecord(FCDSFields[i])^.DecDec;
              Size := PFieldRecord(FCDSFields[i])^.DecDec;
            end;
          FLD_STRING,
          FLD_PICTURE :
            begin
              DataType := ftString;
              Size := PFieldRecord(FCDSFields[i])^.Length;
            end;
          FLD_GROUP : DataType := ftUnknown;
        end; // case
        Required := False;
      end; // for-with
    if IsTableHaveMemo then
      with FieldDefs.AddFieldDef do begin
        DataType := ftMemo;
        Name := Trim(FHeader.MemName);
        Size := FHeader.MemoLen;
      end; // if HaveMemo - with
  end;
end;

function TClarionDataSet.GetRecord(Buffer: PChar; GetMode: TGetMode; DoCheck: Boolean): TGetResult;
Var P : PChar;
begin
  if GetRecordCount < 1 then
    Result := grEOF
  else begin
    Result := grOK;
    case GetMode of
      gmNext:
        if FCurRec >= RecordCount - 1  then
          Result := grEOF
        else
          Inc(FCurRec);
      gmPrior:
        if FCurRec <= 0 then
          Result := grBOF
        else
          Dec(FCurRec);
      gmCurrent:
        if (FCurRec < 0) or (FCurRec >= RecordCount) then
          Result := grError;
    end;
    if Result = grOK then begin
      FFile.Seek( FHeader.Offset + FHeader.RecLen * FCurRec, soFromBeginning );
      FFile.Read( Buffer^, RecordSize );
      if IsTableEncrypted then begin
        P := @Buffer[ SizeOf(TDataHeader) ];
        DecodeBuffer( P^, RecordSize - SizeOf(TDataHeader), FId );
      end;
      with PRecInfo(Buffer + GetRecordSize)^ do begin
        BookmarkFlag := bfCurrent;
        Bookmark := FCurRec;
      end;
    end else
      if (Result = grError) and DoCheck then DatabaseError('No Records');
  end;
end;

procedure TClarionDataSet._InternalReadHeader;

 procedure Crack;
 begin
   if IsTableHaveMemo then begin // memo
     FId := Swap( FHeader.Offset SHR 16 );
     if NOT CheckHeader(FId) then begin
       FId := Swap( PWordArray(@FHeader.RecName)[5] XOR $2020 );
       if NOT CheckHeader(FId) then begin
         FId := Swap( PWordArray(@FHeader.MemName)[5] XOR $2020 );
         if NOT CheckHeader(FId) then begin
           Close;
           raise Exception.Create( 'ERR_CT_STRANGE_ENCRYPT' );
         end;
       end; // Offset
     end; // RecName
   end else begin // no memo
     FId := Swap( FHeader.MemoLen );
     if NOT CheckHeader( FId ) then begin
       FId := Swap( PWordArray(@FHeader.MemName)[5] XOR $2020 );
       if NOT CheckHeader(FId) then begin
         Close;
         raise Exception.Create( 'ERR_CT_STRANGE_ENCRYPT' );
       end;
     end; // MemoLen
   end; // isMemoExist - IsEncrypted
 end; // Crack

begin
  FFile.Seek( 0, soFromBeginning );
  FFile.Read( FHeader, SizeOf(THeader) );

  if FHeader.FileSIG <> VERSION_21_SIG then
    raise Exception.Create( 'ERR_CT_INVALID_VERSION' );

  if IsTableEncrypted then begin
    if FId <> 0 then begin
      if NOT CheckHeader(FId) then Crack
    end else
      Crack;
  end;
end;

procedure TClarionDataSet._InternalWriteHeader;
begin
  if IsTableEncrypted then begin
    FHeader.CheckSum := 0;
    FHeader.CheckSum := CalcCheckSum;
    DecodeHeader(FId);   // !!!
  end;
  FFile.Seek( 0, soFromBeginning );
  FFile.Write( FHeader, SizeOf(FHeader) );
  if IsTableEncrypted then DecodeHeader(FId);   // !!!
end;

procedure TClarionDataSet.InternalInitRecord(Buffer: PChar);
begin
  FillChar(Buffer^, RecordSize, 0);
end;

function TClarionDataSet.GetFieldData(Field: TField; Buffer: Pointer): Boolean;
Var
  SrcBuf, DestBuf : PChar;
  PCurField : PFieldRecord;
begin
  if Assigned(Buffer) then begin
    DestBuf := Buffer;
    PCurField := PFieldRecord(FCDSFields[Field.FieldNo-1]);
    SrcBuf := @PChar(ActiveBuffer)[PCurField^.FOffset + Sizeof(TDataHeader)];
    case PCurField^.FldType of
      FLD_BYTE, FLD_SHORT, FLD_LONG, FLD_REAL :
        System.Move(SrcBuf^, DestBuf^, PCurField^.Length);
      FLD_DECIMAL :
        with PBCD(DestBuf)^ do begin
          Precision := PCurField^.DecSig +PCurField^.DecDec + 1;
          SignSpecialPlaces := PCurField^.DecDec;
          if PByte(SrcBuf)^ > $0F then SignSpecialPlaces := SignSpecialPlaces OR $80;
          Move(SrcBuf^, Fraction, PCurField^.Length);
          if Byte(Fraction[0]) > 0 then
            Byte(Fraction[0]) := Byte(Fraction[0]) AND $0F;
        end;
      FLD_STRING, FLD_PICTURE :
        begin
          FillChar(DestBuf^, Field.DataSize, 0);
          System.Move(SrcBuf^, DestBuf^, PCurField^.Length);
          if FOemConvert then
            OemToCharBuff(DestBuf, DestBuf, PCurField^.Length);
        end;
      FLD_GROUP :
        begin
        end;
    end; // case
    Result := True;
  end else begin
    Result := Boolean(ActiveBuffer[0]);
    if Result and (Buffer <> nil) then begin
      PCurField := PFieldRecord(FCDSFields[Field.FieldNo-1]);
      SrcBuf := @PChar(ActiveBuffer)[PCurField^.FOffset + Sizeof(TDataHeader)];
      Move(SrcBuf[1], Buffer^, Field.DataSize);
    end;
  end;
end;

procedure TClarionDataSet.SetFieldData(Field: TField; Buffer: Pointer);
Var
  SrcBuf, DestBuf : PChar;
begin
  SrcBuf := Buffer;
  DestBuf := @PChar(ActiveBuffer)[PFieldRecord(FCDSFields[Field.FieldNo-1])^.FOffset + Sizeof(TDataHeader)];
  case PFieldRecord(FCDSFields[Field.FieldNo-1])^.FldType of
    FLD_BYTE, FLD_SHORT, FLD_LONG, FLD_REAL :
      System.Move(SrcBuf^, DestBuf^, PFieldRecord(FCDSFields[Field.FieldNo-1])^.Length);
    FLD_DECIMAL :
      with PBCD(SrcBuf)^ do begin
        System.Move(Fraction[(Precision div 2) - PFieldRecord(FCDSFields[Field.FieldNo-1])^.Length],
                    DestBuf^, PFieldRecord(FCDSFields[Field.FieldNo-1])^.Length);
        if Boolean(SignSpecialPlaces AND $80) then
          Byte(DestBuf[0]) := Byte(DestBuf[0]) OR $F0;
      end; // with
    FLD_STRING, FLD_PICTURE :
      begin
        FillChar(DestBuf^, Field.DataSize, 0);
        System.Move(SrcBuf^, DestBuf^, PFieldRecord(FCDSFields[Field.FieldNo-1])^.Length);
        if FOemConvert then
          CharToOemBuff(DestBuf, DestBuf, PFieldRecord(FCDSFields[Field.FieldNo-1])^.Length);
      end;
    FLD_GROUP :
      begin
      end;
  end; // case
  DataEvent(deFieldChange, Longint(Field));
end;

procedure TClarionDataSet.InternalHandleException;
begin
  Application.HandleException(Self);
end;

function TClarionDataSet.GetCanModify: Boolean;
begin
  Result := (FOpenMode = fmOpenReadWrite);
end;

function TClarionDataSet.GetRecordSize : Word;
begin
  Result := FHeader.RecLen;
end;

function TClarionDataSet.AllocRecordBuffer : PChar;
begin
  GetMem(Result, FRecBufSize);
end;

procedure TClarionDataSet.FreeRecordBuffer(var Buffer : PChar);
begin
  FreeMem(Buffer, FRecBufSize);
end;

(* Bookmarks *)

procedure TClarionDataSet.InternalGotoBookmark(Bookmark: Pointer);
begin
  FCurRec := PLongInt(Bookmark)^;
end;

procedure TClarionDataSet.InternalSetToRecord(Buffer: PChar);
begin
  InternalGotoBookmark(@PRecInfo(Buffer + GetRecordSize).Bookmark);
end;

function TClarionDataSet.GetBookmarkFlag(Buffer: PChar): TBookmarkFlag;
begin
  Result := PRecInfo(Buffer + GetRecordSize).BookmarkFlag;
end;

procedure TClarionDataSet.SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag);
begin
  PRecInfo(Buffer + GetRecordSize).BookmarkFlag := Value;
end;

procedure TClarionDataSet.GetBookmarkData(Buffer: PChar; Data: Pointer);
begin
  PLongInt(Data)^ := PRecInfo(Buffer + GetRecordSize).Bookmark;
end;

procedure TClarionDataSet.SetBookmarkData(Buffer: PChar; Data: Pointer);
begin
  PRecInfo(Buffer + GetRecordSize).Bookmark := PLongInt(Data)^;
end;

(* Optional Methods *)

function TClarionDataSet.GetRecordCount : LongInt;
begin
  Result := FHeader.NumRecs + FHeader.NumDels;
end;

function TClarionDataSet.GetRecNo : LongInt;
begin
  UpdateCursorPos;
  if (FCurRec = -1) and (RecordCount > 0) then
    Result := 1
  else
    Result := FCurRec + 1;
end;

procedure TClarionDataSet.SetRecNo(Value : Integer);
begin
  if (Value > -1) and (Value < FHeader.NumRecs) then begin
    FCurRec := Value;
    Resync([]);
  end;
end;

(* Record Navigation/Editing*)

procedure TClarionDataSet.InternalFirst;
begin
  FCurRec := -1;
end;

procedure TClarionDataSet.InternalLast;
begin
  FCurRec := FHeader.NumRecs + FHeader.NumDels;
end;

procedure TClarionDataSet.InternalPost;
begin
  if IsTableEncrypted then
    DecodeBuffer( ActiveBuffer[SizeOf(TDataHeader)], GetRecordSize - SizeOf(TDataHeader), FId );
  case State of
  dsEdit :
    begin
      FFile.Seek( FHeader.Offset + FHeader.RecLen * FCurRec, soFromBeginning );
      FFile.Write( ActiveBuffer^, GetRecordSize );
    end;
  dsInsert :
    begin
      FFile.Seek( 0, soFromEnd );
      FFile.Write( ActiveBuffer^, GetRecordSize );
      Inc(FHeader.NumRecs);
      _InternalWriteHeader;
    end;
  end;
end;

procedure TClarionDataSet.InternalAddRecord(Buffer: Pointer; Append: Boolean);
begin
  raise Exception.Create('TClarionDataSet.InternalAddRecord Not Implemented Yet !');
end;

procedure TClarionDataSet.InternalDelete;
Var RecStatus : Byte;
begin
  { Only mark record as delted }
  RecStatus := Byte(ActiveBuffer[0]) OR DATA_DEL;
  FFile.Seek( FHeader.Offset + FHeader.RecLen * FCurRec, soFromBeginning );
  FFile.Write( RecStatus, SizeOf(RecStatus) );
  Dec(FHeader.NumRecs);
  Inc(FHeader.NumDels);
  _InternalWriteHeader;
end;

(* CRACK *)

procedure TClarionDataSet.SetPassword(APwd : String);
Var i, k : Byte;
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

function TClarionDataSet.CalcCheckSum : Word;
Var i : Byte;
begin
  Result := 0;
  for i := 0 to SizeOf(THeader) - 3 do Result := Result + PByteArray(@FHeader)^[i];
end;

procedure TClarionDataSet.DecodeHeader(ID : Word);
Var i : byte;
begin
  for i := 2 to 41 do
    PWordArray(@FHeader)^[i] := PWordArray(@FHeader)^[i] XOR ID;
end;

function TClarionDataSet.CheckHeader(ID : Word) : Boolean;
Var
  ChkSum : Word;
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

(* IsRecord... functions *)

function TClarionDataSet.IsRecordNew : Boolean;
begin
  Result := Boolean(Byte(ActiveBuffer[0]) AND DATA_NEW);
end;

function TClarionDataSet.IsRecordOld : Boolean;
begin
  Result := Boolean(Byte(ActiveBuffer[0]) AND DATA_OLD);
end;

function TClarionDataSet.IsRecordRevised : Boolean;
begin
  Result := Boolean(Byte(ActiveBuffer[0]) AND DATA_REV);
end;

function TClarionDataSet.IsRecordDeleted : Boolean;
begin
  Result := Boolean(Byte(ActiveBuffer[0]) AND DATA_DEL);
end;

function TClarionDataSet.IsRecordHeld : Boolean;
begin
  Result := Boolean(Byte(ActiveBuffer[0]) AND DATA_HLD);
end;

(* IsTable... functions *)

function TClarionDataSet.IsTableLocked : Boolean;
begin
  Result := Boolean( FHeader.SFAtr AND SIGN_LOCKED );
end;

function TClarionDataSet.IsTableOwned : Boolean;
begin
  Result := Boolean( FHeader.SFAtr AND SIGN_OWNED );
end;

function TClarionDataSet.IsTableEncrypted : Boolean;
begin
  Result := Boolean( FHeader.SFAtr AND SIGN_ENCRYPTED );
end;

function TClarionDataSet.IsTableHaveMemo : Boolean;
begin
  Result := Boolean( FHeader.SFAtr AND SIGN_MEMO );
end;

function TClarionDataSet.IsTableCompressed : Boolean;
begin
  Result := Boolean( FHeader.SFAtr AND SIGN_COMPRESSED );
end;

function TClarionDataSet.IsTableReclaim : Boolean;
begin
  Result := Boolean( FHeader.SFAtr AND SIGN_RECLAIM );
end;

function TClarionDataSet.IsTableReadonly : Boolean;
begin
  Result := Boolean( FHeader.SFAtr AND SIGN_READONLY );
end;

function TClarionDataSet.IsTableCreated : Boolean;
begin
  Result := Boolean( FHeader.SFAtr AND SIGN_CREATED );
end;

(* Set Open/Share mode functions *)

procedure TClarionDataSet.SetBlobToCache(Value : Boolean);
begin
  CheckInactive;
  FBlobToCache := Value;
end;

procedure TClarionDataSet.SetReadOnly(Value : Boolean);
begin
  CheckInactive;
  if Value then
    FOpenMode := fmOpenRead
  else
    FOpenMode := fmOpenReadWrite;
  FReadOnly := Value;
end;

procedure TClarionDataSet.SetExclusive(Value : Boolean);
begin
  CheckInactive;
  if Value then
    FShareMode := fmShareExclusive
  else
    FShareMode := fmShareDenyNone;
  FExclusive := Value;
end;

(* BLOB *)

function TClarionDataSet.CreateBlobStream(Field : TField; Mode : TBlobStreamMode) : TStream;
begin
  Result := TClarionMemoStream.Create(Field as TBlobField, Mode);
end;

function TClarionDataSet.GetBlobFieldData(FieldNo : Integer; var Buffer : TBlobByteData) : Integer;
begin
  Result := 0; { No additional information in record }
end;

(* TClarionMemoStream implementation *)

constructor TClarionMemoStream.Create(Field: TBlobField; Mode: TBlobStreamMode);
Var
  Buf : TMemoData;
  i : Integer;
begin
  FMode := Mode;
  FField := Field;
  FDataSet := FField.DataSet as TClarionDataSet;
  FRPtr := PDataHeader(FDataSet.ActiveBuffer)^.RPtr;
  inherited Create( ChangeFileExt(FDataSet.TableName, '.MEM'), FDataSet.FShareMode OR FDataSet.FOpenMode );

  inherited Read( FHeader, Sizeof(FHeader) );
  if FHeader.MemoSIG <> MEMO_21_SIG then
    raise Exception.Create('ERR_INVALID_MEMO_HEADER');

  if FDataSet.FBlobToCache then begin
    i := 1;
    inherited Seek( RPtrToOffset(FRPtr), soFromBeginning );
    SetLength( FBlobData, GetBlobSize );
    repeat
      inherited Read( Buf, SizeOf(Buf) );
      Move( Buf.Memo, FBlobData[i], SizeOf(Buf.Memo) );
      Inc( i, SizeOf(Buf.Memo) );
      inherited Seek( RPtrToOffset(Buf.NextBlock), soFromBeginning );
    until Buf.NextBlock = 0;
  end;
  FPosition := 0;
end;

destructor TClarionMemoStream.Destroy;
begin
  if FOpened AND FModified then
    FField.Modified := True;
  if FModified then
    try
      FDataSet.DataEvent(deFieldChange, Longint(FField));
    except
      Application.HandleException(Self);
    end;
  SetLength(FBlobData, 0);
  inherited Destroy;
end;

function TClarionMemoStream.Read(var Buffer; Count: Longint): Longint;
begin
  if FDataSet.FBlobToCache then
    Move( FBlobData[FPosition + 1], Buffer, Count )
  else begin
    { !!! }
  end;
  if FDataSet.FOemConvert then OemToCharBuff(@PChar(Buffer), @PChar(Buffer), Count);
  Result := Count;
end;

function TClarionMemoStream.Write(const Buffer; Count: Longint): Longint;
begin
  if FDataSet.FOemConvert then OemToCharBuff(@PChar(Buffer), @PChar(Buffer), Count);
  case FDataSet.State of
  dsEdit :
    begin
    end;
  dsInsert :
    begin
    end;
  end;
  Result := Count;
end;

function TClarionMemoStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  case Origin of
    0: FPosition := Offset;
    1: Inc(FPosition, Offset);
    2: FPosition := GetBlobSize + Offset;
  end;
  Result := FPosition;
end;

function TClarionMemoStream.RPtrToOffset(RPtr : Integer) : LongInt;
begin
  Result := ((RPtr - 1) SHL 8) + 6;
end;

function TClarionMemoStream.OffsetToRPtr(Offset : Integer) : LongInt;
begin
  Result := ((Offset - 6) SHR 8 ) + 1;
end;

function TClarionMemoStream.GetBlobSize: Longint;
begin
  Result := FDataSet.FHeader.MemoLen;
end;

(***** Internal Utility Functions *****)

function PatchFieldName( S : String ) : String;
begin
  Result := Trim(Copy(S, 5, Length(S)));
end;

procedure DecodeBuffer( Var Buf; BufSize, Id : Word );
var i : integer;
begin
  for i := 0 to ( BufSize div 2 ) - 1 do TWordArray(Buf)[i] := TWordArray(Buf)[i] XOR Id;
end;

(* Registration *)

procedure Register;
begin
  RegisterComponents('Data Access', [TClarionDataSet]);
end;

END.

