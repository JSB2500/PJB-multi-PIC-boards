object Main: TMain
  Left = 436
  Top = 310
  Width = 690
  Height = 444
  Caption = 'I2C Monitor'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object RawDataControl: TMemo
    Left = 0
    Top = 296
    Width = 682
    Height = 114
    Align = alBottom
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 682
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object GoButton: TButton
      Left = 6
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Go'
      Default = True
      TabOrder = 0
      OnClick = GoButtonClick
    end
    object ClearButton: TButton
      Left = 88
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Clear'
      TabOrder = 1
      OnClick = ClearButtonClick
    end
    object ParseAgainButton: TButton
      Left = 168
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Parse again'
      TabOrder = 2
      OnClick = ParseAgainButtonClick
    end
  end
  object ProcessedDataControl: TMemo
    Left = 0
    Top = 41
    Width = 682
    Height = 255
    Align = alClient
    TabOrder = 2
  end
end
