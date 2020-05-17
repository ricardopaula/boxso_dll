library Boxso;

uses
  SysUtils,
  Classes,
  Dialogs,
  IdHTTP,
  DBXJSON,
  IdIOHandler,
  IdIOHandlerSocket,
  IdIOHandlerStack,
  IdSSL,
  IdSSLOpenSSL,
  Character;
{$R *.res}

var
  http: TIdHTTP;
  ssl: TIdSSLIOHandlerSocketOpenSSL;
  sDefaultUrl: String;

function StripNonJson(s: string): pchar;
var
  ch: char;
  inString: boolean;
begin
  Result := '';
  inString := false;
  for ch in s do
  begin
    if ch = '"' then
      inString := not inString;
    if TCharacter.IsWhiteSpace(ch) and not inString then
      continue;
    Result := pchar(Result + ch);
  end;
end;

procedure MakeConnection();
begin
  http := TIdHTTP.Create(nil);
  ssl := TIdSSLIOHandlerSocketOpenSSL.Create(nil);

  http.IOHandler := ssl;
  http.ConnectTimeout := 120000;
  http.ReadTimeout := 120000;
  http.Request.UserAgent := 'Mozilla/3.0';
end;

function ChangeCommaPerPoint(sValue: string): String;
var
  i: integer;
begin
  if sValue <> '' then
  begin
    for i := 0 to Length(sValue) do
    begin
      if sValue[i] = ',' then
        sValue[i] := '.';
    end;
  end;
  Result := sValue;
end;

function MakeOrder(sApiId: String; sApiKey: String; rBRLValue: Real) : pchar; stdcall;
var
  sUrl: String;
  sBody: String;
  sResponse: String;
  JsonStream: TStringStream;
  jsonObj: TJSONObject;
begin
  try
    try
      MakeConnection;
      sUrl := sDefaultUrl + '/orders';
      http.Request.CustomHeaders.Add('Content-Type:application/json');
      http.Request.CustomHeaders.Add('apiid:' + sApiId);
      http.Request.CustomHeaders.Add('apikey:' + sApiKey);

      sBody := '{"brlvalue" : ' + ChangeCommaPerPoint(FloatToStr(rBRLValue)) + '}';

      JsonStream := TStringStream.Create(sBody);
      JsonStream.DataString;

      sResponse := http.Post(sUrl, JsonStream);

      if http.ResponseCode = 200 then
      begin
        jsonObj := TJSONObject(TJSONObject.
          ParseJSONValue(TEncoding.ASCII.GetBytes(StripNonJson(sResponse)), 0));

        sResponse := jsonObj.Get(2).JsonValue.Value + ';' +
          jsonObj.Get(3).JsonValue.Value + ';' +
          jsonObj.Get(4).JsonValue.Value + ';' +
          jsonObj.Get(1).JsonValue.Value;
      end
      else
        sResponse := '';
    except
      on E: exception do
      begin
        ShowMessage('Error - Create order');
        sResponse := '';
      end;
    end;
  finally
    FreeAndNil(http);
    FreeAndNil(JsonStream);
    Result := pchar(sResponse);
  end;
end;

function CheckPayment(sApiId: String; sApiKey: String; sUuid: String): pchar; stdcall;
var
  sUrl: String;
  sResponse: String;
  jsonObj: TJSONObject;
begin
  try
    try
      MakeConnection;

      sUrl := sDefaultUrl + '/orders/' + sUuid+'/status';
      http.Request.CustomHeaders.Add('Content-Type:application/json');
      http.Request.CustomHeaders.Add('apiid:' + sApiId);
      http.Request.CustomHeaders.Add('apikey:' + sApiKey);

      sResponse := http.Get(sUrl);

      jsonObj := TJSONObject(TJSONObject.
        ParseJSONValue(TEncoding.ASCII.GetBytes(StripNonJson(sResponse)), 0));

      sResponse := jsonObj.Get(2).JsonValue.ToString + ';' +
        jsonObj.Get(1).JsonValue.Value;
    except
      on E: exception do
      begin
        ShowMessage('Error - Check payment');
        sResponse := ';';
      end;
    end;
  finally
    FreeAndNil(http);
    Result := pchar(sResponse);
  end;
end;

function CheckCredentials(sApiId: String; sApiKey: String): pchar; stdcall;
var
  sUrl: String;
  sResponse: String;
  jsonObj: TJSONObject;
begin
  try
    try
      MakeConnection;
      sUrl := sDefaultUrl + '/sessions/check-credentials';

      http.Request.CustomHeaders.Add('Content-Type:application/json');
      http.Request.CustomHeaders.Add('apiid:' + sApiId);
      http.Request.CustomHeaders.Add('apikey:' + sApiKey);

//      ShowMessage(surl);
//      ShowMessage(sApiId);
//      ShowMessage(sApiKey);
      sResponse := http.Get(sUrl);

      if http.ResponseCode = 200 then
      begin
        jsonObj := TJSONObject(TJSONObject.ParseJSONValue
            (TEncoding.ASCII.GetBytes(StripNonJson(sResponse)), 0));

        if jsonObj.Get(0).JsonValue.Value = 'CREDENTIALS_OK' then
        begin
          sResponse := jsonObj.Get(0).JsonValue.Value + ';' +
            jsonObj.Get(1).JsonValue.Value;
        end
        else
        begin
          sResponse := 'false;;';
        end;
      end
      else
        sResponse := 'false;;';
    except
      on E: exception do
      begin
        ShowMessage('Error - Check credentials');
        ShowMessage(E.Message);
        sResponse := 'false;;';
      end;
    end;
  finally
    FreeAndNil(http);
    Result := pchar(sResponse);
  end;
end;

function ListPayment(sApiId: String; sApiKey: String): pchar; stdcall;
var
  sUrl: String;
  sResponse: String;
begin
  try
    try
      MakeConnection;

      sUrl := sDefaultUrl + '/orders/latest';
      http.Request.CustomHeaders.Add('Content-Type:application/json');
      http.Request.CustomHeaders.Add('apiid:' + sApiId);
      http.Request.CustomHeaders.Add('apikey:' + sApiKey);

      sResponse := http.Get(sUrl);
    except
      on E: exception do
      begin
        ShowMessage('Error - List payment');
        sResponse := '';
      end;
    end;
  finally
    FreeAndNil(http);
    Result := pchar(sResponse);
  end;
end;

exports MakeOrder, CheckPayment, ListPayment,
  CheckCredentials;

begin
  sDefaultUrl := 'https://boxso.com.br/api';
//  sDefaultUrl := 'http://192.168.0.22:3333/api';
end.

