object Form1: TForm1
  Left = 350
  Top = 173
  Width = 438
  Height = 305
  HorzScrollBar.Range = 423
  VertScrollBar.Range = 258
  ActiveControl = eSource
  AutoScroll = False
  Caption = 'D2D GUI Edition'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = 11
  Font.Name = 'MS Sans Serif'
  Font.Pitch = fpVariable
  Font.Style = []
  OldCreateOrder = True
  Position = poDesktopCenter
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object SpeedButton1: TSpeedButton
    Left = 400
    Top = 40
    Width = 23
    Height = 22
    Caption = '...'
    OnClick = SBClick
  end
  object SpeedButton2: TSpeedButton
    Left = 400
    Top = 64
    Width = 23
    Height = 22
    Caption = '...'
    OnClick = SBClick
  end
  object Bevel1: TBevel
    Left = 0
    Top = 32
    Width = 430
    Height = 2
    Align = alTop
  end
  object Bevel2: TBevel
    Left = 0
    Top = 229
    Width = 430
    Height = 2
    Align = alBottom
  end
  object Label1: TLabel
    Left = 8
    Top = 44
    Width = 66
    Height = 12
    Caption = 'Source DAT file'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 12
    Font.Name = 'Arial'
    Font.Pitch = fpVariable
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 8
    Top = 68
    Width = 64
    Height = 12
    Caption = 'Target DBF file'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 12
    Font.Name = 'Arial'
    Font.Pitch = fpVariable
    Font.Style = []
    ParentFont = False
  end
  object eSource: TEdit
    Left = 104
    Top = 40
    Width = 297
    Height = 20
    Hint = 'You can use relative paths'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 12
    Font.Name = 'Arial'
    Font.Pitch = fpVariable
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnChange = eChanged
  end
  object eTarget: TEdit
    Left = 104
    Top = 64
    Width = 297
    Height = 20
    Hint = 'You can use relative paths'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 12
    Font.Name = 'Arial'
    Font.Pitch = fpVariable
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    OnChange = eChanged
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 430
    Height = 32
    Align = alTop
    Alignment = taLeftJustify
    BevelOuter = bvNone
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = 19
    Font.Name = 'MS Sans Serif'
    Font.Pitch = fpVariable
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    object Image1: TImage
      Left = 0
      Top = 0
      Width = 32
      Height = 32
      Align = alLeft
      Picture.Data = {
        07544269746D617036080000424D360800000000000036040000280000002000
        0000200000000100080000000000000400000000000000000000000100000000
        000000000000000080000080000000808000800000008000800080800000C0C0
        C000C0DCC000F0CAA6000020400000206000002080000020A0000020C0000020
        E00000400000004020000040400000406000004080000040A0000040C0000040
        E00000600000006020000060400000606000006080000060A0000060C0000060
        E00000800000008020000080400000806000008080000080A0000080C0000080
        E00000A0000000A0200000A0400000A0600000A0800000A0A00000A0C00000A0
        E00000C0000000C0200000C0400000C0600000C0800000C0A00000C0C00000C0
        E00000E0000000E0200000E0400000E0600000E0800000E0A00000E0C00000E0
        E00040000000400020004000400040006000400080004000A0004000C0004000
        E00040200000402020004020400040206000402080004020A0004020C0004020
        E00040400000404020004040400040406000404080004040A0004040C0004040
        E00040600000406020004060400040606000406080004060A0004060C0004060
        E00040800000408020004080400040806000408080004080A0004080C0004080
        E00040A0000040A0200040A0400040A0600040A0800040A0A00040A0C00040A0
        E00040C0000040C0200040C0400040C0600040C0800040C0A00040C0C00040C0
        E00040E0000040E0200040E0400040E0600040E0800040E0A00040E0C00040E0
        E00080000000800020008000400080006000800080008000A0008000C0008000
        E00080200000802020008020400080206000802080008020A0008020C0008020
        E00080400000804020008040400080406000804080008040A0008040C0008040
        E00080600000806020008060400080606000806080008060A0008060C0008060
        E00080800000808020008080400080806000808080008080A0008080C0008080
        E00080A0000080A0200080A0400080A0600080A0800080A0A00080A0C00080A0
        E00080C0000080C0200080C0400080C0600080C0800080C0A00080C0C00080C0
        E00080E0000080E0200080E0400080E0600080E0800080E0A00080E0C00080E0
        E000C0000000C0002000C0004000C0006000C0008000C000A000C000C000C000
        E000C0200000C0202000C0204000C0206000C0208000C020A000C020C000C020
        E000C0400000C0402000C0404000C0406000C0408000C040A000C040C000C040
        E000C0600000C0602000C0604000C0606000C0608000C060A000C060C000C060
        E000C0800000C0802000C0804000C0806000C0808000C080A000C080C000C080
        E000C0A00000C0A02000C0A04000C0A06000C0A08000C0A0A000C0A0C000C0A0
        E000C0C00000C0C02000C0C04000C0C06000C0C08000C0C0A000F0FBFF00A4A0
        A000808080000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
        FF00F7F700000000F7F7F7F70000000000F7F7F70000F7F7F7F7F7F7F7F7F7F7
        F7F7F7010101010100F7F701010101010000F7010100F7F7F7F7F7F7F7F7F7F7
        F7F7F7010100F7010100F7010100F7F70100F7010100F7F7F7F7F7F7F7F7F7F7
        F7F7F7010100F7010100F7010100000001F7F7010100F7F7F7F7F7F7F7F7F7F7
        F7F7F7010100F7010100F701010101010000F70101000000F7F7F7F7F7F7F7F7
        F7F7F7010100F7010100F7010100F7F70100F701010101F7F7F7F7F7F7F7F7F7
        F7F7F7010100000101F7F7010100000001F7F701010000000000F7F7F7F7F7F7
        F7F7F70101010101F7F7F70101010101F7F7F7010101010101F7F7F7F7F7F7F7
        F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F9F7F7
        F7F7F7000000000000000000000000000000000000000000F7F7F7F7F9F9F9F7
        F7F7F7000700FFFFFFFFFFFF07FFFFFFFFFFFFFFFFFFFF00F7F7F7F9F9F9F9F9
        F7F7F700FF00FF04040404FF07FF04040404FFFFFFFFFF00F7F7F9F9F9F9F9F9
        F9F7F7000700FFFFFFFFFFFF07FFFFFFFFFFFFFFFFFFFF00F7F9F9F9F9F9F9F9
        F9F9F700FF00FF04040404FF07FF0404040404040404FF00F7F7F7F7F9F9F9F7
        F7F7F7000700FFFFFFFFFFFF07FFFFFFFFFFFFFFFFFFFF00F7F7F7F7F9F9F9F7
        F7F7F700FF00FF04040404FF07FF040404040404FFFFFF00F7F7F7F7F9F9F9F7
        F7F7F7000700FFFFFFFFFFFF07FFFFFFFFFFFFFFFFFFFF00F7F7F7F7F9F9F9F7
        F7F7F700FF00FF04040404FF07FF04040404040404FFFF00F7F7F7F7F9F9F9F7
        F7F7F7000700FFFFFFFFFFFF07FFFFFFFFFFFFFFFFFFFF00F7F7F7F7F9F9F9F7
        F7F7F7000000000000000000000000000000000000000000F7F7F7F7F9F9F9F7
        F7F7F7000700FF0707FF070707FF070707FF070707FF0700F7F7F7F7F9F9F9F7
        F7F7F7000000000000000000000000000000000000000000F7F7F7F7F9F9F9F7
        F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F9F9F9F7
        F7F7F7F700000000F7F7F7F70000F7F7F70000F7F7F70000F7F7F7F7F7F7F7F7
        F7F7F7010101010100F7F7010100F7F7010100F7F7010100F7F7F7F7F7F7F7F7
        F7F7F7010100F7010100F70101000000010100F7F7010100F7F7F7F7F7F7F7F7
        F7F7F7010100F7010100F701010101010101F7F7F7010100F7F7F7F7F7F7F7F7
        F7F7F7010100F7010100F7F7010100010100F7F7F7010100F7F7F7F7F7F7F7F7
        F7F7F7010100F7010100F7F70101000101F7F7F7F7010100F7F7F7F7F7F7F7F7
        F7F7F7010100000101F7F7F7F701010100F7F7F7000101000000F7F7F7F7F7F7
        F7F7F70101010101F7F7F7F7F7010101F7F7F7010101010101F7F7F7F7F7F7F7
        F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7
        F7F7}
      Stretch = True
      Transparent = True
    end
    object Label3: TLabel
      Left = 40
      Top = 4
      Width = 205
      Height = 16
      Caption = 'Juliasoft Dat to Dbf converter '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = 19
      Font.Name = 'MS Sans Serif'
      Font.Pitch = fpVariable
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 231
    Width = 430
    Height = 47
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    object Label6: TLabel
      Left = 8
      Top = 8
      Width = 109
      Height = 13
      Caption = 'mailto: juliasoft@mail.ru'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = 11
      Font.Name = 'MS Sans Serif'
      Font.Pitch = fpVariable
      Font.Style = []
      ParentFont = False
    end
    object btnGo: TBitBtn
      Left = 312
      Top = 8
      Width = 107
      Height = 33
      Caption = 'Convert It !'
      Default = True
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = 13
      Font.Name = 'Arial'
      Font.Pitch = fpVariable
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = btnGoClick
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000120B0000120B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333000000000
        333333777777777F33333330B00000003333337F7777777F3333333000000000
        333333777777777F333333330EEEEEE033333337FFFFFF7F3333333300000000
        333333377777777F3333333330BFBFB03333333373333373F33333330BFBFBFB
        03333337F33333F7F33333330FBFBF0F03333337F33337F7F33333330BFBFB0B
        03333337F3F3F7F7333333330F0F0F0033333337F7F7F773333333330B0B0B03
        3333333737F7F7F333333333300F0F03333333337737F7F33333333333300B03
        333333333377F7F33333333333330F03333333333337F7F33333333333330B03
        3333333333373733333333333333303333333333333373333333}
      NumGlyphs = 2
    end
  end
  object cbAppendMode: TCheckBox
    Left = 40
    Top = 96
    Width = 105
    Height = 17
    Caption = 'Append Mode'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 12
    Font.Name = 'Arial'
    Font.Pitch = fpVariable
    Font.Style = []
    ParentFont = False
    TabOrder = 4
  end
  object cbDateSupport: TCheckBox
    Left = 40
    Top = 120
    Width = 105
    Height = 17
    Caption = 'Date Support'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 12
    Font.Name = 'Arial'
    Font.Pitch = fpVariable
    Font.Style = []
    ParentFont = False
    TabOrder = 5
  end
  object cbUndelete: TCheckBox
    Left = 160
    Top = 120
    Width = 105
    Height = 17
    Caption = 'Undelete'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 12
    Font.Name = 'Arial'
    Font.Pitch = fpVariable
    Font.Style = []
    ParentFont = False
    TabOrder = 7
  end
  object cbArraySupport: TCheckBox
    Left = 160
    Top = 96
    Width = 105
    Height = 17
    Caption = 'Array Support'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 12
    Font.Name = 'Arial'
    Font.Pitch = fpVariable
    Font.Style = []
    ParentFont = False
    TabOrder = 6
  end
  object cbRepeatable: TCheckBox
    Left = 280
    Top = 96
    Width = 105
    Height = 17
    Caption = 'Repeatable'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 12
    Font.Name = 'Arial'
    Font.Pitch = fpVariable
    Font.Style = []
    ParentFont = False
    TabOrder = 8
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 144
    Width = 409
    Height = 73
    Caption = 'Date Fields'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 12
    Font.Name = 'Arial'
    Font.Pitch = fpVariable
    Font.Style = []
    ParentFont = False
    TabOrder = 9
    object Label4: TLabel
      Left = 8
      Top = 20
      Width = 71
      Height = 12
      Caption = 'should  contains:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = 12
      Font.Name = 'Arial'
      Font.Pitch = fpVariable
      Font.Style = []
      ParentFont = False
    end
    object Label5: TLabel
      Left = 8
      Top = 44
      Width = 94
      Height = 12
      Caption = 'should be started with:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = 12
      Font.Name = 'Arial'
      Font.Pitch = fpVariable
      Font.Style = []
      ParentFont = False
    end
    object eContains: TEdit
      Left = 112
      Top = 16
      Width = 289
      Height = 20
      Hint = 'strings should be delimited by ";"'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object eStarted: TEdit
      Left = 144
      Top = 40
      Width = 257
      Height = 20
      Hint = 'strings should be delimited by ";"'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
  end
  object OemBox: TComboBox
    Left = 280
    Top = 120
    Width = 113
    Height = 21
    ItemHeight = 13
    TabOrder = 10
    Text = 'None'
    Items.Strings = (
      'None'
      'OemToChar'
      'CharToOem')
  end
  object OpenDialog1: TOpenDialog
    Title = 'Open'
    Left = 224
    Top = 48
  end
end
