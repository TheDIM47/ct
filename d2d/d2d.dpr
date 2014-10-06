(*
** Clarion DAT table to dBASE DBF packet converter
** Copyright (C) by Dmitry Koudryavtsev
** http://juliasoft.chat.ru
** juliasoft@mail.ru
*)
program D2d;
{$APPTYPE CONSOLE}
{$H-}{$J+}

uses
  d2dx, SysUtils, clarion, Classes
  {$IFDEF WIN32}
  ,Windows
  {$ENDIF}
  ;

const
  SUCCESS          =  0;
  CMD_LINE_ERROR   = -1;
  CFG_FILE_INVALID = -2;

Const
  InDir : String = {$IFDEF WIN32}'.\'{$ELSE}''{$ENDIF};
  OutDir : String = {$IFDEF WIN32}'.\'{$ELSE}''{$ENDIF};

Var
  FileList : TStringList;
  D : TD2DX;

procedure Init;
begin
  FileList := TStringList.Create;
end;

procedure Done;
begin
  FileList.Free;
end;

procedure PrintHeader;
begin
  WriteLn;
  WriteLn('DAT2DBF Clarion to dBASE table packet converter v' + TOOLKIT_VERSION );
  WriteLn('Under GNU Public License. Volgograd, RUSSIA, 1999-2002');
  WriteLn('Copyright (C) by Dmitry Koudryavtsev, juliasoft@mail.ru');
end;

procedure PrintHelp;
begin
  PrintHeader;
  WriteLn('Usage:');
  WriteLn('DAT2DBF[.EXE] [[-|/]{@IORDEAUWY}] {files}');
  WriteLn(' -I<InboundDir> clarion tables path');
  WriteLn(' -O<OutboundDir> outbound dBASE tables path');
  WriteLn(' -R[+|-] repeatable opening on|off; default:on');
  WriteLn(' -D[+|-] DATE fields support on|off; default:off');
  WriteLn(' -DS<date field names started with... delimited by ";">');
  WriteLn(' -DC<date field names contains... delimited by ";">');
  WriteLn(' -E[+|-] OEM convert on|off; default:off');
  WriteLn(' -A[+|-] append mode on|off; default:off');
  WriteLn(' -U[+|-] undelete mode on|off; default:off');
  WriteLn(' -W<msec> msec wait for file unlock; default: INFINITE');
  WriteLn(' -Y[+|-] array conversion to string field; default: off');
  WriteLn(' -@<ParamFile>');
  WriteLn(' {files} files to convert');
  WriteLn;
end;

function ParseCmdWord(S : String) : Integer;
Var
  F : Text;
  S1 : String;
begin
  Result := SUCCESS;
  if (S[1] <> '-') AND (S[1] <> '/') then begin
    if Pos(EXTENSION, UpperCase(S)) = 0 then S := S + EXTENSION;
    FileList.Add(S);
  end else begin
    case UpCase(S[2]) of
      'I': InDir  := Copy(S, 3, Length(S));
      'O': OutDir := Copy(S, 3, Length(S));
      'E': if S[3] = '-' then
             D.OemConvert := False
           else
             D.OemConvert := True;
      'D': case UpCase(S[3]) of
             '-' : D.DateSupport := False;
             '+' : D.DateSupport := True;
             'S' : D.DateStarted := Copy(S, 4, Length(S)-3);
             'C' : D.DateContains := Copy(S, 4, Length(S)-3);
           else
             begin
               WriteLn('Invalid Keyword');
               Result := CMD_LINE_ERROR;
               exit;
             end;
           end;
      'A': if S[3] = '-' then
             D.AppendMode := False
           else
             D.AppendMode := True;
      'U': if S[3] = '-' then
             D.UnDelMode := False
           else
             D.UnDelMode := True;
      'R': if S[3] = '-' then
             D.Repeatable := False
           else
             D.Repeatable := True;
      'Y': if S[3] = '-' then
             D.ArraySupport := False
           else
             D.ArraySupport := True;
      'W': begin
             try
               D.MsecWait := StrToInt(Copy(S, 3, Length(S)));
             except
               WriteLn('Error in /W key. INFINITE value will be used.');
               D.MsecWait := DIM_INFINITE;
             end;
           end;
      '@': begin
             {$I-}
             System.Assign( F, Copy(S, 3, Length(S)) );
             System.ReSet(F);
             {$I+}
             if System.IOResult <> 0 then begin
               WriteLn('Invalid configuration file');
               Result := CFG_FILE_INVALID;
               exit;
             end;
             while ( not Eof(F) ) AND ( Result = 0 ) do begin
               ReadLn( F, S1 );
               Result := ParseCmdWord( S1 );
               if Result <> SUCCESS then break;
             end;
             Close(F);
           end;
      else begin
        WriteLn('Invalid Keyword');
        Result := CMD_LINE_ERROR;
      end;
    end; // case
  end;
end;

Var
  i : Byte;
  T : TDateTime;
begin
  D := TD2DX.Create(Nil);
  if ParamCount = 0 then PrintHelp
  else begin
    PrintHeader;
    Init;
    for i := 1 to ParamCount do
      if ParseCmdWord(ParamStr(i)) <> SUCCESS then begin
        Done;
        D.Free;
        exit;
      end; // for
    CheckSlash(InDir);
    CheckSlash(OutDir);
    if FileList.Count = 0 then begin
      WriteLn('ERROR: Nothing to convert');
      exit;
    end;
    for i := 0 to FileList.Count - 1 do
      if FileExists(ExpandFileName(InDir+FileList[i])) then begin
        Write('BEGIN: ', ExpandFileName(InDir+FileList[i]));
        T := Now;
        try
          D.Go( ExpandFileName(InDir+FileList[i]),
                ExpandFileName(OutDir+ChangeFileExt(FileList[i], '.dbf')) );
        finally
          WriteLn(' DONE: ', FormatDateTime('hh:nn:ss:zz', Now - T));
        end;
      end else
        WriteLn('ERROR: File ', ExpandFileName(InDir+FileList[i]), ' not exists');
    Done;
  end; // if ParamCount
  if Assigned(D) then D.Free;
end.

