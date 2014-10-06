unit find;

interface

uses
  {$IFDEF WIN32}
  Windows, Messages, Graphics, Controls, Forms,
  Grids, Menus, Dialogs, StdCtrls, ComCtrls, ExtCtrls,
  {$ELSE}
  QMenus, QTypes, QDialogs, QControls, QGrids, QForms, 
  Types, QExtCtrls, QStdCtrls,
  {$ENDIF}
  SysUtils, Classes,
  clarion, cldb;

{$H+}

type
  TFindForm = class(TForm)
    FindEdit: TEdit;
    FieldCombo: TComboBox;
    FindButton: TButton;
    CancelButton: TButton;
    DirGrp: TRadioGroup;
    FindNextButton: TButton;
    procedure CancelButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FindButtonClick(Sender: TObject);
    procedure FindNextButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FindCur : TctCursor;
    function Compare(AText : String; ACur : TctCursor; AFld : TctField) : Boolean;
    function SearchForward(AText : String; AFld : TctField) : Boolean;
    function SearchBackward(AText : String; AFld : TctField) : Boolean;
  end;

var
  FindForm: TFindForm;

implementation

uses DvMain;

{$R *.dfm}

procedure TFindForm.CancelButtonClick(Sender: TObject);
begin
  Hide;
  FindCur.Free;
end;

procedure TFindForm.FormShow(Sender: TObject);
Var
  i, pfx_len : Integer;
  s : string;
begin
  FieldCombo.Items.Clear;
  with DvForm do begin
    pfx_len := Length( Clarion.GetFilePrefix ) + 2;
    for i := 0 to Clarion.GetFieldCount - 1 do begin
      s := Clarion.Fields[i].GetFieldName;
      if FPatchNames then
        s := Copy( s, pfx_len, Length(s)-pfx_len );
      FieldCombo.Items.Add(Trim(s));
    end;
    FindCur := TctCursor.Create(Clarion, 16384, coNormal);
    FieldCombo.ItemIndex := Grid.Col - 1;
  end;
end;

function TFindForm.Compare(AText : String; ACur : TctCursor; AFld : TctField) : Boolean;
//Var S : String;
begin
  Result := False;
  case AFld.GetFieldType of
    FLD_LONG,
    FLD_BYTE,
    FLD_SHORT:
      Result := ( StrToInt(AText) = ACur.GetInteger(AFld) );
    FLD_PICTURE,
    FLD_STRING:
      Result := ( Pos( AText, ACur.GetString(AFld) ) > 0 );
    FLD_REAL:
      Result := ( StrToFloat(AText) = ACur.GetDouble(AFld) );
    FLD_DECIMAL:
      Result := ( StrToFloat(AText) = ACur.GetDecimal(AFld) );
  end; // case
end;

function TFindForm.SearchForward(AText : String; AFld : TctField) : Boolean;
begin
  Result := False;
  with DvForm do begin
    FindCur.SetBalance(coFastForw);
    while not FindCur.EOF do begin
      if Compare(AText, FindCur, AFld) then begin
        Grid.Row := FindCur.GetCurrRecNo + 1;
        Grid.Col := FieldCombo.ItemIndex + 1; // ???
        Result := True;
        break;
      end;
      FindCur.GotoNext;
    end;
  end;
end;

function TFindForm.SearchBackward(AText : String; AFld : TctField) : Boolean;
begin
  Result := False;
  with DvForm do begin
    FindCur.SetBalance(coFastBack);
    while not FindCur.BOF do begin
      if Compare(AText, FindCur, AFld) then begin
        Grid.Row := FindCur.GetCurrRecNo + 1;
        Grid.Col := FieldCombo.ItemIndex + 1; // ???
        Result := True;
        break;
      end;
      FindCur.GotoPrev;
    end;
  end;
end;

procedure TFindForm.FindButtonClick(Sender: TObject);
Var
  SRes : Boolean;
  NRec : Integer;
begin
  FindForm.Caption := 'Find';
  Application.ProcessMessages;
  with DvForm do begin
    NRec := Cur.GetCurrRecNo;
    FindCur.GotoRecord(NRec);
    if DirGrp.ItemIndex = 0 then
      SRes := SearchForward( {$IFDEF WIN32}
                             CharToOem(FindEdit.Text),
                             {$ELSE}
                             FindEdit.Text,
                             {$ENDIF}
                             Clarion.Fields[FieldCombo.ItemIndex] )
    else
      SRes := SearchBackward( {$IFDEF WIN32}
                             CharToOem(FindEdit.Text),
                             {$ELSE}
                             FindEdit.Text,
                             {$ENDIF}
                             Clarion.Fields[FieldCombo.ItemIndex] );
    if SRes then begin
      FindForm.Caption := 'Find: Search Ok';
      Grid.Row := FindCur.GetCurrRecNo + 1;
    end else begin
      FindForm.Caption := 'Find: Search Failed';
      FindCur.GotoRecord(NRec);
    end;
  end;
end;

procedure TFindForm.FindNextButtonClick(Sender: TObject);
begin
  with DvForm do
    if DirGrp.ItemIndex = 0 then Cur.GotoNext else Cur.GotoPrev;
  FindButtonClick(Sender);
end;

end.
