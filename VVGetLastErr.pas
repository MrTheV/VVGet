unit VVGetLastErr;

interface

{$IFDEF LDEBUG}
  {$DEFINE DEBUG}
{$ENDIF}

uses Sysutils, Windows;

function GetLastErrorText: string;
function ErrorToText(ErrorNum: DWORD):string;


implementation


procedure Ansi2Ascii(var s: string);
var s0: Ansistring;
begin
  Setlength(s0,length(s));
  if length(s0)>0 then
    CharToOem(Pchar(s),PAnsiChar(s0));
  s:=String(s0);
end;

function GetLastErrorText:string;
begin
  Result:=ErrorToText(GetLastError);
end;


function ErrorToText(ErrorNum: DWORD):string;
var
  dwSize:DWORD;
  lpszTemp:LPWSTR;
  S: string;
begin
  dwSize:=512;
  lpszTemp:=nil;
  try
    GetMem(lpszTemp,dwSize);
    FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_ARGUMENT_ARRAY,
      nil,ErrorNum,LANG_NEUTRAL,lpszTemp,dwSize,nil);
  finally
    S:=StrPas(lpszTemp);
    Ansi2Ascii(S);
    Result:=S;
    FreeMem(lpszTemp,dwsize);
  end;
end;


end.
 