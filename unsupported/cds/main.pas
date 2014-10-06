unit Main;

interface

uses
  Forms, Dialogs, DBGrids, Db, CDS, StdCtrls, Menus,
  Grids, Controls, Classes, ExtCtrls, DBCtrls;

type
  TMainForm = class(TForm)
    OpenDialog1: TOpenDialog;
    MainMenu: TMainMenu;
    FileItems: TMenuItem;
    OpenItem: TMenuItem;
    CloseItem: TMenuItem;
    N1: TMenuItem;
    ExitItem: TMenuItem;
    SearchItem: TMenuItem;
    CGrid: TDBGrid;
    CTable: TClarionDataSet;
    DataSource1: TDataSource;
    DBMemo1: TDBMemo;
    procedure OpenClick(Sender: TObject);
    procedure CloseClick(Sender: TObject);
    procedure FindClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ExitItemClick(Sender: TObject);
    procedure CTableAfterOpen(DataSet: TDataSet);
    procedure CTableAfterClose(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses Find, SysUtils;

{$R *.DFM}

procedure TMainForm.OpenClick(Sender: TObject);
begin
  if OpenDialog1.Execute then begin
    if CTable.Active then CTable.Close;
    CTable.TableName := OpenDialog1.FileName;
    Caption := OpenDialog1.FileName;
    CTable.Open;
    SearchItem.Enabled := CTable.Active;
  end;
end;

procedure TMainForm.CloseClick(Sender: TObject);
begin
  if CTable.Active then CTable.Close;
  SearchItem.Enabled := CTable.Active;
end;

procedure TMainForm.FindClick(Sender: TObject);
begin
  FindForm.Show;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  if ParamCount > 0 then begin
    CTable.TableName := ParamStr(1);
    Caption := CTable.TableName;
    CTable.Open;
    SearchItem.Enabled := CTable.Active;
  end;
end;

procedure TMainForm.ExitItemClick(Sender: TObject);
begin
  if CTable.Active then CTable.Close;
  Close;
end;

procedure TMainForm.CTableAfterOpen(DataSet: TDataSet);
begin
  with CTable do
    if CTable.IsTableHaveMemo then begin
      DBMemo1.DataSource := DataSource1;
      DBMemo1.DataField := CTable.Fields[Fields.Count-1].FieldName;
      DBMemo1.Visible := True;
    end;
end;

procedure TMainForm.CTableAfterClose(DataSet: TDataSet);
begin
  with CTable do begin
    DBMemo1.DataSource := Nil;
    DBMemo1.DataField := '';
    DBMemo1.Visible := False;
  end;
end;

end.
