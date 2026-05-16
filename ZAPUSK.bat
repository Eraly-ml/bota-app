@echo off
set FLUTTER_PATH=C:\Users\Yeraly\flutter\bin\flutter.bat
echo [1/2] Podgotovka...
call %FLUTTER_PATH% pub get
echo [2/2] Zapusk na Samsung (R5GL13ZD2FB)...
call %FLUTTER_PATH% run -d R5GL13ZD2FB
pause
