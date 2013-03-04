@echo Off
set config=%1
if "%config%" == "" (
   set config=debug
)
%WINDIR%\Microsoft.NET\Framework\v4.0.30319\msbuild src/Build.proj /p:Configuration="%config%"; /flp:LogFile=msbuild.log;Verbosity=Normal /tv:4.0
