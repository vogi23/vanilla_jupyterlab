::::::::::::::::::::::::::::::::::::::::::::
:: Elevate.cmd - Version 4
:: Automatically check & get admin rights
:: see "https://stackoverflow.com/a/12264592/1016343" for description
::::::::::::::::::::::::::::::::::::::::::::
 @echo off
 CLS
 ECHO[
 ECHO =============================
 ECHO Running Admin shell
 ECHO =============================

:init
 setlocal DisableDelayedExpansion
 set cmdInvoke=1
 set winSysFolder=System32
 set "batchPath=%~0"
 for %%k in (%0) do set batchName=%%~nk
 set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
 setlocal EnableDelayedExpansion

:checkPrivileges
  NET FILE 1>NUL 2>NUL
  if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
  if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
  ECHO[
  ECHO =============================
  ECHO Invoking UAC for Privilege Escalation
  ECHO =============================

  ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
  ECHO args = "ELEV " >> "%vbsGetPrivileges%"
  ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
  ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
  ECHO Next >> "%vbsGetPrivileges%"

  if '%cmdInvoke%'=='1' goto InvokeCmd 

  ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
  goto ExecElevation

:InvokeCmd
  ECHO args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
  ECHO UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:ExecElevation
 "%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*
 exit /B

:gotPrivileges
 setlocal & cd /d %~dp0
 if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)



 ::::::::::::::::::::::::::::
 ::START ELEVATED CODE
 ::::::::::::::::::::::::::::
 cd %0%\..\
 ECHO[
 ECHO =============================
 ECHO Starting Docker Container
 ECHO =============================
 ECHO[
 echo Path to current Script:
 echo %cd%
 ECHO[
 
 :: get name of parent directory as image-name
 call set PARENT_DIR=%CD%
 set PARENT_DIR=%PARENT_DIR:\= %
 set PROJECT_DIRECTORY_NAME=
 for %%i in (%PARENT_DIR%) do set PROJECT_DIRECTORY_NAME=%%i
 echo %PROJECT_DIRECTORY_NAME%

 :: Build
 docker build -t %PROJECT_DIRECTORY_NAME% -f config/Dockerfile .
 
 :: Run
 docker run -ti -v %cd%:/usr/local/bin/host_dir -p 8888:8888 --name %PROJECT_DIRECTORY_NAME% %PROJECT_DIRECTORY_NAME%
 pause