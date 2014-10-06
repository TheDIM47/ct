unit D2DAXCtrl_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : $Revision:   1.130.1.0.1.0.1.6  $
// File generated on 11.07.2002 13:08:38 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\JOBDIR\D2DaX\D2D_OCX\D2DAXCtrl.tlb (1)
// LIBID: {76834D73-33C8-4C7E-914F-967D535528C0}
// LCID: 0
// Helpfile: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINNT2\System32\stdole2.tlb)
//   (2) v4.0 StdVCL, (C:\WINNT2\System32\stdvcl40.dll)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  D2DAXCtrlMajorVersion = 1;
  D2DAXCtrlMinorVersion = 0;

  LIBID_D2DAXCtrl: TGUID = '{76834D73-33C8-4C7E-914F-967D535528C0}';

  IID_ID2DAX: TGUID = '{81367FBA-79E3-4E96-9D45-C8865A3C9E1E}';
  DIID_ID2DAXEvents: TGUID = '{D338C0DE-47B1-4220-B15C-60355936CFAC}';
  CLASS_D2DAX: TGUID = '{E21BA3C1-B4F9-40A0-8FC6-426E09F7D7D2}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum TxHelpType
type
  TxHelpType = TOleEnum;
const
  htKeyword = $00000000;
  htContext = $00000001;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  ID2DAX = interface;
  ID2DAXDisp = dispinterface;
  ID2DAXEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  D2DAX = ID2DAX;


// *********************************************************************//
// Interface: ID2DAX
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {81367FBA-79E3-4E96-9D45-C8865A3C9E1E}
// *********************************************************************//
  ID2DAX = interface(IDispatch)
    ['{81367FBA-79E3-4E96-9D45-C8865A3C9E1E}']
    procedure Go(const InFile: WideString; const OutFile: WideString); safecall;
    function Get_Repeatable: WordBool; safecall;
    procedure Set_Repeatable(Value: WordBool); safecall;
    function Get_DateSupport: WordBool; safecall;
    procedure Set_DateSupport(Value: WordBool); safecall;
    function Get_AppendMode: WordBool; safecall;
    procedure Set_AppendMode(Value: WordBool); safecall;
    function Get_UnDelMode: WordBool; safecall;
    procedure Set_UnDelMode(Value: WordBool); safecall;
    function Get_MsecWait: LongWord; safecall;
    procedure Set_MsecWait(Value: LongWord); safecall;
    function Get_ArraySupport: WordBool; safecall;
    procedure Set_ArraySupport(Value: WordBool); safecall;
    function Get_DoubleBuffered: WordBool; safecall;
    procedure Set_DoubleBuffered(Value: WordBool); safecall;
    function Get_AlignDisabled: WordBool; safecall;
    function Get_VisibleDockClientCount: Integer; safecall;
    function DrawTextBiDiModeFlagsReadingOnly: Integer; safecall;
    function Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    procedure InitiateAction; safecall;
    function IsRightToLeft: WordBool; safecall;
    function UseRightToLeftReading: WordBool; safecall;
    function UseRightToLeftScrollBar: WordBool; safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function Get_Cursor: Smallint; safecall;
    procedure Set_Cursor(Value: Smallint); safecall;
    function Get_HelpType: TxHelpType; safecall;
    procedure Set_HelpType(Value: TxHelpType); safecall;
    function Get_HelpKeyword: WideString; safecall;
    procedure Set_HelpKeyword(const Value: WideString); safecall;
    procedure SetSubComponent(IsSubComponent: WordBool); safecall;
    procedure AboutBox; safecall;
    function Get_DateContains: WideString; safecall;
    procedure Set_DateContains(const Value: WideString); safecall;
    function Get_DateStarted: WideString; safecall;
    procedure Set_DateStarted(const Value: WideString); safecall;
    function Get_OemConvert: WordBool; safecall;
    procedure Set_OemConvert(Value: WordBool); safecall;
    property Repeatable: WordBool read Get_Repeatable write Set_Repeatable;
    property DateSupport: WordBool read Get_DateSupport write Set_DateSupport;
    property AppendMode: WordBool read Get_AppendMode write Set_AppendMode;
    property UnDelMode: WordBool read Get_UnDelMode write Set_UnDelMode;
    property MsecWait: LongWord read Get_MsecWait write Set_MsecWait;
    property ArraySupport: WordBool read Get_ArraySupport write Set_ArraySupport;
    property DoubleBuffered: WordBool read Get_DoubleBuffered write Set_DoubleBuffered;
    property AlignDisabled: WordBool read Get_AlignDisabled;
    property VisibleDockClientCount: Integer read Get_VisibleDockClientCount;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property Cursor: Smallint read Get_Cursor write Set_Cursor;
    property HelpType: TxHelpType read Get_HelpType write Set_HelpType;
    property HelpKeyword: WideString read Get_HelpKeyword write Set_HelpKeyword;
    property DateContains: WideString read Get_DateContains write Set_DateContains;
    property DateStarted: WideString read Get_DateStarted write Set_DateStarted;
    property OemConvert: WordBool read Get_OemConvert write Set_OemConvert;
  end;

// *********************************************************************//
// DispIntf:  ID2DAXDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {81367FBA-79E3-4E96-9D45-C8865A3C9E1E}
// *********************************************************************//
  ID2DAXDisp = dispinterface
    ['{81367FBA-79E3-4E96-9D45-C8865A3C9E1E}']
    procedure Go(const InFile: WideString; const OutFile: WideString); dispid 1;
    property Repeatable: WordBool dispid 2;
    property DateSupport: WordBool dispid 3;
    property AppendMode: WordBool dispid 4;
    property UnDelMode: WordBool dispid 5;
    property MsecWait: LongWord dispid 6;
    property ArraySupport: WordBool dispid 7;
    property DoubleBuffered: WordBool dispid 8;
    property AlignDisabled: WordBool readonly dispid 9;
    property VisibleDockClientCount: Integer readonly dispid 10;
    function DrawTextBiDiModeFlagsReadingOnly: Integer; dispid 12;
    property Enabled: WordBool dispid -514;
    procedure InitiateAction; dispid 13;
    function IsRightToLeft: WordBool; dispid 14;
    function UseRightToLeftReading: WordBool; dispid 17;
    function UseRightToLeftScrollBar: WordBool; dispid 18;
    property Visible: WordBool dispid 19;
    property Cursor: Smallint dispid 20;
    property HelpType: TxHelpType dispid 21;
    property HelpKeyword: WideString dispid 22;
    procedure SetSubComponent(IsSubComponent: WordBool); dispid 24;
    procedure AboutBox; dispid -552;
    property DateContains: WideString dispid 23;
    property DateStarted: WideString dispid 25;
    property OemConvert: WordBool dispid 26;
  end;

// *********************************************************************//
// DispIntf:  ID2DAXEvents
// Flags:     (4096) Dispatchable
// GUID:      {D338C0DE-47B1-4220-B15C-60355936CFAC}
// *********************************************************************//
  ID2DAXEvents = dispinterface
    ['{D338C0DE-47B1-4220-B15C-60355936CFAC}']
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TD2DAX
// Help String      : D2DAX Control
// Default Interface: ID2DAX
// Def. Intf. DISP? : No
// Event   Interface: ID2DAXEvents
// TypeFlags        : (34) CanCreate Control
// *********************************************************************//
  TD2DAX = class(TOleControl)
  private
    FIntf: ID2DAX;
    function  GetControlInterface: ID2DAX;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    procedure Go(const InFile: WideString; const OutFile: WideString);
    function DrawTextBiDiModeFlagsReadingOnly: Integer;
    procedure InitiateAction;
    function IsRightToLeft: WordBool;
    function UseRightToLeftReading: WordBool;
    function UseRightToLeftScrollBar: WordBool;
    procedure SetSubComponent(IsSubComponent: WordBool);
    procedure AboutBox;
    property  ControlInterface: ID2DAX read GetControlInterface;
    property  DefaultInterface: ID2DAX read GetControlInterface;
    property Repeatable: WordBool index 2 read GetWordBoolProp write SetWordBoolProp;
    property DateSupport: WordBool index 3 read GetWordBoolProp write SetWordBoolProp;
    property AppendMode: WordBool index 4 read GetWordBoolProp write SetWordBoolProp;
    property UnDelMode: WordBool index 5 read GetWordBoolProp write SetWordBoolProp;
    property MsecWait: Integer index 6 read GetIntegerProp write SetIntegerProp;
    property ArraySupport: WordBool index 7 read GetWordBoolProp write SetWordBoolProp;
    property DoubleBuffered: WordBool index 8 read GetWordBoolProp write SetWordBoolProp;
    property AlignDisabled: WordBool index 9 read GetWordBoolProp;
    property VisibleDockClientCount: Integer index 10 read GetIntegerProp;
    property Enabled: WordBool index -514 read GetWordBoolProp write SetWordBoolProp;
    property Visible: WordBool index 19 read GetWordBoolProp write SetWordBoolProp;
  published
    property  TabStop;
    property  Align;
    property  DragCursor;
    property  DragMode;
    property  ParentShowHint;
    property  PopupMenu;
    property  ShowHint;
    property  TabOrder;
    property  OnDragDrop;
    property  OnDragOver;
    property  OnEndDrag;
    property  OnEnter;
    property  OnExit;
    property  OnStartDrag;
    property Cursor: Smallint index 20 read GetSmallintProp write SetSmallintProp stored False;
    property HelpType: TOleEnum index 21 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property HelpKeyword: WideString index 22 read GetWideStringProp write SetWideStringProp stored False;
    property DateContains: WideString index 23 read GetWideStringProp write SetWideStringProp stored False;
    property DateStarted: WideString index 25 read GetWideStringProp write SetWideStringProp stored False;
    property OemConvert: WordBool index 26 read GetWordBoolProp write SetWordBoolProp stored False;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'Servers';

implementation

uses ComObj;

procedure TD2DAX.InitControlData;
const
  CControlData: TControlData2 = (
    ClassID: '{E21BA3C1-B4F9-40A0-8FC6-426E09F7D7D2}';
    EventIID: '';
    EventCount: 0;
    EventDispIDs: nil;
    LicenseKey: nil (*HR:$00000000*);
    Flags: $00000008;
    Version: 401);
begin
  ControlData := @CControlData;
end;

procedure TD2DAX.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as ID2DAX;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TD2DAX.GetControlInterface: ID2DAX;
begin
  CreateControl;
  Result := FIntf;
end;

procedure TD2DAX.Go(const InFile: WideString; const OutFile: WideString);
begin
  DefaultInterface.Go(InFile, OutFile);
end;

function TD2DAX.DrawTextBiDiModeFlagsReadingOnly: Integer;
begin
  Result := DefaultInterface.DrawTextBiDiModeFlagsReadingOnly;
end;

procedure TD2DAX.InitiateAction;
begin
  DefaultInterface.InitiateAction;
end;

function TD2DAX.IsRightToLeft: WordBool;
begin
  Result := DefaultInterface.IsRightToLeft;
end;

function TD2DAX.UseRightToLeftReading: WordBool;
begin
  Result := DefaultInterface.UseRightToLeftReading;
end;

function TD2DAX.UseRightToLeftScrollBar: WordBool;
begin
  Result := DefaultInterface.UseRightToLeftScrollBar;
end;

procedure TD2DAX.SetSubComponent(IsSubComponent: WordBool);
begin
  DefaultInterface.SetSubComponent(IsSubComponent);
end;

procedure TD2DAX.AboutBox;
begin
  DefaultInterface.AboutBox;
end;

procedure Register;
begin
  RegisterComponents('ActiveX',[TD2DAX]);
end;

end.
