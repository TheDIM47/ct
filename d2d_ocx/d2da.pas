unit D2DA;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  ActiveX, AxCtrls, ComServ, D2DAXCtrl_TLB, D2DX, StdVcl;

type
  TD2DAX = class(TActiveXControl, ID2DAX)
  private
    { Private declarations }
    FDelphiControl: TD2DX;
    FEvents: ID2DAXEvents;
  protected
    { Protected declarations }
    procedure DefinePropertyPages(DefinePropertyPage: TDefinePropertyPage); override;
    procedure EventSinkChanged(const EventSink: IUnknown); override;
    procedure InitializeControl; override;
    function DrawTextBiDiModeFlagsReadingOnly: Integer; safecall;
    function Get_AlignDisabled: WordBool; safecall;
    function Get_AppendMode: WordBool; safecall;
    function Get_ArraySupport: WordBool; safecall;
    function Get_Cursor: Smallint; safecall;
    function Get_DateSupport: WordBool; safecall;
    function Get_DoubleBuffered: WordBool; safecall;
    function Get_Enabled: WordBool; safecall;
    function Get_HelpKeyword: WideString; safecall;
    function Get_HelpType: TxHelpType; safecall;
    function Get_MsecWait: LongWord; safecall;
    function Get_Repeatable: WordBool; safecall;
    function Get_UnDelMode: WordBool; safecall;
    function Get_Visible: WordBool; safecall;
    function Get_VisibleDockClientCount: Integer; safecall;
    function IsRightToLeft: WordBool; safecall;
    function UseRightToLeftReading: WordBool; safecall;
    function UseRightToLeftScrollBar: WordBool; safecall;
    procedure AboutBox; safecall;
    procedure Go(const InFile, OutFile: WideString); safecall;
    procedure InitiateAction; safecall;
    procedure Set_AppendMode(Value: WordBool); safecall;
    procedure Set_ArraySupport(Value: WordBool); safecall;
    procedure Set_Cursor(Value: Smallint); safecall;
    procedure Set_DateSupport(Value: WordBool); safecall;
    procedure Set_DoubleBuffered(Value: WordBool); safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    procedure Set_HelpKeyword(const Value: WideString); safecall;
    procedure Set_HelpType(Value: TxHelpType); safecall;
    procedure Set_MsecWait(Value: LongWord); safecall;
    procedure Set_Repeatable(Value: WordBool); safecall;
    procedure Set_UnDelMode(Value: WordBool); safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    procedure SetSubComponent(IsSubComponent: WordBool); safecall;
    function Get_DateContains: WideString; safecall;
    procedure Set_DateContains(const Value: WideString); safecall;
    function Get_DateStarted: WideString; safecall;
    procedure Set_DateStarted(const Value: WideString); safecall;
    function Get_OemConvert: WordBool; safecall;
    procedure Set_OemConvert(Value: WordBool); safecall;
  end;

implementation

uses Controls, Classes, ComObj, About;

{ TD2DAX }

procedure TD2DAX.DefinePropertyPages(DefinePropertyPage: TDefinePropertyPage);
begin
  {TODO: Define property pages here.  Property pages are defined by calling
    DefinePropertyPage with the class id of the page.  For example,
      DefinePropertyPage(Class_D2DAXPage); }
//  DefinePropertyPage(Class_D2DAXPage);
end;

procedure TD2DAX.EventSinkChanged(const EventSink: IUnknown);
begin
  FEvents := EventSink as ID2DAXEvents;
end;

procedure TD2DAX.InitializeControl;
begin
  FDelphiControl := Control as TD2DX;
end;

function TD2DAX.DrawTextBiDiModeFlagsReadingOnly: Integer;
begin
  Result := FDelphiControl.DrawTextBiDiModeFlagsReadingOnly;
end;

function TD2DAX.Get_AlignDisabled: WordBool;
begin
  Result := FDelphiControl.AlignDisabled;
end;

function TD2DAX.Get_AppendMode: WordBool;
begin
  Result := FDelphiControl.AppendMode;
end;

function TD2DAX.Get_ArraySupport: WordBool;
begin
  Result := FDelphiControl.ArraySupport;
end;

function TD2DAX.Get_Cursor: Smallint;
begin
  Result := Smallint(FDelphiControl.Cursor);
end;

function TD2DAX.Get_DateSupport: WordBool;
begin
  Result := FDelphiControl.DateSupport;
end;

function TD2DAX.Get_DoubleBuffered: WordBool;
begin
  Result := FDelphiControl.DoubleBuffered;
end;

function TD2DAX.Get_Enabled: WordBool;
begin
  Result := FDelphiControl.Enabled;
end;

function TD2DAX.Get_HelpKeyword: WideString;
begin
  Result := WideString(FDelphiControl.HelpKeyword);
end;

function TD2DAX.Get_HelpType: TxHelpType;
begin
  Result := Ord(FDelphiControl.HelpType);
end;

function TD2DAX.Get_MsecWait: LongWord;
begin
  Result := LongWord(FDelphiControl.MsecWait);
end;

function TD2DAX.Get_Repeatable: WordBool;
begin
  Result := FDelphiControl.Repeatable;
end;

function TD2DAX.Get_UnDelMode: WordBool;
begin
  Result := FDelphiControl.UnDelMode;
end;

function TD2DAX.Get_Visible: WordBool;
begin
  Result := FDelphiControl.Visible;
end;

function TD2DAX.Get_VisibleDockClientCount: Integer;
begin
  Result := FDelphiControl.VisibleDockClientCount;
end;

function TD2DAX.IsRightToLeft: WordBool;
begin
  Result := FDelphiControl.IsRightToLeft;
end;

function TD2DAX.UseRightToLeftReading: WordBool;
begin
  Result := FDelphiControl.UseRightToLeftReading;
end;

function TD2DAX.UseRightToLeftScrollBar: WordBool;
begin
  Result := FDelphiControl.UseRightToLeftScrollBar;
end;

procedure TD2DAX.AboutBox;
begin
  ShowD2DAXAbout;
end;

procedure TD2DAX.Go(const InFile, OutFile: WideString);
begin
  FDelphiControl.Go(InFile, OutFile);
end;

procedure TD2DAX.InitiateAction;
begin
  FDelphiControl.InitiateAction;
end;

procedure TD2DAX.Set_AppendMode(Value: WordBool);
begin
  FDelphiControl.AppendMode := Value;
end;

procedure TD2DAX.Set_ArraySupport(Value: WordBool);
begin
  FDelphiControl.ArraySupport := Value;
end;

procedure TD2DAX.Set_Cursor(Value: Smallint);
begin
  FDelphiControl.Cursor := TCursor(Value);
end;

procedure TD2DAX.Set_DateSupport(Value: WordBool);
begin
  FDelphiControl.DateSupport := Value;
end;

procedure TD2DAX.Set_DoubleBuffered(Value: WordBool);
begin
  FDelphiControl.DoubleBuffered := Value;
end;

procedure TD2DAX.Set_Enabled(Value: WordBool);
begin
  FDelphiControl.Enabled := Value;
end;

procedure TD2DAX.Set_HelpKeyword(const Value: WideString);
begin
  FDelphiControl.HelpKeyword := String(Value);
end;

procedure TD2DAX.Set_HelpType(Value: TxHelpType);
begin
  FDelphiControl.HelpType := THelpType(Value);
end;

procedure TD2DAX.Set_MsecWait(Value: LongWord);
begin
  FDelphiControl.MsecWait := Cardinal(Value);
end;

procedure TD2DAX.Set_Repeatable(Value: WordBool);
begin
  FDelphiControl.Repeatable := Value;
end;

procedure TD2DAX.Set_UnDelMode(Value: WordBool);
begin
  FDelphiControl.UnDelMode := Value;
end;

procedure TD2DAX.Set_Visible(Value: WordBool);
begin
  FDelphiControl.Visible := Value;
end;

procedure TD2DAX.SetSubComponent(IsSubComponent: WordBool);
begin
  FDelphiControl.SetSubComponent(IsSubComponent);
end;


function TD2DAX.Get_DateContains: WideString;
begin
  Result := FDelphiControl.DateContains;
end;

procedure TD2DAX.Set_DateContains(const Value: WideString);
begin
  FDelphiControl.DateContains := ShortString(Value);
end;

function TD2DAX.Get_DateStarted: WideString;
begin
  Result := FDelphiControl.DateStarted;
end;

procedure TD2DAX.Set_DateStarted(const Value: WideString);
begin
  FDelphiControl.DateStarted := Value;
end;

function TD2DAX.Get_OemConvert: WordBool;
begin
  Result := FDelphiControl.OemConvert;
end;

procedure TD2DAX.Set_OemConvert(Value: WordBool);
begin
  FDelphiControl.OemConvert := Value;
end;

initialization
  TActiveXControlFactory.Create(
    ComServer,
    TD2DAX,
    TD2DX,
    Class_D2DAX,
    1,
    '',
    0,
    tmApartment);
end.
