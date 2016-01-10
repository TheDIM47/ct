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
// File generated on 21.10.2002 16:25:45 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\JOBDIR\D2DaX\d2d_ocx\D2DAXCtrl.tlb (1)
// LIBID: {122EDE5B-BD3E-4702-9DEC-BCB4BBF74978}
// LCID: 0
// Helpfile: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINNT2\System32\STDOLE2.TLB)
//   (2) v4.0 StdVCL, (C:\WINNT2\System32\stdvcl40.dll)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{.$VARPROPSETTER ON}
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

  LIBID_D2DAXCtrl: TGUID = '{122EDE5B-BD3E-4702-9DEC-BCB4BBF74978}';

  IID_ID2DAX: TGUID = '{6B3D565C-3088-4371-8BCF-F9A3C40FA612}';
  DIID_ID2DAXEvents: TGUID = '{8E3C23CD-DDE2-4CD7-96F3-898D2C8A060C}';
  CLASS_D2DAX: TGUID = '{3DD33659-B7B1-44DC-8833-3477939829A0}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum TxOemCvtType
type
  TxOemCvtType = TOleEnum;
const
  ocOemToChar = $00000000;
  ocCharToOem = $00000001;
  ocNone = $00000002;

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
// GUID:      {6B3D565C-3088-4371-8BCF-F9A3C40FA612}
// *********************************************************************//
  ID2DAX = interface(IDispatch)
    ['{6B3D565C-3088-4371-8BCF-F9A3C40FA612}']
    procedure Go(const InFile: WideString; const OutFile: WideString); safecall;
    function Get_Repeatable: WordBool; safecall;
    procedure Set_Repeatable(Value: WordBool); safecall;
    function Get_AppendMode: WordBool; safecall;
    procedure Set_AppendMode(Value: WordBool); safecall;
    function Get_UnDelMode: WordBool; safecall;
    procedure Set_UnDelMode(Value: WordBool); safecall;
    function Get_MsecWait: Integer; safecall;
    procedure Set_MsecWait(Value: Integer); safecall;
    function Get_ArraySupport: WordBool; safecall;
    procedure Set_ArraySupport(Value: WordBool); safecall;
    function Get_OemConvert: TxOemCvtType; safecall;
    procedure Set_OemConvert(Value: TxOemCvtType); safecall;
    function Get_DateSupport: WordBool; safecall;
    procedure Set_DateSupport(Value: WordBool); safecall;
    function Get_DateContains: WideString; safecall;
    procedure Set_DateContains(const Value: WideString); safecall;
    function Get_DateStarted: WideString; safecall;
    procedure Set_DateStarted(const Value: WideString); safecall;
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
    property Repeatable: WordBool read Get_Repeatable write Set_Repeatable;
    property AppendMode: WordBool read Get_AppendMode write Set_AppendMode;
    property UnDelMode: WordBool read Get_UnDelMode write Set_UnDelMode;
    property MsecWait: Integer read Get_MsecWait write Set_MsecWait;
    property ArraySupport: WordBool read Get_ArraySupport write Set_ArraySupport;
    property OemConvert: TxOemCvtType read Get_OemConvert write Set_OemConvert;
    property DateSupport: WordBool read Get_DateSupport write Set_DateSupport;
    property DateContains: WideString read Get_DateContains write Set_DateContains;
    property DateStarted: WideString read Get_DateStarted write Set_DateStarted;
    property DoubleBuffered: WordBool read Get_DoubleBuffered write Set_DoubleBuffered;
    property AlignDisabled: WordBool read Get_AlignDisabled;
    property VisibleDockClientCount: Integer read Get_VisibleDockClientCount;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property Cursor: Smallint read Get_Cursor write Set_Cursor;
    property HelpType: TxHelpType read Get_HelpType write Set_HelpType;
    property HelpKeyword: WideString read Get_HelpKeyword write Set_HelpKeyword;
  end;

// *********************************************************************//
// DispIntf:  ID2DAXDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {6B3D565C-3088-4371-8BCF-F9A3C40FA612}
// *********************************************************************//
  ID2DAXDisp = dispinterface
    ['{6B3D565C-3088-4371-8BCF-F9A3C40FA612}']
    procedure Go(const InFile: WideString; const OutFile: WideString); dispid 1;
    property Repeatable: WordBool dispid 2;
    property AppendMode: WordBool dispid 3;
    property UnDelMode: WordBool dispid 4;
    property MsecWait: Integer dispid 5;
    property ArraySupport: WordBool dispid 6;
    property OemConvert: TxOemCvtType dispid 7;
    property DateSupport: WordBool dispid 8;
    property DateContains: WideString dispid 9;
    property DateStarted: WideString dispid 10;
    property DoubleBuffered: WordBool dispid 11;
    property AlignDisabled: WordBool readonly dispid 12;
    property VisibleDockClientCount: Integer readonly dispid 13;
    function DrawTextBiDiModeFlagsReadingOnly: Integer; dispid 15;
    property Enabled: WordBool dispid -514;
    procedure InitiateAction; dispid 16;
    function IsRightToLeft: WordBool; dispid 17;
    function UseRightToLeftReading: WordBool; dispid 20;
    function UseRightToLeftScrollBar: WordBool; dispid 21;
    property Visible: WordBool dispid 22;
    property Cursor: Smallint dispid 23;
    property HelpType: TxHelpType dispid 24;
    property HelpKeyword: WideString dispid 25;
    procedure SetSubComponent(IsSubComponent: WordBool); dispid 27;
  end;

// *********************************************************************//
// DispIntf:  ID2DAXEvents
// Flags:     (0)
// GUID:      {8E3C23CD-DDE2-4CD7-96F3-898D2C8A060C}
// *********************************************************************//
  ID2DAXEvents = dispinterface
    ['{8E3C23CD-DDE2-4CD7-96F3-898D2C8A060C}']
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
    property  ControlInterface: ID2DAX read GetControlInterface;
    property  DefaultInterface: ID2DAX read GetControlInterface;
    property Repeatable: WordBool index 2 read GetWordBoolProp write SetWordBoolProp;
    property AppendMode: WordBool index 3 read GetWordBoolProp write SetWordBoolProp;
    property UnDelMode: WordBool index 4 read GetWordBoolProp write SetWordBoolProp;
    property MsecWait: Integer index 5 read GetIntegerProp write SetIntegerProp;
    property ArraySupport: WordBool index 6 read GetWordBoolProp write SetWordBoolProp;
    property OemConvert: TOleEnum index 7 read GetTOleEnumProp write SetTOleEnumProp;
    property DateSupport: WordBool index 8 read GetWordBoolProp write SetWordBoolProp;
    property DateContains: WideString index 9 read GetWideStringProp write SetWideStringProp;
    property DateStarted: WideString index 10 read GetWideStringProp write SetWideStringProp;
    property DoubleBuffered: WordBool index 11 read GetWordBoolProp write SetWordBoolProp;
    property AlignDisabled: WordBool index 12 read GetWordBoolProp;
    property VisibleDockClientCount: Integer index 13 read GetIntegerProp;
    property Enabled: WordBool index -514 read GetWordBoolProp write SetWordBoolProp;
    property Visible: WordBool index 22 read GetWordBoolProp write SetWordBoolProp;
  published
    property Cursor: Smallint index 23 read GetSmallintProp write SetSmallintProp stored False;
    property HelpType: TOleEnum index 24 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property HelpKeyword: WideString index 25 read GetWideStringProp write SetWideStringProp stored False;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'Servers';

implementation

uses ComObj;

procedure TD2DAX.InitControlData;
const
  CControlData: TControlData2 = (
    ClassID: '{3DD33659-B7B1-44DC-8833-3477939829A0}';
    EventIID: '';
    EventCount: 0;
    EventDispIDs: nil;
    LicenseKey: nil (*HR:$80040154*);
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

procedure Register;
begin
  RegisterComponents('ActiveX',[TD2DAX]);
end;

end.
