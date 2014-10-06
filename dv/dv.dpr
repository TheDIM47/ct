program dv;

uses
  {$IFDEF WIN32}
  Forms,
  {$ELSE}
  QForms,
  {$ENDIF}
  dvmain in 'dvmain.pas' {DvForm},
  find in 'find.pas' {FindForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDvForm, DvForm);
  Application.CreateForm(TFindForm, FindForm);
  Application.Run;
end.
