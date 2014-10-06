program Dv2;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  Find in 'Find.pas' {FindForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TFindForm, FindForm);
  Application.Run;
end.
