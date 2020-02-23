@ECHO OFF


::
:: Initial check.
:: Verify if the SDK is correctly configurated
::
IF "%OSDK%"=="" GOTO ErCfg


::
:: Set the build paremeters
::
CALL osdk_config.bat


::
:: Launch the compilation of files
::
CALL %OSDK%\bin\make.bat %OSDKFILE%
CD build
COPY final.out ..\final.out
CALL %OSDK%\bin\Bin2Txt.exe -s1 -f3 -h2 -l5200:10 -n8 final.out finaldat.txt data

TYPE asmbase.txt finaldat.txt asmend.txt > %TEXTNAME%.bas

CALL %OSDK%\bin\Bas2Tap.exe -b2t1 %TEXTNAME%.bas %TEXTNAME%.tap

GOTO End


::
:: Outputs an error message
::
:ErCfg
ECHO == ERROR ==
ECHO The Oric SDK was not configured properly
ECHO You should have a OSDK environment variable setted to the location of the SDK
IF "%OSDKBRIEF%"=="" PAUSE
GOTO End


:End
Pause