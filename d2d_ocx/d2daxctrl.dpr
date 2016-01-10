library D2DAXCtrl;

uses
  ComServ,
  D2DAXCtrl_TLB in 'D2DAXCtrl_TLB.pas';

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
