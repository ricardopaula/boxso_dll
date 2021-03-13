object FrmPrincipal: TFrmPrincipal
  Left = 0
  Top = 0
  AlphaBlendValue = 100
  BorderStyle = bsToolWindow
  Caption = 'Boxso'
  ClientHeight = 607
  ClientWidth = 1023
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -24
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 29
  object sbInicio: TStatusBar
    Left = 0
    Top = 588
    Width = 1023
    Height = 19
    Panels = <
      item
        Alignment = taCenter
        Bevel = pbNone
        BiDiMode = bdLeftToRight
        ParentBiDiMode = False
        Width = 50
      end>
  end
  object gbReceber: TGroupBox
    Left = 8
    Top = 8
    Width = 320
    Height = 177
    TabOrder = 1
    object Label4: TLabel
      Left = 52
      Top = 10
      Width = 212
      Height = 29
      Caption = 'Receber o valor R$:'
    end
    object Label5: TLabel
      Left = 68
      Top = 278
      Width = 46
      Height = 29
      Caption = 'Log:'
    end
    object btnPagar: TButton
      Left = 52
      Top = 117
      Width = 212
      Height = 45
      Caption = 'Receber'
      TabOrder = 0
      OnClick = btnPagarClick
    end
    object edtValor: TEdit
      Left = 52
      Top = 53
      Width = 212
      Height = 56
      Alignment = taCenter
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -40
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnKeyDown = edtValorKeyDown
    end
  end
  object gbAguardando: TGroupBox
    Left = 348
    Top = 8
    Width = 320
    Height = 359
    TabOrder = 2
    object gbQRCode: TGroupBox
      Left = 0
      Top = 0
      Width = 320
      Height = 268
      TabOrder = 0
      object pbQRCode: TPaintBox
        Left = 48
        Top = 11
        Width = 230
        Height = 230
        OnPaint = pbQRCodePaint
      end
      object Label1: TLabel
        Left = 46
        Top = 246
        Width = 114
        Height = 16
        Caption = 'Cotata'#231#227'o Utilizada:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lblCotacao: TLabel
        Left = 166
        Top = 246
        Width = 4
        Height = 16
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
    end
    object gbVerificar: TGroupBox
      Left = 0
      Top = 271
      Width = 320
      Height = 88
      TabOrder = 1
      object lblVerificando: TLabel
        Left = 8
        Top = 8
        Width = 305
        Height = 33
        Alignment = taCenter
        AutoSize = False
        Caption = 'Verificando'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object btnCancelar: TButton
        Left = 112
        Top = 47
        Width = 98
        Height = 29
        Caption = 'Cancelar'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnClick = btnCancelarClick
      end
      object Button1: TButton
        Left = 216
        Top = 47
        Width = 41
        Height = 29
        Caption = '<>'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        OnClick = Button1Click
      end
    end
  end
  object gbRecebimentos: TGroupBox
    Left = 695
    Top = 8
    Width = 320
    Height = 362
    Ctl3D = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 3
    object btnVoltar: TButton
      Left = 11
      Top = 294
      Width = 299
      Height = 56
      Caption = 'Voltar'
      TabOrder = 0
      OnClick = btnVoltarClick
    end
    object GroupBox1: TGroupBox
      Left = 0
      Top = 3
      Width = 320
      Height = 273
      Enabled = False
      TabOrder = 1
      object DBGrid1: TDBGrid
        Left = 2
        Top = 3
        Width = 315
        Height = 265
        DataSource = dtsRecebimentos
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -16
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        Columns = <
          item
            Expanded = False
            FieldName = 'DataHora'
            Title.Caption = 'Data Hora'
            Width = 170
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'valor'
            Width = 110
            Visible = True
          end>
      end
    end
  end
  object popMenuApp: TPopupMenu
    Left = 164
    Top = 202
    object Encerrar1: TMenuItem
      Caption = 'Encerrar'
      OnClick = Encerrar1Click
    end
  end
  object MainMenu1: TMainMenu
    Left = 96
    Top = 200
    object Recebimentos: TMenuItem
      Caption = 'Recebimentos'
      object listarultimos: TMenuItem
        Caption = 'Listar ultimos'
        OnClick = listarultimosClick
      end
    end
  end
  object tmr: TTimer
    Enabled = False
    OnTimer = tmrTimer
    Left = 32
    Top = 200
  end
  object dtsRecebimentos: TDataSource
    DataSet = cdsRecebimentos
    Left = 453
    Top = 64
  end
  object cdsRecebimentos: TClientDataSet
    PersistDataPacket.Data = {
      510000009619E0BD010000001800000002000000000003000000510008446174
      61486F726101004900000001000557494454480200020019000576616C6F7201
      004900000001000557494454480200020014000000}
    Active = True
    Aggregates = <>
    Params = <>
    Left = 421
    Top = 168
    object cdsRecebimentosDataHora: TStringField
      DisplayWidth = 20
      FieldName = 'DataHora'
      Size = 25
    end
    object cdsRecebimentosvalor: TStringField
      DisplayWidth = 23
      FieldName = 'valor'
    end
  end
end
