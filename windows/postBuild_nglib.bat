REM *********************************************************************************
REM *** Netgen Library (nglib) Windows Post-Build Script
REM *** Author: Philippose Rajan
REM *** Date: 15/02/2009
REM ***
REM *** Used to perform an "Install" of the generated Dynamic Link Library (DLL)  
REM *** and the corresponding LIB file.
REM ***
REM *** Call from Visual C++ using:
REM *** postBuild_nglib.bat $(ProjectName) $(TargetFileName) $(ConfigurationName) $(ProjectDir)
REM *********************************************************************************
if [%1]==[] goto InputParamsFailed
set PROJ_NAME=%~1
set PROJ_EXEC=%~2
set BUILD_TYPE=%~3
set BUILD_ARCH=%~4
set PROJ_DIR=%~5

REM *** Change these Folders if required ***
REM Check if the environment variable NETGENDIR exists, 
REM and use it as the installation folder
set W_WO_OCC=%BUILD_TYPE:~-4,3%
if defined NETGENDIR (
   echo Environment variable NETGENDIR found: %NETGENDIR%
   set INSTALL_FOLDER=%NETGENDIR%\..
) else (
   echo Environment variable NETGENDIR not found.... using default location!!!
   if /i "%W_WO_OCC%" == "OCC" (   
      set INSTALL_FOLDER=%PROJ_DIR%..\..\%PROJ_NAME%-instOCC_%BUILD_ARCH%
   ) else (
      set INSTALL_FOLDER=%PROJ_DIR%..\..\%PROJ_NAME%-instNoOCC_%BUILD_ARCH%
   )   
)
   
set NGLIB_LIBINC=%PROJ_DIR%..\nglib


echo POSTBUILD Script for %PROJ_NAME% ........

REM *** Embed the Windows Manifest into the Executable File ***
REM echo Embedding Manifest into the DLL: %PROJ_EXEC% ....
REM mt.exe -manifest "%PROJ_DIR%%PROJ_NAME%\%BUILD_TYPE%\%PROJ_EXEC%.intermediate.manifest" "-outputresource:%PROJ_DIR%%PROJ_NAME%\%BUILD_TYPE%\%PROJ_EXEC%;#2" 
REM if errorlevel 1 goto ManifestFailed
REM echo Embedding Manifest into the DLL: Completed OK!!

REM *** Copy the DLL and LIB Files into the install folder ***
echo Installing required files into %INSTALL_FOLDER% ....
if /i "%BUILD_ARCH%" == "win32" (
   xcopy "%PROJ_DIR%%PROJ_NAME%\%BUILD_TYPE%\%PROJ_EXEC%" "%INSTALL_FOLDER%\bin\" /i /d /y
   if errorlevel 1 goto DLLInstallFailed
)
if /i "%BUILD_ARCH%" == "x64" (
   xcopy "%PROJ_DIR%%PROJ_NAME%\%BUILD_ARCH%\%BUILD_TYPE%\%PROJ_EXEC%" "%INSTALL_FOLDER%\bin\" /i /d /y
   if errorlevel 1 goto DLLInstallFailed
)   
echo Installing %PROJ_EXEC%: Completed OK!!

if /i "%BUILD_ARCH%" == "win32" (
   xcopy "%PROJ_DIR%%PROJ_NAME%\%BUILD_TYPE%\%PROJ_NAME%.lib" "%INSTALL_FOLDER%\lib\" /i /d /y
   if errorlevel 1 goto LibInstallFailed
)
if /i "%BUILD_ARCH%" == "x64" (
   xcopy "%PROJ_DIR%%PROJ_NAME%\%BUILD_ARCH%\%BUILD_TYPE%\%PROJ_NAME%.lib" "%INSTALL_FOLDER%\lib\" /i /d /y
   if errorlevel 1 goto LibInstallFailed
)   
echo Installing %PROJ_NAME%.lib: Completed OK!!

REM *** Copy the include file nglib.h into the install folder ***
echo Installing %PROJ_NAME%.h into %INSTALL_FOLDER%\include ....
xcopy "%NGLIB_LIBINC%\%PROJ_NAME%.h" "%INSTALL_FOLDER%\include\" /i /d /y
if errorlevel 1 goto LibInstallFailed
echo Installing %PROJ_NAME%.h: Completed OK!!


REM *** Clean up the build directory by deleting the OBJ files ***
REM echo Deleting the %PROJ_NAME% build folder %PROJ_DIR%%PROJ_NAME% ....
REM rmdir %PROJ_DIR%%PROJ_NAME% /s /q

REM *** If there have been no errors so far, we are done ***
goto BuildEventOK

REM *** Error Messages for each stage of the post build process ***
:InputParamsFailed
echo POSTBUILD Script for %PROJ_NAME% FAILED..... Invalid number of input parameters!!!
exit 1
:ManifestFailed
echo POSTBUILD Script for %PROJ_NAME% FAILED..... Manifest not successfully embedded!!!
exit 1
:DLLInstallFailed
echo POSTBUILD Script for %PROJ_NAME% FAILED..... Error copying the %PROJ_NAME% DLL into install folder!!!
exit 1
:LibInstallFailed
echo POSTBUILD Script for %PROJ_NAME% FAILED..... Error copying %PROJ_NAME%.lib or %PROJ_NAME%.h into install folder!!!
exit 1

:BuildEventOK
echo POSTBUILD Script for %PROJ_NAME% completed OK.....!!
