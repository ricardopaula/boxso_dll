program BoxsoPagamento;

uses
  Forms,
  Windows,
  UFrmPrincipal in 'UFrmPrincipal.pas' {FrmPrincipal},
  uLibINI in '..\uLibINI.pas',
  DelphiZXIngQRCode in 'DelphiZXIngQRCode.pas';

{$R *.res}
var
  oPrograma: THandle;
  aWideChars: array [0 .. 49] of WideChar;
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Boxso';

  StringToWideChar(Application.Title, aWideChars, 50);

  oPrograma := FindWindow(nil, aWideChars);

  if oPrograma > 0 then
  begin
    SetForegroundWindow(oPrograma);

    Application.Terminate;
  end;

  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.
