unit VVDbg;

//Various functions to log and debug.

{$UNDEF LogToTS}

interface



uses
  sysutils,
{$IFDEF LogToTS}
  classes,
{$ENDIF}
  windows;

procedure VVDbgWriteln(S:String);
procedure VVDbgOut(S:String);
procedure WriteLogToEventLogger(const Msg: string; const SvcName: string);
procedure VVriteLogToEventLogger(const Msg: string; const SvcName: string);
procedure AddToLog(S: string);
procedure VVDbgAndLogString(S: string);


implementation

uses
  VCL.SvcMgr;

{$IFDEF DEBUG}
 {$IFDEF LogToTS}
var
  TS: TStringList;
  szBuff: array[0..MAX_PATH] of char;

 {$ENDIF}
{$ENDIF}

// This functions writes an event of type "Information" to Windows Event Log
procedure VVriteLogToEventLogger(const Msg: string; const SvcName: string);
var
  FEventLogger: TEventLogger;
begin
  FEventLogger := TEventLogger.Create(SvcName);
  try
    FEventLogger.LogMessage(Msg, EVENTLOG_INFORMATION_TYPE, 0, 0);
  finally
    FreeAndNil(FEventLogger);
  end;
end;

// This functions writes an event of type "Error" to Windows Event Log
procedure WriteLogToEventLogger(const Msg: string; const SvcName: string);
{$IFDEF DEBUG}
var
  FEventLogger: TEventLogger;
{$ENDIF}
begin
{$IFDEF DEBUG}
  FEventLogger := TEventLogger.Create(SvcName);
  try
    FEventLogger.LogMessage(Msg, EVENTLOG_ERROR_TYPE, 0, 0);
  finally
    FreeAndNil(FEventLogger);
  end;
{$ENDIF}
end;


//This function logs a string into a file located in %TEMP% folder which name is the exe file name + ".log"
//If LogToTS is defined, the string is added to a TStringList object TS which is saved to the log file when the program exits
//If LogToTS is NOT defined, the string is added directly to the log file.
procedure AddToLog(S: string);
{$IFDEF DEBUG}
 {$IFNDEF LogToTS}
var
  LogFile:TextFile;
  szBuff: array[0..MAX_PATH] of char;
  LogFileName: string;
 {$ENDIF}
{$ENDIF}
begin
{$IFDEF DEBUG}
 {$IFDEF LogToTS}
 TS.Add(S);
 {$ELSE}

try
  GetTempPath(MAX_PATH,szBuff);
  LogFileName:=string(szBuff)+'\'+ExtractFileName(ParamStr(0))+'.log';
  AssignFile(LogFile,LogFileName);
  try
    if FileExists(LogFileName) then Append(LogFile)
    else rewrite(LogFile);
    writeln(LogFile, S);

  finally
    closefile(Logfile);
  end;
except
  on e:Exception do VVDbgOut('!! Exception in AddToLog: '+E.Classname+': '+E.Message);
end;
 {$ENDIF}
{$ENDIF}
end;

// This functions logs a string to the DebugOutput. Can be seen with SysSinternals "DbgView" for instance
Procedure VVDbgOut(S: string);
begin
{$IFDEF DEBUG}
  OutputDebugString(PChar(ExtractFileName(ParamStr(0))+': '+S));
{$ENDIF}
end;

procedure VVDbgAndLogString(S: string);
begin
  VVDbgOut(S);
  AddToLog(S);
end;

//Write to stdout only if teh target is DEBUG
procedure VVDbgWriteln(S:String);
begin
  {$IFDEF DEBUG}
  writeln(S);
  {$ENDIF}
end;


{$IFDEF DEBUG}
 {$IFDEF LogToTS}

initialization
 TS:=TStringList.CREATE;
 TS.Sorted:=false;
 TS.Clear;


finalization
 GetTempPath(MAX_PATH,szBuff);
 TS.Add('(Log created with LogToTS defined');
 TS.SaveToFile(string(szBuff)+'\'+ExtractFileName(ParamStr(0))+'.log');
 TS.Free;
 {$ENDIF}
{$ENDIF}


end.
