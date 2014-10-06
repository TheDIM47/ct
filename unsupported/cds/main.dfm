object MainForm: TMainForm
  Left = 192
  Top = 106
  Width = 420
  Height = 203
  Caption = 'DAT Viewer v.2.0'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  Scaled = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object CGrid: TDBGrid
    Left = 0
    Top = 0
    Width = 412
    Height = 94
    Align = alClient
    DataSource = DataSource1
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object DBMemo1: TDBMemo
    Left = 0
    Top = 94
    Width = 412
    Height = 63
    Align = alBottom
    TabOrder = 1
    Visible = False
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Clarion 2.1 DAT|*.DAT'
    InitialDir = 'C:\JOBDIR\CDS'
    Title = 'Clarion DAT Open Dialog'
    Left = 192
    Top = 8
  end
  object MainMenu: TMainMenu
    Left = 160
    Top = 8
    object FileItems: TMenuItem
      Caption = 'File'
      object OpenItem: TMenuItem
        Caption = 'Open'
        OnClick = OpenClick
      end
      object CloseItem: TMenuItem
        Caption = 'Close'
        OnClick = CloseClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object ExitItem: TMenuItem
        Caption = 'Exit'
        OnClick = ExitItemClick
      end
    end
    object SearchItem: TMenuItem
      Caption = 'Search'
      Enabled = False
      OnClick = FindClick
    end
  end
  object CTable: TClarionDataSet
    TableName = 'CMD.DAT'
    ReadOnly = False
    Exclusive = False
    OemConvert = True
    AfterOpen = CTableAfterOpen
    AfterClose = CTableAfterClose
    Left = 96
    Top = 8
  end
  object DataSource1: TDataSource
    DataSet = CTable
    Left = 128
    Top = 8
  end
end
