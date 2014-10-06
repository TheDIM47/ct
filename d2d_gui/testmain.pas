unit testmain;

interface
{$H-}{$IFDEF VER140}{$J+}{$ENDIF}

{$IFDEF LINUX}
{$INCLUDE ../d2dx.inc}
{$ELSE}
{$INCLUDE ..\d2dx.inc}
{$ENDIF}

uses
  {$IFDEF WIN32}
  Forms, Dialogs, StdCtrls,
  Graphics, ExtCtrls, Controls, Buttons,
  {$ELSE}
  QForms, QDialogs, QStdCtrls, QButtons,
  QGraphics, QExtCtrls, QControls,
  {$ENDIF}
  d2dx, Classes;

type
  TForm1 = class(TForm)
    eSource: TEdit;
    Label1: TLabel;
    eTarget: TEdit;
    Label2: TLabel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Panel1: TPanel;
    Bevel1: TBevel;
    Label3: TLabel;
    OpenDialog1: TOpenDialog;
    Panel2: TPanel;
    Bevel2: TBevel;
    btnGo: TBitBtn;
    cbAppendMode: TCheckBox;
    cbDateSupport: TCheckBox;
    cbUndelete: TCheckBox;
    cbArraySupport: TCheckBox;
    cbRepeatable: TCheckBox;
    cbOemConvert: TCheckBox;
    GroupBox1: TGroupBox;
    Label4: TLabel;
    eContains: TEdit;
    Label5: TLabel;
    eStarted: TEdit;
    Image1: TImage;
    Label6: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnGoClick(Sender: TObject);
    procedure sbClick(Sender: TObject);
    procedure eChanged(Sender: TObject);
  private
    { Private declarations }
    DAX : TD2DX;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

Uses SysUtils;

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  DAX := TD2DX.Create(Self);
  with DAX do begin
    cbAppendMode.Checked := AppendMode;
    cbDateSupport.Checked := DateSupport;
    cbArraySupport.Checked := ArraySupport;
    cbUndelete.Checked := UnDelMode;
    cbRepeatable.Checked := Repeatable;
    cbOemConvert.Checked := OemConvert;
  end;
  OpenDialog1.InitialDir := ExtractFileDir(ParamStr(0));
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DAX.Free;
end;

procedure TForm1.btnGoClick(Sender: TObject);
begin
  with DAX do begin
    AppendMode := cbAppendMode.Checked;
    DateSupport := cbDateSupport.Checked;
    ArraySupport := cbArraySupport.Checked;
    UnDelMode := cbUndelete.Checked;
    Repeatable := cbRepeatable.Checked;
    OemConvert := cbOemConvert.Checked;
    //
    DateContains := eContains.Text; // !!!!!!!!
    DateStarted  := eStarted.Text;  // !!!!!!!!
    //
    Screen.Cursor := crHourglass;
    btnGo.Enabled := False;
    try
      Go(eSource.Text, eTarget.Text);
    finally
      Screen.Cursor := crDefault;
      btnGo.Enabled := True;
    end;
  end;
end;

procedure TForm1.sbClick(Sender: TObject);
begin
  OpenDialog1.FileName := '';

  if Sender = SpeedButton2 then
    OpenDialog1.Filter := 'dBASE files (*.DBF)|*.DBF'
  else
    OpenDialog1.Filter := 'Clarion files (*.DAT)|*.DAT';

  with OpenDialog1 do
    if Execute then
      if Sender = SpeedButton2 then
        eTarget.Text := OpenDialog1.FileName
      else begin
        eSource.Text := OpenDialog1.FileName;
        eTarget.Text := ChangeFileExt(eSource.Text, '.DBF');
      end;
end;

procedure TForm1.eChanged(Sender: TObject);
begin
  btnGo.Enabled := ( Length(eSource.Text) > 0 ) AND ( Length(eTarget.Text) > 0 );
end;

end.
