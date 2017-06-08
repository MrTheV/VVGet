PURPOSE ETC.
This program is a Delphi for Windows implementation of a WGet-type tool.
Its major advantage is that it can use AutoProxy features by relying on
WinHTTP AutoProxy subsystem. Then, if AutoProxy is available, either through DNS,
DHCP, JavaScript URL or by other configuration means, VVGet can fetch a file
using said automatic proxy. Manual Proxy is also supported.
AutoProxy is considered enabled if parameters from Windows/InternetExplorer specify
that "Auto Detect Proxy" is set. See WinHttpGetIEProxyConfigForCurrentUser function
and https:msdn.microsoft.com/fr-fr/library/windows/desktop/aa384240(v=vs.85).aspx
Warning : Integrated Proxy Authentication with Windows Credentials has not been fully tested and may
not work as expected.

DEPENDENCIES
VVGet is built using Indy 10. A recent version of Indy10 (after 2016/01/10 (YYYY/MM/DD)) is
required in order to support fetching files over SSL/TLS when Client-side SNI support is required
such as when using shared hosting in which several host names share the same IP address.
See http:www.indyproject.org/Sockets/Blogs/ChangeLog/20160110B.en.aspx
If you get an EIdOSSLUnderlyingCryptoError Exception when fetching a file over
https, your Indy version may be too old.
Get a recent Indy 10 from http:www.indyproject.org/

VVGet embeds OpenSSL DLLs, in order to be self contained. The DLLs are embedded
as binaries in the resources, extracted to a subfolder in %TEMP% and %PATH% is
adjusted so that the extracted OpenSSL DDLs are used by VVGet.
In order to use OpenSSL DLLS suitable with Indy, with no dependencies, check this link:
http:indy.fulgan.com/SSL/