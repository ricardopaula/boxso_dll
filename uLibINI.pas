{
Biblioteca utilizada para trabalhar com arquivos de configuracao
Criado em 11-08-2010
}

unit uLibINI;
interface
uses IniFiles, Vcl.Forms, SysUtils, Classes;

// grava informacoes em arquivo ini
procedure storeIniValue(sFile  : String; sSection: String; sVariable: String; vValue: String);  Overload;
procedure storeIniValue(sFile  : String; sSection: String; sVariable: String; vValue: Integer); Overload;
procedure storeIniValue(sFile  : String; sSection: String; sVariable: String; vValue: Real);    Overload;
procedure storeIniValue(sFile  : String; sSection: String; sVariable: String; vValue: Boolean); Overload;

// le informacao em arquivo ini
function restoreIniValue(sFile  : String; sSection: String; sVariable: String; vType : String)  : String;   OverLoad;
function restoreIniValue(sFile  : String; sSection: String; sVariable: String; vType : Integer) : Integer;  Overload;
function restoreIniValue(sFile  : String; sSection: String; sVariable: String; vType : Real)    : Real;     Overload;
function restoreIniValue(sFile  : String; sSection: String; sVariable: String; vType : Boolean) : Boolean;  Overload;

// funcoes especiais
function deleteINISec(sINI : String; sSec: String): Boolean;

implementation

procedure storeIniValue(sFile  : String; sSection: String; sVariable: String; vValue: String);  Overload;
Var
  oIni : TIniFile;
Begin
  oIni := TIniFile.Create(sFile);
  oIni.WriteString(sSection,sVariable,vValue);
  oIni.Free;
end;

procedure storeIniValue(sFile  : String; sSection: String; sVariable: String; vValue: Integer); Overload;
var oIni : TIniFile;
begin
  oIni := TIniFile.Create(sFile);
  oIni.WriteInteger(sSection,sVariable,vValue);
  oIni.Free;
end;

procedure storeIniValue(sFile  : String; sSection: String; sVariable: String; vValue: Real);    Overload;
var oIni : TIniFile;
begin
  oIni := TIniFile.Create(sFile);
  oIni.WriteFloat(sSection,sVariable,vValue);
  oIni.Free;
end;

procedure storeIniValue(sFile  : String; sSection: String; sVariable: String; vValue: Boolean); Overload;
var oIni : TIniFile;
begin
  oIni := TIniFile.Create(sFile);
  oIni.WriteBool(sSection,sVariable,vValue);
  oIni.Free;
end;


function restoreIniValue(sFile  : String; sSection: String; sVariable: String; vType : String)  : String;   OverLoad;
var oIni : TIniFile;
Begin
  oIni    := TIniFile.Create(sFile);
  Result := oIni.ReadString(sSection,sVariable,vType);
  oIni.Free;
end;

function restoreIniValue(sFile  : String; sSection: String; sVariable: String; vType : Integer) : Integer;  OverLoad;
var oIni : TIniFile;
Begin
  oIni    := TIniFile.Create(sFile);
  Result := oIni.ReadInteger(sSection,sVariable,vType);
  oIni.Free;
end;

function restoreIniValue(sFile  : String; sSection: String; sVariable: String; vType : Real)    : Real;     Overload;
var oIni : TIniFile;
Begin
  oIni    := TIniFile.Create(sFile);
  Result := oIni.ReadFloat(sSection,sVariable,vType);
  oIni.Free;
end;

function restoreIniValue(sFile  : String; sSection: String; sVariable: String; vType : Boolean) : Boolean;  Overload;
var oIni : TIniFile;
Begin
  oIni    := TIniFile.Create(sFile);
  Result := oIni.ReadBool(sSection,sVariable,vType);
  oIni.Free;
end;

function deleteINISec(sINI : String; sSec: String): Boolean;
var Ini : TIniFile;
begin
  try
    Ini := TIniFile.Create(sINI);
    Ini.EraseSection(sSec);
    Ini.Free;
    result := True;
  except
    result := False;
  end;
end;

end.
