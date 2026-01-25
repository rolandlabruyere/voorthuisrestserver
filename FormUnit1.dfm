object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 235
  ClientWidth = 399
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 48
    Width = 20
    Height = 13
    Caption = 'Port'
  end
  object ButtonStart: TButton
    Left = 24
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 0
    OnClick = ButtonStartClick
  end
  object ButtonStop: TButton
    Left = 105
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Stop'
    TabOrder = 1
    OnClick = ButtonStopClick
  end
  object EditPort: TEdit
    Left = 24
    Top = 67
    Width = 121
    Height = 21
    TabOrder = 2
    Text = '8080'
  end
  object ButtonOpenBrowser: TButton
    Left = 24
    Top = 112
    Width = 107
    Height = 25
    Caption = 'Open Browser'
    TabOrder = 3
    OnClick = ButtonOpenBrowserClick
  end
  object ApplicationEvents1: TApplicationEvents
    OnIdle = ApplicationEvents1Idle
    Left = 288
    Top = 24
  end
  object adoVoorThuisCustomerSales: TADOConnection
    ConnectionString = 
      'Driver=MySQL ODBC 8.0 Unicode Driver;Server=Localhost;Port=3306;' +
      'Database=VoorThuisHtmlPages;Uid=VoorThuis;'
    LoginPrompt = False
    Left = 240
    Top = 160
  end
  object adoConnHtmlPages: TADOConnection
    ConnectionString = 
      'Driver=MySQL ODBC 8.0 Unicode Driver;Server=Localhost;Port=3306;' +
      'Database=VoorThuisHtmlPages;Uid=VoorThuis;'
    LoginPrompt = False
    Left = 96
    Top = 160
  end
  object Timer30min: TTimer
    OnTimer = Timer30minTimer
    Left = 328
    Top = 128
  end
  object Timer30days: TTimer
    OnTimer = Timer30daysTimer
    Left = 328
    Top = 96
  end
end
