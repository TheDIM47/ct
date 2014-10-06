unit dvmain;

interface

{$H-}{$IFDEF VER140}{$J+}{$ENDIF}
{$IFDEF LINUX}
{$INCLUDE ../d2dx.inc}
{$ELSE}
{$INCLUDE ..\d2dx.inc}
{$ENDIF}

uses
  {$IFDEF WIN32}
  Windows, Messages, Graphics, Controls, Forms,
  Grids, Menus, Dialogs, StdCtrls, ComCtrls,
  {$ELSE}
  QMenus, QTypes, QDialogs, QControls, QGrids, QForms, Types,
  {$ENDIF}
  SysUtils, Classes,
  clarion, cldb;

type
  TDvForm = class(TForm)
    Grid: TDrawGrid;
    OpenDialog1: TOpenDialog;
    Clarion: TctClarion;
    Trn: TctTransaction;
    SaveDialog1: TSaveDialog;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    ExporttoText1: TMenuItem;
    Exit1: TMenuItem;
    Options1: TMenuItem;
    PatchNames: TMenuItem;
    Find1: TMenuItem;
    Selectfont1: TMenuItem;
    FontDialog1: TFontDialog;
    procedure FormCreate(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure PatchNamesClick(Sender: TObject);
    procedure Find1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure ExporttoText1Click(Sender: TObject);
    procedure Selectfont1Click(Sender: TObject);
  private
    { Private declarations }
    procedure OpenTable(FileName : String);
    procedure CloseTable;
  public
    { Public declarations }
    Cur : TctCursor;
    FldNames : TStringList;
    FPatchNames : Boolean;
    Function GetFieldValue(j: Integer) : String;
  end;

var
  DvForm: TDvForm;

implementation

uses find
{$IFDEF VER140}
{$IFDEF USE_VARIANT}
, Variants
{$ENDIF}
{$ENDIF}
;

{$R *.dfm}

// added by Final Filer Software
Function TDvForm.GetFieldValue(j: Integer) : String;
var s : String;
begin
  try
    case Clarion.Fields[j].GetFieldType of
      FLD_SHORT:
        S := IntToStr(Cur.GetShort(Clarion.Fields[j]));
      FLD_BYTE:
        S := IntToStr(Cur.GetByte(Clarion.Fields[j]));
      FLD_LONG:
        if Pos('DATE', Clarion.Fields[j].GetFieldName) > 0 then
          S := DateToStr(Cur.GetDate(Clarion.Fields[j]))
        else
          if Pos('TIME', Clarion.Fields[j].GetFieldName) > 0 then
            S := TimeToStr(Cur.GetTime(Clarion.Fields[j]))
          else
            S := IntToStr(Cur.GetInteger(Clarion.Fields[j]));
      FLD_PICTURE,
      FLD_STRING:
        S := {$IFDEF WIN32}
             OemToChar(Cur.GetString(Clarion.Fields[j]));
             {$ELSE}
             Cur.GetString(Clarion.Fields[j]);
             {$ENDIF}
      FLD_REAL:
        S := FloatToStr(Cur.GetDouble(Clarion.Fields[j]));
      FLD_DECIMAL:
        S := FloatToStr(Cur.GetDecimal(Clarion.Fields[j]));
      FLD_GROUP: S := '';
    end // case
  except
    s := ''
  end;
  result := trim(s);
end;

procedure TDvForm.FormCreate(Sender: TObject);
begin
  Grid.Align := alClient;
  Grid.ColWidths[0] := 40;
  FldNames := TStringList.Create;
  FldNames.Sorted := False;
  FPatchNames := True;
end;

procedure TDvForm.Open1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then OpenTable(OpenDialog1.FileName);
end;

procedure TDvForm.Exit1Click(Sender: TObject);
begin
  CloseTable;
  FldNames.Destroy;
  DvForm.Close;
end;

procedure TDvForm.CloseTable;
begin
  Grid.ColCount := 2; Grid.Col := 1;
  Grid.RowCount := 2; Grid.Row := 1;
  if Clarion.Active then begin
    Cur.Free;
    Cur := Nil;
    Clarion.Close;
    FldNames.Clear;
  end;
end;

procedure TDvForm.OpenTable(FileName : String);
var
  s : string;
  i, pfx_len : integer;
begin
  if Clarion.Active then CloseTable;
  Clarion.FileName := FileName;
  try
    Clarion.Open;
  except
    raise;
    exit;
  end;
  Cur := TctCursor.Create( Clarion, 16384, coForward );

  pfx_len := Length( Clarion.GetFilePrefix ) + 2;

  Grid.ColCount := Clarion.GetFieldCount + 1;
  Grid.RowCount := Clarion.GetRecordCount + 1;
  DvForm.Caption := Clarion.FileName;

  for i := 0 to Clarion.GetFieldCount - 1 do begin
    s := Clarion.Fields[i].GetFieldName;
    if FPatchNames then
      s := Copy( s, pfx_len, Length(s)-pfx_len );
    if Clarion.Fields[i].IsArray then
      s := Trim(s) + '(' + IntToStr(Clarion.Arrays[Clarion.Fields[i].GetArrayNumber-1].GetDim(0)) + ')';
    FldNames.Add(Trim(s));
  end;
end;

procedure TDvForm.GridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
Var
  S : String;
  j : Integer;
begin
  if Clarion.Active then begin
    if ARow = 0 then begin
      if ACol > 0 then
        S := FldNames[ACol-1]
      else
        S := '';
    end else
      if ACol = 0 then
        S := IntToStr( ARow )
      else begin
        Cur.GotoRecord( ARow - 1 );
        j := ACol - 1;
        case Clarion.Fields[j].GetFieldType of
          FLD_SHORT:
            S := IntToStr(Cur.GetShort(Clarion.Fields[j]));
          FLD_BYTE:
            S := IntToStr(Cur.GetByte(Clarion.Fields[j]));
          FLD_LONG:
            if Pos('DATE', Clarion.Fields[j].GetFieldName) > 0 then
              S := DateToStr(Cur.GetDate(Clarion.Fields[j]))
            else
              if Pos('TIME', Clarion.Fields[j].GetFieldName) > 0 then
                S := TimeToStr(Cur.GetTime(Clarion.Fields[j]))
              else
                S := IntToStr(Cur.GetInteger(Clarion.Fields[j]));
          FLD_PICTURE,
          FLD_STRING:
            S := {$IFDEF WIN32}
                 OemToChar(Cur.GetString(Clarion.Fields[j]));
                 {$ELSE}
                 Cur.GetString(Clarion.Fields[j]);
                 {$ENDIF}
          FLD_REAL:
            S := FloatToStr(Cur.GetDouble(Clarion.Fields[j]));
          FLD_DECIMAL:
            S := FloatToStr(Cur.GetDecimal(Clarion.Fields[j]));
          FLD_GROUP: S := '';
        end; // case
      end;
    Grid.Canvas.FillRect( Rect );
    Grid.Canvas.TextRect( Rect, Rect.Left + 2, Rect.Top + 2, S );
  end;
end;

procedure TDvForm.PatchNamesClick(Sender: TObject);
begin
  PatchNames.Checked := not PatchNames.Checked;
  FPatchNames := PatchNames.Checked;
end;

procedure TDvForm.Find1Click(Sender: TObject);
begin
  if Clarion.Active then
    FindForm.Show
  else
    ShowMessage('Open table, first...');
end;

procedure TDvForm.FormActivate(Sender: TObject);
begin
  if ParamCount > 0 then OpenTable(ParamStr(1));
end;

procedure TDvForm.Selectfont1Click(Sender: TObject);
begin
  if FontDialog1.Execute then
    Grid.Font := FontDialog1.Font;
end;

procedure TDvForm.GridDblClick(Sender: TObject);
Var
  {$IFDEF USE_VARIANT}
  A : Variant;
  i, j : Word;
  {$ENDIF}
  s : string;
begin
  if Clarion.Fields[Grid.Col-1].IsArray then begin
    Cur.GotoRecord(Grid.Row - 1);
    {$IFDEF USE_VARIANT}
    A := Cur.GetVariant(Clarion.Fields[Grid.Col-1]);
    s := '';
    j := VarArrayHighBound(A, 1);
    for i := 0 to j do
      case VarType(A[i]) of
        varSmallInt:
          s := s + IntToStr(A[i]) + ';';
        varByte:
          s := s + IntToStr(A[i]) + ';';
        varInteger:
          s := s + IntToStr(A[i]) + ';';
        varOleStr:
          s := s + A[i] + ';';
        varDouble:
          s := s + FloatToStr(A[i]) + ';';
      end;
    ShowMessage(s);
    VarClear(A);
    {$ELSE}
    S := Cur.GetArrayAsString(Clarion.Fields[Grid.Col-1]);
    ShowMessage(s);    
    {$ENDIF}
  end;
end;

procedure TDvForm.ExporttoText1Click(Sender: TObject);
var f : TextFile;
    s, f1 : String;
    j, pfx_len: Integer;
begin
// this routine exports the current data to a text file.
// the first row will contain the field names
// added by Final Filer Software

  SaveDialog1.FileName := ChangeFileExt (OpenDialog1.FileName,'.txt');

  if SaveDialog1.Execute then          { Display Open dialog box }
    begin
    Screen.cursor := crHourglass;
    Rewrite (F, SaveDialog1.FileName);   { File selected in dialog box }
    //Reset(F);

           s := '';
           f1 := '';
          // loop thru fields
            for j := 0 to Clarion.GetFieldCount - 1 do begin
            f1 := Clarion.Fields[j].GetFieldName;
            pfx_len := Length( Clarion.GetFilePrefix ) + 2;

            if FPatchNames then
                f1 := trim(Copy( f1, pfx_len, Length(f1)-pfx_len ));

             if Clarion.Fields[j].IsArray then // fixed by Igor Zakhrebetkov
               f1 := Trim(f1) + Trim(IntToStr(Clarion.Arrays[Clarion.Fields[j].GetArrayNumber-1].GetDim(0)));
//             f1 := Trim(f1) +  trim(IntToStr(Clarion.Arrays[Clarion.Fields[i].GetArrayNumber-1].GetDim(0)));

              if length(s) = 0 then
                 s := #34 + f1 + #34
              else
                 s := s + ', ' +  #34 + f1 + #34;

             end ; // field count

          // write field Header list
           Writeln(F, S);

          // export field values
          s := '';
          f1 := '';
          cur.GotoFirst  ;
          while not(cur.EOF ) do begin
              s := '';
              f1 := '';
               for j := 0 to Clarion.GetFieldCount - 1 do begin
                  f1 := GetFieldValue (j);
                  if length(s) = 0 then
                      s := #34 + f1 + #34
                  else
                    s := s + ',' + #34 + f1 + #34;
                end ; // fields
             Writeln(F, S);
             cur.gotonext;
         end; // get record

    closeFile(F);
    Screen.cursor := crDefault;
    MessageDlg('The data has been exported to '+#13+#10+ SaveDialog1.filename, mtInformation, [mbOK], 0);
   end;
End;



end.