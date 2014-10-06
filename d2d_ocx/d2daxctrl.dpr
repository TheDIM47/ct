library D2DAXCtrl;

uses
  ComServ,
  D2DAXCtrl_TLB in 'D2DAXCtrl_TLB.pas',
  D2DA in 'D2DA.pas' {D2DAX: CoClass},
  About in 'About.pas' {D2DAXAboutBox};

{$E ocx}

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}

{$R *.RES}

begin
end.
