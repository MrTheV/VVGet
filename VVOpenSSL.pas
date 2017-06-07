unit VVOpenSSL;

(*
This Units handles the extracting of OpenSLL files from resources.
The files will be extracted in Temp dir +'\'+SubDir
A modififation to the Path environment variable is done when the extracting has
been achieved so that when looking for the OpenSSL files, they will be found.
Binding will be done in the calling Unit

*)


interface


const
  SSLDLLName = 'SSLEAY32.DLL';
  SSLCLIBName = 'LIBEAY32.DLL';
  SSLDLLResourceName= 'SSLDLL';
  SSLCLIBResourceName= 'SSLCLIB';


procedure LoadOpenSLL;
procedure UnloadOpenSLL;

var
  IsPresent: boolean=False;
  SubDirName: string='VVGetOpenSSL';

implementation

uses
  Windows,
  Dialogs,
  Classes,
  VVDbg,
  SysUtils,
  IdMessage,
  IdSSLOpenSSL,
  IdSSLOpenSSLHeaders;

var
  PathBackup: string;



function VVFileExists(FileName: WideString): boolean;
begin
  Result:=(GetFileAttributesW(PWChar(FileName))<>$FFFFFFFF);
end;

function VVDirExists(DirName: String): boolean;
begin
  Result:=DirectoryExists(DirName);
end;



procedure LoadOpenSLL;
var
  ResStream: TResourceStream;
  EnvPath : String;
  SSLDLLPath: string;
  SSLClibPath: string;
  TempDir: string;
  szBuff: array [0..MAX_PATH] of char;


begin
  GetTempPath(MAX_PATH,szBuff);
  TempDir:=szBuff;
  SSLDLLPath:= TempDir+SubDirName+'\'+SSLDLLName;
  SSLClibPath:= TempDir+SubDirName+'\'+SSLCLibName;
  if not VVFileExists(SSLDLLPath)then
  begin
    ResStream := TResourceStream.Create(HInstance, SSLDLLResourceName, RT_RCDATA);
    try
      ResStream.Position := 0;
      if not VVDirExists(TempDir+SubDirName) then CreateDir(TempDir+SubDirName);
      ResStream.SaveToFile(SSLDLLPath);
    finally
      ResStream.Free;
    end;
  end;

  if not VVFileExists(SSLClibPath) then
  begin
    ResStream := TResourceStream.Create(HInstance, SSLCLIBResourceName, RT_RCDATA);
    try
      ResStream.Position := 0;
      if not VVDirExists(TempDir+SubDirName) then CreateDir(TempDir+SubDirName);
      ResStream.SaveToFile(SSLClibPath);
    finally
      ResStream.Free;
    end;
    Sleep(25);
  end;

  EnvPath:=GetEnvironmentVariable('Path');
  PathBackup:=EnvPath;
  EnvPath:=TempDir+SubDirname+';'+EnvPath;
  SetEnvironmentVariable(PChar('PATH'),PChar(EnvPath));
  VvDbgAndLogString('Path='+GetEnvironmentVariable('Path'));
  IsPresent:=True;
end;


procedure UnloadOpenSLL;
var
  TempDir: string;
  szBuff: array [0..MAX_PATH] of char;

begin
  GetTempPath(MAX_PATH,szBuff);
  TempDir:=szBuff;
  IdSSLOpenSSL.UnLoadOpenSSLLibrary();
  VvDbgAndLogString('About to delete file '+TempDir+SubDirName+'\'+SSLDLLName);
  if FileExists(TempDir+SubDirName+'\'+SSLDLLName) then DeleteFile(TempDir+SubDirName+'\'+SSLDLLName);

  VvDbgAndLogString('About to delete file '+TempDir+SubDirName+'\'+SSLCLIBName);
  if FileExists(TempDir+SubDirName+'\'+SSLCLIBName) then DeleteFile(TempDir+SubDirName+'\'+SSLCLIBName);
  SetEnvironmentVariable(PChar('PATH'),PChar(PathBackup));

  if VVDirExists(TempDir+SubDirName) then RemoveDirectory(PWchar(TempDir+SubDirName));

  IsPresent:=False;
end;

initialization

finalization
  if VVOpenSSL.IsPresent then VVOpenSSL.UnloadOpenSLL;

end.
