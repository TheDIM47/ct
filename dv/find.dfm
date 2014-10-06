object FindForm: TFindForm
  Left = 276
  Top = 139
  Width = 267
  Height = 133
  HorzScrollBar.Range = 251
  VertScrollBar.Range = 97
  ActiveControl = FindEdit
  AutoScroll = False
  BorderIcons = []
  Caption = 'Find'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = 11
  Font.Name = 'MS Sans Serif'
  Font.Pitch = fpVariable
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = True
  Position = poDefault
  Scaled = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object FindEdit: TEdit
    Left = 8
    Top = 8
    Width = 161
    Height = 21
    TabOrder = 0
  end
  object FieldCombo: TComboBox
    Left = 8
    Top = 40
    Width = 161
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 1
  end
  object FindButton: TButton
    Left = 176
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Find'
    Default = True
    TabOrder = 2
    OnClick = FindButtonClick
  end
  object CancelButton: TButton
    Left = 176
    Top = 72
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
    OnClick = CancelButtonClick
  end
  object DirGrp: TRadioGroup
    Left = 8
    Top = 64
    Width = 161
    Height = 33
    Caption = 'Direction'
    Columns = 2
    Items.Strings = (
      'Forward'
      'Backward')
    TabOrder = 4
  end
  object FindNextButton: TButton
    Left = 176
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Find Next'
    TabOrder = 5
    OnClick = FindNextButtonClick
  end
end
