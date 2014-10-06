object FindForm: TFindForm
  Left = 303
  Top = 160
  BorderStyle = bsSingle
  Caption = 'FindForm'
  ClientHeight = 72
  ClientWidth = 257
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poMainFormCenter
  PrintScale = poNone
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object FindEdit: TEdit
    Left = 8
    Top = 8
    Width = 241
    Height = 21
    TabOrder = 0
    OnChange = FindEditChange
  end
  object FieldsCombo: TComboBox
    Left = 8
    Top = 40
    Width = 105
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 1
  end
  object FindButton: TButton
    Left = 120
    Top = 40
    Width = 65
    Height = 25
    Caption = 'Find'
    Enabled = False
    TabOrder = 2
    OnClick = FindButtonClick
  end
  object CloseButton: TButton
    Left = 184
    Top = 40
    Width = 65
    Height = 25
    Caption = 'Close'
    TabOrder = 3
    OnClick = CloseButtonClick
  end
end
