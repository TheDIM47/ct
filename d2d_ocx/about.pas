unit About;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TD2DAXAboutBox = class(TForm)
    NameLbl: TLabel;
    OkBtn: TButton;
    CopyrightLbl: TLabel;
    DescLbl: TLabel;
    Label1: TLabel;
  end;

procedure ShowD2DAXAbout;

implementation

{$R *.DFM}

procedure ShowD2DAXAbout;
begin
  with TD2DAXAboutBox.Create(nil) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

end.
