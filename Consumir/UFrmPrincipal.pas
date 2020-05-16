unit UFrmPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, Menus, CoolTrayIcon, Spin, StrUtils, ComCtrls,
  IdBaseComponent, IdAntiFreezeBase, IdAntiFreeze, DBXJSON, Character, DB,
  DBClient, Grids, DBGrids, Dialogs;

type
  // TShowForm = procedure;
  // TShowFormModal = function :integer;

  TFrmPrincipal = class(TForm)
    sbInicio: TStatusBar;
    gbReceber: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    btnPagar: TButton;
    edtValor: TEdit;
    ticon: TCoolTrayIcon;
    popMenuApp: TPopupMenu;
    Encerrar1: TMenuItem;
    MainMenu1: TMainMenu;
    Recebimentos: TMenuItem;
    listarultimos: TMenuItem;
    tmr: TTimer;
    gbAguardando: TGroupBox;
    gbQRCode: TGroupBox;
    pbQRCode: TPaintBox;
    Label1: TLabel;
    lblCotacao: TLabel;
    gbVerificar: TGroupBox;
    lblVerificando: TLabel;
    btnCancelar: TButton;
    gbRecebimentos: TGroupBox;
    dtsRecebimentos: TDataSource;
    cdsRecebimentos: TClientDataSet;
    cdsRecebimentosDataHora: TStringField;
    cdsRecebimentosvalor: TStringField;
    btnVoltar: TButton;
    GroupBox1: TGroupBox;
    DBGrid1: TDBGrid;
    btnFlutuante: TImage;
    Button1: TButton;
    procedure btnPagarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ticonDblClick(Sender: TObject);
    procedure Encerrar1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure pbQRCodePaint(Sender: TObject);
    procedure tmrTimer(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtValorKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure listarultimosClick(Sender: TObject);
    procedure btnVoltarClick(Sender: TObject);
    procedure btnFlutuanteStartDrag
      (Sender: TObject; var DragObject: TDragObject);
    procedure btnFlutuanteMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnFlutuanteDblClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Button1Click(Sender: TObject);
  private
    bCancelado: Boolean;
    sApiId: String;
    sAPIKey: String;
    iTentativas: Integer;
    uuidRecebimento: String;

    fLeft, fTop: Integer;
    bLeft, bTop: Integer;

    QRCodeBitmap: TBitmap;

    bVisivel: Boolean;

    // ShowForm : TShowForm;
    // ShowFormModal : TShowFormModal;

    procedure esconderForm;
    procedure mostrarForm;
    function formatDate(sDatetime: String): String;
    function strValorNoSeparador(s: String; iQualPosicao: Integer;
      sSeparador: String = ';'): String;
    procedure exibeQRCode(sQRCode: String; sCotacao: String);
    procedure exibir(sQRCode: String);
    function TrocaPtoPVirg(Valor: string): String;
    procedure inicio;
    procedure aguardando;
    function StripNonJson(s: string): string;
    procedure recebendo;
    procedure listando;
    procedure esconderFlutuante;
    procedure mostrarFlutuante;
    procedure MovimentaObject(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Formulario: TForm);
    { Private declarations }
  public
    { Public declarations }
  end;

function MakeOrder(sApiId: String; sSenha: String; rValorBRL: Real): Pchar;
  stdcall; external 'Boxso.dll' name 'MakeOrder';

function CheckPayment(sApiId: String; sSenha: String; uuidRecebimento: String)
  : Pchar; stdcall; external 'Boxso.dll' name 'CheckPayment';

function ListPayment(sApiId: String; sSenha: String): Pchar; stdcall;
external 'Boxso.dll' name 'ListPayment';

function CheckCredentials(sApiId: String; sSenha: String): Pchar; stdcall;
external 'Boxso.dll' name 'CheckCredentials';

var
  FrmPrincipal: TFrmPrincipal;

implementation

uses uLibINI, DelphiZXIngQRCode;
{$R *.dfm}

procedure TFrmPrincipal.btnCancelarClick(Sender: TObject);
begin
  bCancelado := True;
  lblVerificando.Font.Color := clRed;
  lblVerificando.Font.Style := [fsBold];
  lblVerificando.Caption := 'Pagamento cancelado';
  Application.ProcessMessages;
  Sleep(2000);
  inicio;
end;

procedure TFrmPrincipal.btnPagarClick(Sender: TObject);
var
  sSolicitacao: String;
begin
  if (trim(edtValor.Text) <> '') then
  begin
    sSolicitacao := MakeOrder
      (sApiId, sAPIKey, StrToFloat(TrocaPtoPVirg(edtValor.Text)));

    // ShowMessage('Solicitacao');
    // ShowMessage(sSolicitacao);

    if sSolicitacao <> '' then
    begin
      try
        gbReceber.Visible := False;
        gbQRCode.Top := gbReceber.Top;

        uuidRecebimento := strValorNoSeparador(sSolicitacao, 1);
        recebendo;
        exibeQRCode(strValorNoSeparador(sSolicitacao, 2), strValorNoSeparador
            (sSolicitacao, 3));
      except

      end;
    end;
  end;
end;

procedure TFrmPrincipal.btnVoltarClick(Sender: TObject);
begin
  inicio;
end;

procedure TFrmPrincipal.Button1Click(Sender: TObject);
begin
  lblVerificando.Caption := 'Verificando';
  lblVerificando.Font.Color := clBlack;
  lblVerificando.Font.Style := [];
  tmr.Enabled := True;
end;

procedure TFrmPrincipal.edtValorKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
  begin
    if trim(edtValor.Text) <> '' then
      btnPagarClick(btnPagar);
  end;
end;

procedure TFrmPrincipal.Encerrar1Click(Sender: TObject);
begin
  Close;
  Application.Terminate;
end;

procedure TFrmPrincipal.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;

  if bVisivel = True then
    mostrarFlutuante
  else
    esconderForm;
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
var
  sIni: String;
  sRet: String;
begin
  bVisivel := True;

  sIni := ExtractFilePath(Application.ExeName) + 'boxsopay.ini';
  QRCodeBitmap := TBitmap.Create;

  if FileExists(sIni) then
  begin
    sApiId := restoreIniValue(sIni, 'acesso', 'apiid', '');
    sAPIKey := restoreIniValue(sIni, 'acesso', 'apikey', '');

    sRet := CheckCredentials(sApiId, sAPIKey);

    if strValorNoSeparador(sRet, 1) = 'CREDENTIALS_OK' then
    begin
      sbInicio.Panels[0].Text := 'Empresa: ' + strValorNoSeparador(sRet, 2);
    end
    else
    begin
      sbInicio.Panels[0].Text := 'Empresa não encontrada';
      edtValor.Enabled := False;
      btnPagar.Enabled := False;
      listarultimos.Enabled := False;
    end;
  end
  else
  begin
    sbInicio.Panels[0].Text := 'Arquivo de configuração não encontrado';
    edtValor.Enabled := False;
    btnPagar.Enabled := False;
    listarultimos.Enabled := False;
  end;
end;

procedure TFrmPrincipal.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = 27) and (btnFlutuante.Visible = False) then
    Close;
end;

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
  inicio;
end;

procedure TFrmPrincipal.btnFlutuanteDblClick(Sender: TObject);
begin
  ticonDblClick(Sender);
end;

procedure TFrmPrincipal.btnFlutuanteMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MovimentaObject(Sender, Button, Shift, X, Y, FrmPrincipal);
end;

procedure TFrmPrincipal.btnFlutuanteStartDrag
  (Sender: TObject; var DragObject: TDragObject);
const
  sc_DragMove = $F012;
begin
  ReleaseCapture;
  Perform(wm_SysCommand, sc_DragMove, 0);
end;

procedure TFrmPrincipal.ticonDblClick(Sender: TObject);
begin
  if bVisivel = True then
    esconderFlutuante
  else
    mostrarForm;
end;

procedure TFrmPrincipal.tmrTimer(Sender: TObject);
var
  sSolicitacao: String;
begin
  tmr.Enabled := False;

  if bCancelado = True then
  begin
    bCancelado := False;
    exit;
  end;

  Application.ProcessMessages;
  sSolicitacao := CheckPayment(sApiId, sAPIKey, uuidRecebimento);
  Application.ProcessMessages;

  // ShowMessage(sSolicitacao);

  if strValorNoSeparador(sSolicitacao, 1) = 'true' then
  begin
    lblVerificando.Font.Color := clGreen;
    lblVerificando.Font.Style := [fsBold];
    lblVerificando.Caption := 'Pagamento Identificado';
    Application.ProcessMessages;
    Sleep(2000);
    inicio;
  end
  else
  begin
    iTentativas := iTentativas - 1;
    lblVerificando.Caption := 'Verificando Pagamento (' + inttoStr(iTentativas)
      + ')';

    if iTentativas <= 0 then
    begin
      iTentativas := 60;

      lblVerificando.Font.Color := clRed;
      lblVerificando.Font.Style := [fsBold];
      lblVerificando.Caption := 'Pagamento não identificado';
      Application.ProcessMessages;
    end
    else
      tmr.Enabled := True;
  end;
end;

procedure TFrmPrincipal.mostrarForm;
begin
  inicio;
  ticon.ShowMainForm;
  Application.Restore;
end;

procedure TFrmPrincipal.pbQRCodePaint(Sender: TObject);
var
  Scale: Double;
begin

  pbQRCode.Canvas.Brush.Color := clWhite;
  pbQRCode.Canvas.FillRect(Rect(0, 0, pbQRCode.Width, pbQRCode.Height));
  if ((QRCodeBitmap.Width > 0) and (QRCodeBitmap.Height > 0)) then
  begin
    if (pbQRCode.Width < pbQRCode.Height) then
    begin
      Scale := pbQRCode.Width / QRCodeBitmap.Width;
    end
    else
    begin
      Scale := pbQRCode.Height / QRCodeBitmap.Height;
    end;
    pbQRCode.Canvas.StretchDraw
      (Rect(0, 0, Trunc(Scale * QRCodeBitmap.Width), Trunc
          (Scale * QRCodeBitmap.Height)), QRCodeBitmap);
  end;
end;

procedure TFrmPrincipal.esconderForm;
begin
  Application.Minimize;
  ticon.HideMainForm;
end;

function TFrmPrincipal.formatDate(sDatetime : String) : String;
var
  sDate : String;
  sTime : String;
begin

  sDate := Copy(sDatetime,9,2) +'/' + Copy(sDatetime,6,2)+ '/'+Copy(sDatetime,0,4);
  sTime := Copy(sDatetime,12,2) +':' + Copy(sDatetime,15,2)+ ':'+Copy(sDatetime,18,2);

  Result := sDate+' '+sTime;
end;


function TFrmPrincipal.strValorNoSeparador(s: String; iQualPosicao: Integer;
  sSeparador: String = ';'): String;
var
  sTemp: String;
  iI, iContSeparador: Integer;
begin
  iContSeparador := 0;

  iI := 0;

  if s[Length(s)] <> sSeparador then
    s := s + sSeparador; // a linha deve terminar com o separador

  while iI <= Length(s) do
  begin
    if s[iI] = sSeparador then
    begin
      iContSeparador := iContSeparador + 1;

      if iContSeparador = iQualPosicao then
      begin
        sTemp := Copy(s, 1, iI - 1); // -1 para nao copiar o ultimo separador
        Break;
      end;
    end;

    Inc(iI);
  end;

  if iQualPosicao > 1 then
  begin
    sTemp := ReverseString(sTemp);
    sTemp := Copy(sTemp, 1, Pos(sSeparador, sTemp) - 1);
    // -1 para nao copiar o ultimo separador
    Result := ReverseString(sTemp);
  end
  else
  begin
    Result := sTemp;
  end;
end;

procedure TFrmPrincipal.exibeQRCode(sQRCode: String; sCotacao: String);
begin
  lblCotacao.Caption := FormatFloat
    ('##,##0.00', StrToFloat(TrocaPtoPVirg(sCotacao)));
  exibir(sQRCode);
end;

procedure TFrmPrincipal.exibir(sQRCode: String);
var
  QRCode: TDelphiZXingQRCode;
  Row, Column: Integer;
begin
  aguardando;

  QRCode := TDelphiZXingQRCode.Create;
  try
    QRCode.Data := sQRCode;
    QRCode.Encoding := TQRCodeEncoding(0);
    QRCode.QuietZone := 0;
    QRCodeBitmap.SetSize(QRCode.Rows, QRCode.Columns);
    for Row := 0 to QRCode.Rows - 1 do
    begin
      for Column := 0 to QRCode.Columns - 1 do
      begin
        if (QRCode.IsBlack[Row, Column]) then
        begin
          QRCodeBitmap.Canvas.Pixels[Column, Row] := clBlack;
        end
        else
        begin
          QRCodeBitmap.Canvas.Pixels[Column, Row] := clWhite;
        end;
      end;
    end;
  finally
    QRCode.Free;
  end;
  pbQRCode.Repaint;

  iTentativas := 60;
  tmr.Enabled := True;
end;

function TFrmPrincipal.TrocaPtoPVirg(Valor: string): String;
var
  i: Integer;
begin
  if Valor <> '' then
  begin
    for i := 0 to Length(Valor) do
    begin
      if Valor[i] = '.' then
        Valor[i] := ',';

    end;
  end;
  Result := Valor;
end;

procedure TFrmPrincipal.inicio;
begin

  gbAguardando.Visible := False;
  gbReceber.Visible := True;
  gbRecebimentos.Visible := False;

   gbReceber.Top := 8;
   gbReceber.Left := 8;

   gbAguardando.Top  := 8;
   gbAguardando.Left := 8;

   gbRecebimentos.Top  := 8;
   gbRecebimentos.Left := 8;

   FrmPrincipal.Width  := 340;
   FrmPrincipal.Height := 260;

  lblVerificando.Caption := 'Verificando';
  lblVerificando.Font.Color := clBlack;
  lblVerificando.Font.Style := [];

  uuidRecebimento := '';
  iTentativas := 60;
  edtValor.Text := '';

  try
    edtValor.SetFocus;
  except
    //
  end;

end;

procedure TFrmPrincipal.recebendo;
begin
  gbAguardando.Visible := True;
  gbReceber.Visible := False;
  gbRecebimentos.Visible := False;

  FrmPrincipal.Height := 440;
end;

procedure TFrmPrincipal.listando;
begin
  gbAguardando.Visible := False;
  gbReceber.Visible := False;
  gbRecebimentos.Visible := True;

  FrmPrincipal.Height := 440;
end;

procedure TFrmPrincipal.listarultimosClick(Sender: TObject);
var
  sRetorno, AJsonText: String;
  jsonObj, vJson: TJSONObject;
  vConteudo: TJSONObject;
  vPagamentos: TJSONArray;
  vpagamento: TJSONObject;
  i: Integer;

  a: STring;
  b: TBytes;
begin
  sRetorno := ListPayment(sApiId, sAPIKey);

  if sRetorno <> '' then
  begin
    AJsonText := '{"pagamentos": '+StripNonJson(sRetorno)+'}';

    vJson := TJsonObject(TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(StripNonJson(AJsonText)),0));

    vPagamentos := TJSONArray(vJson.Get(0).JsonValue);

    cdsRecebimentos.EmptyDataSet;

    for i := 0 to vPagamentos.Size - 1 do
    begin
      vpagamento := TJSONObject(vPagamentos.Get(i));

      cdsRecebimentos.Append;
      cdsRecebimentosDataHora.AsString := formatDate(vpagamento.Get(9).JsonValue.Value);
      cdsRecebimentosvalor.AsString := 'R$ ' + vpagamento.Get(2)
        .JsonValue.Value;
      cdsRecebimentos.Post;
    end;
    listando;
  end;
end;

procedure TFrmPrincipal.aguardando;
begin
  gbAguardando.Visible := True;
  gbReceber.Visible := False;

  gbAguardando.Top := 8;
  FrmPrincipal.Height := 440;
end;

function TFrmPrincipal.StripNonJson(s: string): string;
var
  ch: char;
  inString: Boolean;
begin
  Result := '';
  inString := False;
  for ch in s do
  begin
    if ch = '"' then
      inString := not inString;
    if TCharacter.IsWhiteSpace(ch) and not inString then
      continue;
    Result := Result + ch;
  end;
end;

procedure TFrmPrincipal.mostrarFlutuante;
begin
  fTop := FrmPrincipal.Top;
  fLeft := FrmPrincipal.Left;

  if (bTop = 0) or (bLeft = 0) then
  begin
    bTop := fTop;
    bLeft := fLeft;
  end;

  FrmPrincipal.Top := bTop;
  FrmPrincipal.Left := bLeft;

  FrmPrincipal.BorderStyle := bsNone;
  FrmPrincipal.Height := 32;
  FrmPrincipal.Width := 32;

  gbReceber.Visible := False;
  gbAguardando.Visible := False;
  gbRecebimentos.Visible := False;
  FrmPrincipal.Menu := nil;
  sbInicio.Visible := False;

  btnFlutuante.Top := 0;
  btnFlutuante.Left := 0;
  btnFlutuante.Visible := True;

  SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NoMove or SWP_NoSize);
  FrmPrincipal.AlphaBlend := True;
end;

procedure TFrmPrincipal.esconderFlutuante;
begin
  bTop := FrmPrincipal.Top;
  bLeft := FrmPrincipal.Left;

  FrmPrincipal.Top := fTop;
  FrmPrincipal.Left := fLeft;

  FrmPrincipal.BorderStyle := bsToolWindow;
  FrmPrincipal.Menu := MainMenu1;
  sbInicio.Visible := True;
  btnFlutuante.Visible := False;
  inicio;

  SetWindowPos(Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NoMove or SWP_NoSize);
  FrmPrincipal.AlphaBlend := False;
end;

procedure TFrmPrincipal.MovimentaObject(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer; Formulario: TForm);
var
  ObjectPos, MousePosMov: TPoint;
  Pt: TPoint;
  fHandle: HWND;
begin
  GetCursorPos(Pt);
  ObjectPos.X := Formulario.Left;
  ObjectPos.Y := Formulario.Top;
  if (Sender is TForm) then
    fHandle := TWinControl(Sender).Handle
  else
    fHandle := TWinControl(Sender).Parent.Handle;
  while DragDetect(fHandle, ObjectPos) do
  begin
    GetCursorPos(MousePosMov);
    Formulario.Left := MousePosMov.X - X - 3;
    Formulario.Top := MousePosMov.Y - Y - 3;
    Application.ProcessMessages;
  end;
end;

end.
