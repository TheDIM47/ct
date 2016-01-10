(*
** CLARION TO INTERBASE GDB CONVERTER
** Copyright (C) by Dmitry Koudryavtsev
** Under GNU Public License
*)
unit sparser;

INTERFACE

Uses Classes, SysUtils,
{$IFDEF WIN32}
Windows,
{$ENDIF}
IBDatabase;

{$IFDEF VER140} {$J+} {$ENDIF}

type
  TKeySign = (
    KEY_INVALID,
    KEY_DBNAME,
    KEY_USER,
    KEY_PASSWORD,
    KEY_COLLTYPE,
    KEY_FIELD,
    KEY_SUPERGEN,
    KEY_COMAFTER,
    KEY_UNDELETE,
    KEY_WAITFOR,
    KEY_FROM_LOCALE,
    KEY_DEST_LOCALE,    KEY_ARR2STR,
    KEY_DELETE_OLD,
    KEY_DATE_SUPPORT,
    KEY_DATE_STARTED,
    KEY_DATE_CONTAINS,
    KEY_TIME_SUPPORT,
    KEY_TIME_STARTED,
    KEY_TIME_CONTAINS,
    KEY_CDB
  );

type
  TKeyWord = record
    KeySign : TKeySign;
    KeyWord : String;
  end;

const
  MAX_KEY = 20;
  KeyWords : array[1..MAX_KEY] of TKeyWord = (
    ( KeySign : KEY_DBNAME   ; KeyWord : 'DBName'      ),
    ( KeySign : KEY_USER     ; KeyWord : 'User'        ),
    ( KeySign : KEY_PASSWORD ; KeyWord : 'Password'    ),
    ( KeySign : KEY_COLLTYPE ; KeyWord : 'Collation'   ),
    ( KeySign : KEY_FIELD    ; KeyWord : 'Field'       ),
    ( KeySign : KEY_SUPERGEN ; KeyWord : 'UseSuperGen' ),
    ( KeySign : KEY_COMAFTER ; KeyWord : 'CommitAfter' ),
    ( KeySign : KEY_UNDELETE ; KeyWord : 'Undelete'    ),
    ( KeySign : KEY_WAITFOR  ; KeyWord : 'WaitFor'     ),
    ( KeySign : KEY_FROM_LOCALE ; KeyWord : 'SourceLocale' ),
    ( KeySign : KEY_DEST_LOCALE ; KeyWord : 'TargetLocale' ),    ( KeySign : KEY_ARR2STR  ; KeyWord : 'ArrayAsStr'  ),
    ( KeySign : KEY_DELETE_OLD ; KeyWord : 'DeleteOld'  ),
    ( KeySign : KEY_DATE_SUPPORT  ; KeyWord : 'DateSupport'  ),
    ( KeySign : KEY_DATE_STARTED  ; KeyWord : 'DateStarted'  ),
    ( KeySign : KEY_DATE_CONTAINS ; KeyWord : 'DateContains' ),
    ( KeySign : KEY_TIME_SUPPORT  ; KeyWord : 'TimeSupport'  ),
    ( KeySign : KEY_TIME_STARTED  ; KeyWord : 'TimeStarted'  ),
    ( KeySign : KEY_TIME_CONTAINS ; KeyWord : 'TimeContains' ),
    ( KeySign : KEY_CDB      ; KeyWord : 'CDb'         )
  );

type
  PCDbDatabase = ^TCDbDatabase;
  TCDbDatabase = record
    OffID,                   // Office ID
    CDbID     : Byte;        // Clarion Database ID
    CDbPath   : ShortString; // Path to Database files
    CDbInc    : Boolean;     // Incremental mode
    CDbTables : TStringList; // Files to convert
  end;

type
  PFldRecord = ^TFldRecord;
  TFldRecord = record
    FldName,
    FldNewName : String;
  end;

  TFieldNoSet = set of Byte;

const
  DefConfigFile = 'DAT2GDB.CNF';

// Function Prototypes

procedure ReadSetup( FileName : String;
                     Var AGdb : TIBDatabase;
                     Var ACDb : TList;   // of CDbDatabase
                     Var AFld : TList ); // of FldRecord

function YesNoToBool(S : String) : Boolean;

function  IsDateField(Value : String) : Boolean;
procedure SetDateContains(Value : String);
procedure SetDateStarted(Value : String);

function  IsTimeField(Value : String) : Boolean;
procedure SetTimeContains(Value : String);
procedure SetTimeStarted(Value : String);

Var
  FDateContains, FDateStarted : TStringList;
  FDateFields : TFieldNoSet;
  //
  FTimeContains, FTimeStarted : TStringList;
  FTimeFields : TFieldNoSet;
  //
  IcvtID    : Pointer;     // for iconv

const
  UseSuperGen : Boolean = True;
  CommitAfter : LongInt = 1000;
  Undelete    : Boolean = False;
  ArrayAsStr  : Boolean = False;
  DateSupport : Boolean = False;
  TimeSupport : Boolean = False;
  DeleteOld   : Boolean = True;
  MsecWait    : LongWord = {$IFDEF WIN32}INFINITE{$ELSE}1000{$ENDIF};
  SourceLocale : String = 'ASCII';
  TargetLocale : String = 'ASCII';

IMPLEMENTATION

// Internal Functions

function GetKeySign(S : String) : TKeySign;
Var i : integer;
begin
  i := MAX_KEY;
  while i >= 1 do begin
    if AnsiCompareText( S, KeyWords[i].KeyWord ) = 0 then begin
      Result := KeyWords[i].KeySign;
      exit;
    end;
    Dec(i);
  end;
  Result := KEY_INVALID;
end;

function YesNoToBool(S : String) : Boolean;
begin
  Result := ( AnsiCompareText( S, 'YES' ) = 0 );
end;

procedure ExtractKeyVal(S : String; Var sKey, sVal : String);
var i : integer;
begin
  i := Pos('=', S);
  sKey := Trim( Copy( S, 1, i - 1 ) );
  sVal := Trim( Copy( S, i + 1, Length(S)-i ) );
end;

// Parser

procedure ReadSetup( FileName : String;
                     Var AGdb : TIBDatabase;
                     Var ACDb : TList;
                     Var AFld : TList ); // of FldRecord

  function GetLineToken(Var S : String) : String;
  Var i : integer;
  begin
    i := Pos(';', S);
    if (i = 0) AND (Length(S) > 0) then begin
      Result := Trim(S);
      S := '';
    end else begin
      Result := Trim(Copy(S, 1, i-1));
      Delete(S, 1, i);
    end;
    Result := Trim(Result);
  end;

Var
  F : Text;
  S, sKey, sVal: String;
  CDbRec : PCDbDatabase;
  FldRec : PFldRecord;
begin
  AssignFile(F, FileName);
  FileMode := 0; // R/O
  Reset(F);
  if (IOResult = 0) AND (FileName <> '') then begin
    while NOT Eof(F) do begin
      ReadLn(F, S);
      S := Trim(S);
      if ( Length(S) = 0 ) then continue;                // empty line
      if ( S[1] = ';' ) OR ( S[1] = '#' ) then continue; // comment
      ExtractKeyVal(S, sKey, sVal);
      with AGdb do
        Case GetKeySign(sKey) of
          KEY_DBNAME  : DatabaseName := sVal;
          KEY_USER    : Params.Add('isc_dpb_user_name=' + sVal);
          KEY_SUPERGEN : UseSuperGen := YesNoToBool(sVal);
          KEY_COMAFTER : CommitAfter := StrToInt(sVal);
          KEY_DELETE_OLD : DeleteOld := YesNoToBool(sVal);

          KEY_FROM_LOCALE : SourceLocale := Trim(sVal) + #0;
          KEY_DEST_LOCALE : TargetLocale := Trim(sVal) + #0;

          KEY_DATE_SUPPORT  : DateSupport := YesNoToBool(sVal);
          KEY_DATE_STARTED  : SetDateStarted(sVal);
          KEY_DATE_CONTAINS : SetDateContains(sVal);

          KEY_TIME_SUPPORT  : TimeSupport := YesNoToBool(sVal);
          KEY_TIME_STARTED  : SetTimeStarted(sVal);
          KEY_TIME_CONTAINS : SetTimeContains(sVal);

          KEY_WAITFOR:  try
                          MsecWait  := StrToInt(sVal);
                        except
                          MsecWait  := {$IFDEF WIN32}INFINITE{$ELSE}10000{$ENDIF};
                        end;
          KEY_UNDELETE: Undelete    := YesNoToBool(sVal);
          KEY_ARR2STR : ArrayAsStr  := YesNoToBool(sVal);
          KEY_COLLTYPE: Params.Add('isc_dpb_lc_ctype=' + sVal);
          KEY_PASSWORD:
            begin
              LoginPrompt := False;
              if Length(sVal) = 0 then
                LoginPrompt := True
              else
                Params.Add('isc_dpb_password=' + sVal)
            end;
          KEY_FIELD:
            begin
              New(FldRec);
              With FldRec^ do begin
                FldName := GetLineToken(sVal);
                FldNewName := GetLineToken(sVal);
              end; // with FldRec
              AFld.Add(FldRec);
            end;
          KEY_CDB:
            begin
              New(CDbRec);
              with CDbRec^ do begin
                OffID   := StrToInt(GetLineToken(sVal));
                CDbID   := StrToInt(GetLineToken(sVal));
                CDbInc  := YesNoToBool(GetLineToken(sVal));
                CDbPath := GetLineToken(sVal);
                CDbTables := TStringList.Create;
                while Length(sVal) > 0 do CDbTables.Add(GetLineToken(sVal));
              end; // with CDbRec
              ACDb.Add(CDbRec);
            end;
          // Invalid Key
          KEY_INVALID: WriteLn( 'Invalid Key: "' + sKey + '" - check your config file.');
        end; // with - case
    end; // while
    CloseFile(F);
  end; // if IOResult
end;

// Date begins

function IsDateField(Value : String) : Boolean;
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

procedure SetDateContains(Value : String);
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
        Delete(S, 1, i);
      end else
        FDateContains.Add(S);
    until i = 0;
  end;
end;

procedure SetDateStarted(Value : String);
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
        Delete(S, 1, i);
      end else
        FDateStarted.Add(S);
    until i = 0;
  end;
end;

// Date end

// Time begins
function IsTimeField(Value : String) : Boolean;
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

procedure SetTimeContains(Value : String);
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

procedure SetTimeStarted(Value : String);
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

// Time end

initialization

  FDateContains := TStringList.Create;
  FDateStarted := TStringList.Create;

  FTimeContains := TStringList.Create;
  FTimeStarted := TStringList.Create;

finalization

  if Assigned(FDateContains) then FDateContains.Free;
  if Assigned(FDateStarted) then FDateStarted.Free;

  if Assigned(FTimeContains) then FTimeContains.Free;
  if Assigned(FTimeStarted) then FTimeStarted.Free;

end.