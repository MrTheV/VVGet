unit VVHttpGet;

interface

uses
  System.Classes,
  Winapi.Windows,
  System.sysUtils,
  WinApi.Winhttp,
  WinhttpStatus,
  VVGetLastErr,
  VVDbg,
  VVOpenSSL,
  HTTPApp,
  IdHTTP,
  IdURI,
  IdSSLOpenSSL,
  IdAllAuthentications;

type
  VVBuff = array of byte;

  VVHTTPResponse= record
    ResponseText: String;
    ResponseCode: UINT;
    ProxyHost: String;
    ProxyPort: String;
    ProxyUserName: String;
  end;


const
  UserAgent='SysStreaming VVGet/1.0';

function VVWinHttpReadData(hRequest: HINTERNET; lpBuffer: Pointer;
    dwNumberofBytesToRead: DWord; var lpdwNumberOfBytesRead: DWord): BOOL;
    stdcall; external 'winhttp.dll' name 'WinHttpReadData';


function VVGet(VVUrl: string; var Buffer: TMemoryStream): VVHTTPResponse;
var
  ExplicitProxyHost: string;
  ExplicitProxyPortStr: string;
  ExplicitProxyUsername: string;
  ExplicitProxyPassword: string;


implementation

function VVGet(VVUrl: string; var Buffer: TMemoryStream): VVHTTPResponse;
var
  VVIEProxyConfig:WINHTTP_CURRENT_USER_IE_PROXY_CONFIG;
  hHttpSession : HINTERNET;
  AutoProxyOptions:   WINHTTP_AUTOPROXY_OPTIONS;
  ProxyInfo: WINHTTP_PROXY_INFO;

  VVHTTP: TIdHTTP;
  VVUri: TIdUri;
  TempBuff: TMemoryStream;
  S:string;

  I: Cardinal;
  WSAError: UINT;
  WSAErrorStr: string;

begin
  try
    VVHTTP := TIdHTTP.Create;

    if ExplicitProxyHost='' then
    begin
      begin
        if WinHttpGetIEProxyConfigForCurrentUser(VVIEProxyConfig) then
        begin
          VVDbgAndLogString('WinHttpGetIEProxyConfigForCurrentUser. Results:');
          if VVIEProxyConfig.fAutoDetect then VVDbgAndLogString(' AutoDetect=true')
          else VVDbgAndLogString(' AutoDetect=false');
          VVDbgAndLogString(' AutoConfigUrl='+String(VVIEProxyConfig.lpszAutoConfigUrl));
          VVDbgAndLogString(' Proxy='+String(VVIEProxyConfig.lpszProxy));
          VVDbgAndLogString(' ProxyBypass='+String(VVIEProxyConfig.lpszProxyBypass));

        end
        else
        begin
        end;

        hHttpSession := WinHttpOpen(UserAgent,
                                    WINHTTP_ACCESS_TYPE_NO_PROXY,
                                    WINHTTP_NO_PROXY_NAME,
                                    WINHTTP_NO_PROXY_BYPASS,
                                    0 );

        ZeroMemory(@AutoProxyOptions, sizeof(AutoProxyOptions) );
        ZeroMemory(@ProxyInfo, sizeof(ProxyInfo) );

        if VVIEProxyConfig.fAutoDetect then
        begin
          AutoProxyOptions.dwFlags := WINHTTP_AUTOPROXY_AUTO_DETECT
          //and WINHTTP_AUTOPROXY_NO_CACHE_CLIENT and WINHTTP_AUTOPROXY_NO_CACHE_SVC
          ;
          // Use DHCP and DNS-based auto-detection.
          AutoProxyOptions.dwAutoDetectFlags := WINHTTP_AUTO_DETECT_TYPE_DHCP + WINHTTP_AUTO_DETECT_TYPE_DNS_A;
        end
        else
        begin
          if VVIEProxyConfig.lpszAutoConfigUrl<>'' then
          begin
            AutoProxyOptions.dwFlags := WINHTTP_AUTOPROXY_CONFIG_URL;
            AutoProxyOptions.lpszAutoConfigUrl:=VVIEProxyConfig.lpszAutoConfigUrl;
          end
          else
          begin
            if VVIEProxyConfig.lpszProxy<>'' then
            begin

            end;
          end;
        end;
      end;

      if (WinHttpGetProxyForUrl(hHttpSession,
                                PWideChar(VVUrl),
                                AutoProxyOptions,
                                ProxyInfo)) then
      begin
        VVDbgAndLogString('WinHttpGetProxyForUrl results:');
        VVDbgAndLogString(' Access Type: '+IntToStr(ProxyInfo.dwAccessType));
        VVDbgAndLogString(' Proxy: '+ProxyInfo.lpszProxy);
        VVDbgAndLogString(' ProxyBypass: '+ProxyInfo.lpszProxyBypass );

        if ProxyInfo.dwAccessType=WINHTTP_ACCESS_TYPE_NAMED_PROXY then
        begin
          try
            try
              if Pos('://',ProxyInfo.lpszProxy)=0 then S:='http://'+ProxyInfo.lpszProxy
              else S:=ProxyInfo.lpszProxy;
              I:=Pos(';',String(S));
              if I<>0 then
              begin
                VVDbgAndLogString(' Multi Proxy Detected: '+S);
                S:=Copy(S,1,I-1);
              end;

              VVURI := TIdURI.Create(S);
              VVDbgAndLogString(' URLEncoded Proxy URI: '+S);
              VVHTTP.ProxyParams.ProxyServer:=VVURI.Host;
              if VVURI.Port<>'' then VVHTTP.ProxyParams.ProxyPort:=StrToInt(VVURI.Port)
              else VVHTTP.ProxyParams.ProxyPort:=INTERNET_DEFAULT_PORT;
              if VVUri.Protocol='https' then
              begin
                if not VVOpenSSL.IsPresent then
                begin
                  LoadOpenSLL;
                end;
                VVHTTP.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(VVHTTP);
              end;

              if VVURI.Username<>'' then VVHTTP.ProxyParams.ProxyUsername:=VVURI.Username;
              if VVURI.Password<>'' then VVHTTP.ProxyParams.ProxyPassword:=VVURI.Password;
            except
              On E: exception do VVDbgAndLogString('Create URI error: '+E.Message);
            end;
          finally
            VVURI.Free;
          end;
        end;
      end;
    end
    else
    begin
      VVHTTP.ProxyParams.ProxyServer:=ExplicitProxyHost;
      try
       if ExplicitProxyPortStr<>'' then VVHTTP.ProxyParams.ProxyPort:=StrToInt(ExplicitProxyPortStr);
      except
        on E: Exception do
        begin
          VVDbgAndLogString('manual proxy port not an integer. Defaulting to default port');
          VVHTTP.ProxyParams.ProxyPort:=0;
        end;
      end;
      if ExplicitProxyUsername<>'' then
      begin
        VVHTTP.ProxyParams.ProxyUsername:=ExplicitProxyUsername;
        if ExplicitProxyPassword<>'' then VVHTTP.ProxyParams.ProxyPassword:=ExplicitProxyPassword;
        VVHTTP.ProxyParams.BasicAuthentication:=true;
      end;
    end;
    try
      TempBuff:=TMemoryStream.Create;
      try
  //      VVHTTP.ProtocolVersion:=pv1_1;
        VVDbgAndLogString(' VVHttpProxy: '+VVHTTP.ProxyParams.ProxyServer);
        VVDbgAndLogString(' VVHttpProxyPort: '+IntToStr(VVHTTP.ProxyParams.ProxyPort));
        VVDbgAndLogString(' VVHttpProxyUser: '+VVHTTP.ProxyParams.ProxyUsername);
        VVDbgAndLogString(' VVHttpProxyPassword: '+VVHTTP.ProxyParams.ProxyPassword);
        VVHTTP.HandleRedirects:=True;

        try
          VVURI := TIdURI.Create(VVUrl);
          if VVUri.Protocol='https' then
          begin
            if not VVOpenSSL.IsPresent then
            begin
              LoadOpenSLL;
            end;
            VVHTTP.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(VVHTTP);
          end;
        finally
          VVUri.Free;
        end;
        VVHTTP.Get(VVUrl,TempBuff);
        Result.ResponseText:=VVHTTP.ResponseText;
        Result.ResponseCode:=VVHTTP.ResponseCode;
        Result.ProxyHost:=VVHTTP.ProxyParams.ProxyServer;
        Result.ProxyPort:=IntToStr(VVHTTP.ProxyParams.ProxyPort);
        Result.ProxyUserName:=VVHTTP.ProxyParams.ProxyUserName;
      except
        on E: exception do
        begin
          VVDbgAndLogString('Error (class: '+E.ClassName+')  in HTTP Get ('+VVUrl+') '+E.Message+' '+E.ToString+ ' !');
          Result.ResponseText:='Error: '+E.ClassName+' '+E.Message;
{$IFDEF DEBUG}
          Result.ResponseText:=Result.ResponseText+#13+#10+
          'Response Code='+IntToStr(Result.ResponseCode)+#13+#10+
          'ProxyHost='+Result.ProxyHost+#13+#10+
          'ProxyPort='+Result.ProxyPort+#13+#10+
          'ProxyUserName='+Result.ProxyUserName;
{$ENDIF}
          WSAError:=6666;
          WSAErrorStr:='';
          if Pos('#',Result.ResponseText)<>0 then
          begin
            for I := Pos('#',Result.ResponseText)+2 to Length(Result.ResponseText) do
              if Result.ResponseText[I] in ['0'..'9'] then WSAErrorStr:=WSAErrorStr+Result.ResponseText[I]
              else break;
            try
              if WSAErrorStr<>'' then WSAError:=StrToInt(WSAErrorStr);
            finally

            end;
          end;

          Result.ResponseCode:=WSAError;
        end;
      end;

      TempBuff.Position:=0;
      if TempBuff.InstanceSize>0 then
      begin
        Buffer.LoadFromStream(TempBuff);
      end;

    finally
      TempBuff.Free;

    end;
  finally
    VVHTTP.free;
    if Assigned(hHttpSession) then WinHttpCloseHandle(hHttpSession);
  end;
end;

initialization

finalization
  if VVOpenSSL.IsPresent then VVOpenSSL.UnloadOpenSLL;

end.
