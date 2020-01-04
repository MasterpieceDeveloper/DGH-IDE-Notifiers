object frmDockableIDENotifications: TfrmDockableIDENotifications
  Left = 0
  Top = 0
  Caption = 'IDE Notifications'
  ClientHeight = 337
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  PixelsPerInch = 96
  TextHeight = 16
  object stbStatusBar: TStatusBar
    Left = 0
    Top = 318
    Width = 635
    Height = 19
    Panels = <
      item
        Width = 250
      end
      item
        Width = 50
      end>
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 635
    Height = 26
    Align = alTop
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 1
    object tbrMessageFilter: TToolBar
      Left = 0
      Top = 0
      Width = 475
      Height = 26
      Align = alClient
      AutoSize = True
      BorderWidth = 1
      Caption = 'tbrMessageFilter'
      DoubleBuffered = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      Images = ilButtons
      List = True
      ParentDoubleBuffered = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      object tbtnCapture: TToolButton
        Left = 0
        Top = 0
        Action = actCapture
      end
      object tbtnClear: TToolButton
        Left = 23
        Top = 0
        Action = actClear
      end
      object tbtnSep1: TToolButton
        Left = 46
        Top = 0
        Width = 8
        Caption = 'tbtnSep1'
        ImageIndex = 1
        Style = tbsSeparator
      end
    end
    object pnlRetention: TPanel
      Left = 475
      Top = 0
      Width = 160
      Height = 26
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      object lblLogRetention: TLabel
        Left = 6
        Top = 5
        Width = 78
        Height = 16
        Caption = 'Log Retention'
      end
      object edtLogRetention: TEdit
        Left = 91
        Top = 2
        Width = 46
        Height = 24
        ReadOnly = True
        TabOrder = 0
        Text = '0'
      end
      object udLogRetention: TUpDown
        Left = 137
        Top = 2
        Width = 16
        Height = 24
        Associate = edtLogRetention
        TabOrder = 1
      end
    end
  end
  object LogView: TVirtualStringTree
    Left = 0
    Top = 26
    Width = 635
    Height = 292
    Align = alClient
    Header.AutoSizeIndex = 0
    Header.Options = [hoColumnResize, hoDblClickResize, hoDrag, hoRestrictDrag, hoShowSortGlyphs, hoVisible]
    Header.Style = hsFlatButtons
    Images = ilButtons
    LineStyle = lsSolid
    ParentShowHint = False
    ShowHint = False
    TabOrder = 2
    TreeOptions.MiscOptions = [toFullRepaintOnResize, toInitOnSave, toReportMode, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowVertGridLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect]
    OnAfterCellPaint = LogViewAfterCellPaint
    OnGetText = LogViewGetText
    OnGetImageIndex = LogViewGetImageIndex
    OnKeyPress = LogViewKeyPress
    Columns = <
      item
        Margin = 5
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coFixed, coAllowFocus, coStyleColor]
        Position = 0
        Spacing = 5
        Width = 185
        WideText = 'Date & Time'
      end
      item
        Margin = 5
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coStyleColor]
        Position = 1
        Spacing = 5
        Width = 640
        WideText = 'Message'
      end>
  end
  object ilButtons: TImageList
    Left = 32
    Top = 72
    Bitmap = {
      494C010102000800040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000080000000FF000000FF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000080000000FF000000FF000000FF00000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000080000000FF000000FF000000FF000000FF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000080000000FF000000FF000000FF000000FF000000FF0000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000800000008000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000080000000FF000000FF000000FF000000FF000000FF000000FF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000FF000000FF00000080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000800000FFFF000000FF000000FF000000FF000000FF000000FF000000FF
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000FF000000FF000000FF000000
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000800000FFFF000000FF000000FF000000FF000000FF000000FF000000FF
      0000008000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000FF000000FF000000FF000000
      0000008080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000800000FFFF000000FF000000FF000000FF000000FF000000FF00000080
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000000000FF
      FF00000000000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000800000FFFF000000FF000000FF000000FF000000FF0000008000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000FFFF000000
      000000FFFF000000000000808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000800000FFFF000000FF000000FF0000FFFF000000800000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF000000000000FFFF0000808000008080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000800000FFFF000000FF0000FFFF00000080000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FFFF0000FFFF0000FFFF00008080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000800000FFFF0000FFFF0000008000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF0000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000800000FFFF000000800000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFF0000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000080000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFF847F00000000F9FF00EF00000000
      F0FF31BF00000000F07F39FF00000000F03F993F00000000F01FCA1F00000000
      F00FF40F00000000F0079C0700000000F007960300000000F00FCB0100000000
      F01FFF8000000000F03FF7C000000000F07FFFE000000000F0FFEFF000000000
      F1FFFFF800000000FBFFFFFC0000000000000000000000000000000000000000
      000000000000}
  end
  object alButtons: TActionList
    Images = ilButtons
    Left = 32
    Top = 128
    object actCapture: TAction
      Caption = 'Catpure Notifications'
      ImageIndex = 0
      OnExecute = actCaptureExecute
      OnUpdate = actCaptureUpdate
    end
    object actClear: TAction
      Caption = 'actClear'
      ImageIndex = 1
      OnExecute = actClearExecute
    end
  end
end