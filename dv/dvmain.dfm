object DvForm: TDvForm
  Left = 216
  Top = 221
  Width = 484
  Height = 291
  HorzScrollBar.Range = 369
  VertScrollBar.Range = 169
  ActiveControl = Grid
  AutoScroll = False
  Caption = 'Clarion 2.1 DAT Viewer'
  Color = clButton
  Font.Color = clText
  Font.Height = 11
  Font.Name = 'MS Sans Serif'
  Font.Pitch = fpVariable
  Font.Style = []
  Menu = MainMenu1
  ParentFont = False
  Scaled = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 75
  object Grid: TDrawGrid
    Left = 8
    Top = 8
    Width = 361
    Height = 161
    ColCount = 2
    DefaultColWidth = 60
    DefaultRowHeight = 18
    RowCount = 2
    Font.Color = clText
    Font.Height = 11
    Font.Name = 'MS Sans Serif'
    Font.Pitch = fpVariable
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSizing, goColSizing]
    ParentFont = False
    TabOrder = 0
    OnDblClick = GridDblClick
    OnDrawCell = GridDrawCell
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'Dat'
    Filter = 'Clarion Table|*.dat'
    Title = 'Open Clarion Table'
    Left = 80
    Top = 48
  end
  object Clarion: TctClarion
    Read_Only = False
    Left = 112
    Top = 16
  end
  object Trn: TctTransaction
    Left = 144
    Top = 16
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'txt'
    Filter = 'Text File|*.txt|All FIles|*.*'
    Title = 'Save As'
    Left = 116
    Top = 52
  end
  object MainMenu1: TMainMenu
    Left = 80
    Top = 16
    object File1: TMenuItem
      Caption = 'File'
      object Open1: TMenuItem
        Caption = '&Open'
        OnClick = Open1Click
      end
      object ExporttoText1: TMenuItem
        Caption = '&Export to Text'
        OnClick = ExporttoText1Click
      end
      object Exit1: TMenuItem
        Caption = 'E&xit'
        OnClick = Exit1Click
      end
    end
    object Options1: TMenuItem
      Caption = 'Misc'
      object PatchNames: TMenuItem
        Caption = '&Patch Field Names'
        Checked = True
        OnClick = PatchNamesClick
      end
      object Find1: TMenuItem
        Caption = 'Find'
        OnClick = Find1Click
      end
      object Selectfont1: TMenuItem
        Caption = 'Select font'
        OnClick = Selectfont1Click
      end
    end
  end
  object FontDialog1: TFontDialog
    Font.Color = clBlack
    Font.Height = 13
    Font.Name = 'Helvetica'
    Font.Pitch = fpVariable
    Font.Style = []
    Left = 80
    Top = 80
  end
end
