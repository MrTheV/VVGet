unit GetProgVersion;

interface

function GetProgramVersion(Path : WideString) : string;

implementation

uses sysutils, windows;


function GetProgramVersion(Path : WideString) : string;
var
  nZero,nSize : cardinal;
  lpData      : pointer;
  p           : pointer;
begin
result:='N/A';
nSize:=GetFileVersionInfoSizeW(PWChar(path),nZero);
if nSize>0 then
 begin
  getmem(lpData,nSize);
  if GetFileVersionInfoW(PWChar(path),0,nSize,lpData) then
   if VerQueryValue(lpData,'\',p,nZero) then
    begin
    result:=inttostr(tVSFIXEDFILEINFO(p^).dwFileVersionMS shr 16)+'.'+
            inttostr(tVSFIXEDFILEINFO(p^).dwFileVersionMS and $FFFF)+'.'+
            inttostr(tVSFIXEDFILEINFO(p^).dwFileVersionLS shr 16)+'.'+
            inttostr(tVSFIXEDFILEINFO(p^).dwFileVersionLS and $FFFF);
    end;
  freemem(lpData,nSize);
 end;
end;


end.
