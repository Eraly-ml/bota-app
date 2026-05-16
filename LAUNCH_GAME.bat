@echo off
set FLUTTER_BIN=C:\Users\Yeraly\flutter\bin\flutter.bat
set DEVICE_ID=R5GL13ZD2FB

echo =======================================
echo    ZAPUSKAYU IGRU NA SAMSUNG...
echo =======================================

call %FLUTTER_BIN% pub get
call %FLUTTER_BIN% run -d %DEVICE_ID%

pause
