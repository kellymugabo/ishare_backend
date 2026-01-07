@echo off
REM Flutter run script that filters out file_picker warnings
REM Usage: run_flutter.bat [device]
REM Example: run_flutter.bat chrome

set DEVICE=%1
if "%DEVICE%"=="" set DEVICE=chrome

REM Run flutter and filter warnings using PowerShell
powershell -Command "flutter run -d %DEVICE% 2>&1 | Where-Object { $_ -notmatch 'file_picker.*default plugin' -and $_ -notmatch 'Ask the maintainers of file_picker' -and $_ -notmatch 'default_package: file_picker' -and $_ -notmatch 'pluginClass or dartPluginClass' }"
