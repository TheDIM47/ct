unit Find;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TFindForm = class(TForm)
    FindEdit: TEdit;
    FieldsCombo: TComboBox;
    FindButton: TButton;
    CloseButton: TButton;
    procedure CloseButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FindButtonClick(Sender: TObject);
    procedure FindEditChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FindForm: TFindForm;

implementation

uses Main, DB, Math;

{$R *.DFM}

procedure TFindForm.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TFindForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TFindForm.FormShow(Sender: TObject);
var i : Integer;
begin
 FieldsCombo.Items.Clear;
  with MainForm.CTable do
    for i := 0 to Fields.Count - 1 do
      FieldsCombo.Items.Add(Fields[i].FieldName);
  FieldsCombo.ItemIndex := MainForm.CGrid.SelectedIndex;
end;

procedure TFindForm.FindButtonClick(Sender: TObject);
Var
  Finded : Boolean;
  Len : Integer;
begin
  Finded := False;
  with MainForm.CTable do begin
    DisableControls;
    if Fields[FieldsCombo.ItemIndex].DataType = ftString then begin
      Len := Min(Length(Fields[FieldsCombo.ItemIndex].AsString), Length(FindEdit.Text));
      while NOT Eof do begin
        if AnsiStrLIComp(@Fields[FieldsCombo.ItemIndex].AsString[1],
                         @FindEdit.Text[1], Len) = 0 then begin
          Finded := True;
          break;
        end; // if
        Next;
      end; // while
    end else begin
      while NOT Eof do begin
        if AnsiCompareText(Fields[FieldsCombo.ItemIndex].AsString, FindEdit.Text) = 0 then begin
          Finded := True;
          break;
        end; // if
        Next;
      end; // while
    end;
    EnableControls;
  end;
  if Finded then Caption := 'SEARCH SUCCESS' else Caption := 'SEARCH FAILED';
end;

procedure TFindForm.FindEditChange(Sender: TObject);
begin
  FindButton.Enabled := (Length(FindEdit.Text) > 0);
end;

end.
