unit Winhttpstatus;
// implementation of Winhttp.  Written by Glenn9999 at tek-tips.com

interface
  uses windows;
  const
   // constant strings for WinHTTP specific error messages, used with WinHttpSysErrorMessage.
    err_12001 = 'Out of handles.';
    err_12002 = 'Time out.';
    err_12004 = 'Internal error.';
    err_12005 = 'Invalid URL.';
    err_12006 = 'Unrecognized Scheme.';
    err_12007 = 'Name not resolved.';
    err_12009 = 'Invalid option.';
    err_12011 = 'Option not settable.';
    err_12012 = 'Shutdown.';
    err_12015 = 'Login failure.';
    err_12017 = 'Operation cancelled.';
    err_12018 = 'Incorrect handle type.';
    err_12019 = 'Incorrect handle state.';
    err_12029 = 'Can not connect.';
    err_12030 = 'Connection error.';
    err_12032 = 'Resend request.';
    err_12044 = 'Client auth cert needed.';
    err_12100 = 'Can not call before open.';
    err_12101 = 'Can not call before send.';
    err_12102 = 'Can not call after send.';
    err_12103 = 'Can not call after open.';
    err_12150 = 'Header not found.';
    err_12152 = 'Invalid Server Response.';
    err_12154 = 'Invalid query request.';
    err_12155 = 'Header already exists.';
    err_12156 = 'Redirect failed.';
    err_12178 = 'Auto proxy service error.';
    err_12166 = 'Bad auto proxy script.';
    err_12167 = 'Unable to download Script.';
    err_12172 = 'Not initialized.';
    err_12175 = 'Secure Failure.';
    err_12037 = 'Secure Cert Date Invalid.';
    err_12038 = 'Secure Cert CN Invalid.';
    err_12045 = 'Secure Invalid CA.';
    err_12057 = 'Secure Cert Rev Failed.';
    err_12157 = 'Secure Channel Error.';
    err_12169 = 'Secure Invalid Cert.';
    err_12170 = 'Secure Cert Revoked.';
    err_12179 = 'Secure Cert Wrong Usage.';
    err_12180 = 'Auto Detection Failed.';
    err_12181 = 'Header Count Exceeded.';
    err_12182 = 'Header Size Overflow.';
    err_12183 = 'Chunked Encoding Header Size Overflow.';
    err_12184 = 'Response Drain Overflow.';

    WINHTTP_ERROR_BASE = 12000;
    ERROR_WINHTTP_OUT_OF_HANDLES = (WINHTTP_ERROR_BASE + 1);
    ERROR_WINHTTP_TIMEOUT = (WINHTTP_ERROR_BASE + 2);
    ERROR_WINHTTP_INTERNAL_ERROR = (WINHTTP_ERROR_BASE + 4);
    ERROR_WINHTTP_INVALID_URL = (WINHTTP_ERROR_BASE + 5);
    ERROR_WINHTTP_UNRECOGNIZED_SCHEME = (WINHTTP_ERROR_BASE + 6);
    ERROR_WINHTTP_NAME_NOT_RESOLVED = (WINHTTP_ERROR_BASE + 7);
    ERROR_WINHTTP_INVALID_OPTION = (WINHTTP_ERROR_BASE + 9);
    ERROR_WINHTTP_OPTION_NOT_SETTABLE = (WINHTTP_ERROR_BASE + 11);
    ERROR_WINHTTP_SHUTDOWN = (WINHTTP_ERROR_BASE + 12);

    ERROR_WINHTTP_LOGIN_FAILURE = (WINHTTP_ERROR_BASE + 15);
    ERROR_WINHTTP_OPERATION_CANCELLED = (WINHTTP_ERROR_BASE + 17);
    ERROR_WINHTTP_INCORRECT_HANDLE_TYPE = (WINHTTP_ERROR_BASE + 18);
    ERROR_WINHTTP_INCORRECT_HANDLE_STATE = (WINHTTP_ERROR_BASE + 19);
    ERROR_WINHTTP_CANNOT_CONNECT = (WINHTTP_ERROR_BASE + 29);
    ERROR_WINHTTP_CONNECTION_ERROR = (WINHTTP_ERROR_BASE + 30);
    ERROR_WINHTTP_RESEND_REQUEST = (WINHTTP_ERROR_BASE + 32);

    ERROR_WINHTTP_CLIENT_AUTH_CERT_NEEDED = (WINHTTP_ERROR_BASE + 44);

   // WinHttpRequest Component errors
    ERROR_WINHTTP_CANNOT_CALL_BEFORE_OPEN = (WINHTTP_ERROR_BASE + 100);
    ERROR_WINHTTP_CANNOT_CALL_BEFORE_SEND = (WINHTTP_ERROR_BASE + 101);
    ERROR_WINHTTP_CANNOT_CALL_AFTER_SEND = (WINHTTP_ERROR_BASE + 102);
    ERROR_WINHTTP_CANNOT_CALL_AFTER_OPEN = (WINHTTP_ERROR_BASE + 103);

    // HTTP API errors
    ERROR_WINHTTP_HEADER_NOT_FOUND = (WINHTTP_ERROR_BASE + 150);
    ERROR_WINHTTP_INVALID_SERVER_RESPONSE = (WINHTTP_ERROR_BASE + 152);
    ERROR_WINHTTP_INVALID_QUERY_REQUEST = (WINHTTP_ERROR_BASE + 154);
    ERROR_WINHTTP_HEADER_ALREADY_EXISTS = (WINHTTP_ERROR_BASE + 155);
    ERROR_WINHTTP_REDIRECT_FAILED = (WINHTTP_ERROR_BASE + 156);

    // additional WinHttp API error codes
    ERROR_WINHTTP_AUTO_PROXY_SERVICE_ERROR = (WINHTTP_ERROR_BASE + 178);
    ERROR_WINHTTP_BAD_AUTO_PROXY_SCRIPT = (WINHTTP_ERROR_BASE + 166);
    ERROR_WINHTTP_UNABLE_TO_DOWNLOAD_SCRIPT = (WINHTTP_ERROR_BASE + 167);

    ERROR_WINHTTP_NOT_INITIALIZED = (WINHTTP_ERROR_BASE + 172);
    ERROR_WINHTTP_SECURE_FAILURE = (WINHTTP_ERROR_BASE + 175);

    ERROR_WINHTTP_SECURE_CERT_DATE_INVALID = (WINHTTP_ERROR_BASE + 37);
    ERROR_WINHTTP_SECURE_CERT_CN_INVALID = (WINHTTP_ERROR_BASE + 38);
    ERROR_WINHTTP_SECURE_INVALID_CA = (WINHTTP_ERROR_BASE + 45);
    ERROR_WINHTTP_SECURE_CERT_REV_FAILED = (WINHTTP_ERROR_BASE + 57);
    ERROR_WINHTTP_SECURE_CHANNEL_ERROR = (WINHTTP_ERROR_BASE + 157);
    ERROR_WINHTTP_SECURE_INVALID_CERT = (WINHTTP_ERROR_BASE + 169);
    ERROR_WINHTTP_SECURE_CERT_REVOKED = (WINHTTP_ERROR_BASE + 170);
    ERROR_WINHTTP_SECURE_CERT_WRONG_USAGE = (WINHTTP_ERROR_BASE + 179);

    ERROR_WINHTTP_AUTODETECTION_FAILED = (WINHTTP_ERROR_BASE + 180);
    ERROR_WINHTTP_HEADER_COUNT_EXCEEDED = (WINHTTP_ERROR_BASE + 181);
    ERROR_WINHTTP_HEADER_SIZE_OVERFLOW = (WINHTTP_ERROR_BASE + 182);
    ERROR_WINHTTP_CHUNKED_ENCODING_HEADER_SIZE_OVERFLOW = (WINHTTP_ERROR_BASE + 183);
    ERROR_WINHTTP_RESPONSE_DRAIN_OVERFLOW = (WINHTTP_ERROR_BASE + 184);

    WINHTTP_ERROR_LAST = (WINHTTP_ERROR_BASE + 184);


function WinHttpSysErrorMessage(inerror: integer): String;

implementation

uses sysutils;

function WinHttpSysErrorMessage(inerror: integer): String;
{
SysErrorMessage does not return word values for the WinHTTP errors.  This will.
SysErrorMessage is still called because WinHTTP will return *SOME* standard
Windows API errors.
}

  begin
    if (inerror >= WINHTTP_ERROR_BASE) and (inerror <= WINHTTP_ERROR_LAST) then
      case inerror of
        ERROR_WINHTTP_OUT_OF_HANDLES: Result := err_12001;
        ERROR_WINHTTP_TIMEOUT: Result := err_12002;
        ERROR_WINHTTP_INTERNAL_ERROR: Result := err_12004;
        ERROR_WINHTTP_INVALID_URL: Result := err_12005;
        ERROR_WINHTTP_UNRECOGNIZED_SCHEME: Result := err_12006;
        ERROR_WINHTTP_NAME_NOT_RESOLVED: Result := err_12007;
        ERROR_WINHTTP_INVALID_OPTION: Result := err_12009;
        ERROR_WINHTTP_OPTION_NOT_SETTABLE: Result := err_12011;
        ERROR_WINHTTP_SHUTDOWN: Result := err_12012;
        ERROR_WINHTTP_LOGIN_FAILURE: Result := err_12015;
        ERROR_WINHTTP_OPERATION_CANCELLED: Result := err_12017;
        ERROR_WINHTTP_INCORRECT_HANDLE_TYPE: Result := err_12018;
        ERROR_WINHTTP_INCORRECT_HANDLE_STATE: Result := err_12019;
        ERROR_WINHTTP_CANNOT_CONNECT: Result := err_12029;
        ERROR_WINHTTP_CONNECTION_ERROR: Result := err_12030;
        ERROR_WINHTTP_RESEND_REQUEST: Result := err_12032;
        ERROR_WINHTTP_CLIENT_AUTH_CERT_NEEDED: Result := err_12044;
        ERROR_WINHTTP_CANNOT_CALL_BEFORE_OPEN: Result := err_12100;
        ERROR_WINHTTP_CANNOT_CALL_BEFORE_SEND: Result := err_12101;
        ERROR_WINHTTP_CANNOT_CALL_AFTER_SEND: Result := err_12102;
        ERROR_WINHTTP_CANNOT_CALL_AFTER_OPEN: Result := err_12103;
        ERROR_WINHTTP_HEADER_NOT_FOUND: Result := err_12150;
        ERROR_WINHTTP_INVALID_SERVER_RESPONSE: Result := err_12152;
        ERROR_WINHTTP_INVALID_QUERY_REQUEST: Result := err_12154;
        ERROR_WINHTTP_HEADER_ALREADY_EXISTS: Result := err_12155;
        ERROR_WINHTTP_REDIRECT_FAILED: Result := err_12156;
        ERROR_WINHTTP_AUTO_PROXY_SERVICE_ERROR: Result := err_12178;
        ERROR_WINHTTP_BAD_AUTO_PROXY_SCRIPT: Result := err_12166;
        ERROR_WINHTTP_UNABLE_TO_DOWNLOAD_SCRIPT: Result := err_12167;
        ERROR_WINHTTP_NOT_INITIALIZED: Result := err_12172;
        ERROR_WINHTTP_SECURE_FAILURE: Result := err_12175;
        ERROR_WINHTTP_SECURE_CERT_DATE_INVALID: Result := err_12037;
        ERROR_WINHTTP_SECURE_CERT_CN_INVALID: Result := err_12038;
        ERROR_WINHTTP_SECURE_INVALID_CA: Result := err_12045;
        ERROR_WINHTTP_SECURE_CERT_REV_FAILED: Result := err_12057;
        ERROR_WINHTTP_SECURE_CHANNEL_ERROR: Result := err_12157;
        ERROR_WINHTTP_SECURE_INVALID_CERT: Result := err_12169;
        ERROR_WINHTTP_SECURE_CERT_REVOKED: Result := err_12170;
        ERROR_WINHTTP_SECURE_CERT_WRONG_USAGE: Result := err_12179;
        ERROR_WINHTTP_AUTODETECTION_FAILED: Result := err_12180;
        ERROR_WINHTTP_HEADER_COUNT_EXCEEDED: Result := err_12181;
        ERROR_WINHTTP_HEADER_SIZE_OVERFLOW: Result := err_12182;
        ERROR_WINHTTP_CHUNKED_ENCODING_HEADER_SIZE_OVERFLOW: Result := err_12183;
        ERROR_WINHTTP_RESPONSE_DRAIN_OVERFLOW: Result := err_12184;
      else
        Result := 'Unspecified error.';
      end
    else
      Result := SysErrorMessage(inerror);
  end;

  end.
