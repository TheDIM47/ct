program d2dgui;

uses
  {$IFDEF WIN32}
  Forms,
  {$ELSE}
  QForms,
  {$ENDIF}
  testmain in 'testmain.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
