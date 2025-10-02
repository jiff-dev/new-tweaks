@echo off
title Jiff3 Tweaker - 5$ Pack
color 0A
setlocal EnableExtensions EnableDelayedExpansion
set LOG=Jiff3Tweaker.log

:menu
cls
echo =========================================================
echo              Jiff3 Tweaker - 5$ Pack
echo =========================================================
echo   1) Create Restore Point
echo   2) Apply Service Tweaks
echo   3) Disable Xbox/GameDVR
echo   4) Apply Extreme Network Tweaks
echo   5) Apply Extreme RAM Tweaks
echo   6) Apply Extreme CPU Tweaks
echo   7) Apply Extreme GPU Tweaks
echo   8) Apply NVIDIA Driver Tweaks
echo   9) Apply Keyboard Tweaks
echo  10) Disable ALL Windows Effects
echo  11) Status Checker
echo  12) Install + Activate ParagonPerfV4
echo  13) Exit
echo.
set /p CH=Choose an option (1-13): 

if "%CH%"=="1"  goto restorepoint
if "%CH%"=="2"  goto tweak_services
if "%CH%"=="3"  goto tweak_xbox
if "%CH%"=="4"  goto tweak_network
if "%CH%"=="5"  goto tweak_ram
if "%CH%"=="6"  goto tweak_cpu
if "%CH%"=="7"  goto tweak_gpu
if "%CH%"=="8"  goto tweak_nvidia
if "%CH%"=="9"  goto tweak_input
if "%CH%"=="10" goto tweak_visuals
if "%CH%"=="11" goto status
if "%CH%"=="12" goto paragonplan
if "%CH%"=="13" exit
goto menu

:: ==============================
:: Restore Point
:: ==============================
:restorepoint
echo Creating Restore Point...
powershell -NoProfile -Command "Try { Checkpoint-Computer -Description 'Jiff3Tweaker Backup' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction Stop } Catch { Write-Output 'Restore point failed' }"
echo Done.
pause
goto menu

:: ==============================
:: Service Tweaks
:: ==============================
:tweak_services
echo Applying Service Tweaks...
set SERVICES=SysMain WSearch DiagTrack RemoteRegistry MapsBroker RetailDemo TabletInputService TrkWks WbioSrvc XboxGipSvc XblAuthManager XblGameSave XboxNetApiSvc
for %%S in (%SERVICES%) do (
  sc config "%%S" start= demand >nul 2>&1
  echo [SERVICE->MANUAL] %%S>>"%LOG%"
)
echo Done. Restart recommended.
pause
goto menu

:: ==============================
:: Xbox/GameDVR
:: ==============================
:tweak_xbox
reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f >nul
echo [XBOX/GAMEDVR] Disabled>>"%LOG%"
echo Done.
pause
goto menu

:: ==============================
:: Extreme Network Tweaks
:: ==============================
:tweak_network
echo Applying Extreme Network Tweaks...

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 0xffffffff /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f >nul

for /f "tokens=3" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /s /v DhcpIPAddress ^| findstr /i "Interfaces"') do (
    reg add "%%A" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f >nul
    reg add "%%A" /v "TCPNoDelay" /t REG_DWORD /d 1 /f >nul
)

netsh int tcp set global autotuninglevel=disabled >nul
netsh int tcp set heuristics disabled >nul
netsh int tcp set global congestionprovider=ctcp >nul
netsh int tcp set global rss=disabled >nul
netsh int tcp set global chimney=disabled >nul
netsh int ip set global taskoffload=disabled >nul

netsh interface ip set dns name="Ethernet" static 1.1.1.1 >nul
netsh interface ip add dns name="Ethernet" 1.0.0.1 index=2 >nul
netsh interface ip set dns name="Wi-Fi" static 1.1.1.1 >nul
netsh interface ip add dns name="Wi-Fi" 1.0.0.1 index=2 >nul

ipconfig /flushdns >nul

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t REG_DWORD /d 0 /f >nul

echo [NETWORK] Extreme tweaks applied>>"%LOG%"
pause
goto menu

:: ==============================
:: Extreme RAM Tweaks
:: ==============================
:tweak_ram
echo Applying Extreme RAM Tweaks...

powershell -NoProfile -Command "Disable-MMAgent -mc" >nul 2>&1
wmic computersystem where name="%computername%" set AutomaticManagedPagefile=False >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PagingFiles" /t REG_MULTI_SZ /d "" /f >nul
sc stop SysMain >nul 2>&1
sc config SysMain start= disabled >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d 0 /f >nul
powercfg -h off >nul

echo [RAM] Extreme tweaks applied>>"%LOG%"
pause
goto menu

:: ==============================
:: Extreme CPU Tweaks
:: ==============================
:tweak_cpu
echo Applying Extreme CPU Tweaks...

powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
powercfg -SETACTIVE e9a42b02-d5df-448d-aa00-03f14749eb61
powercfg -setacvalueindex e9a42b02-d5df-448d-aa00-03f14749eb61 SUB_PROCESSOR PROCTHROTTLEMIN 100
powercfg -setacvalueindex e9a42b02-d5df-448d-aa00-03f14749eb61 SUB_PROCESSOR PROCTHROTTLEMAX 100

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\0cc5b647-c1df-4637-891a-dec35c318583\3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb" /v "Attributes" /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 26 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f >nul
bcdedit /set disabledynamictick yes >nul
bcdedit /set useplatformclock yes >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d 3 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d 3 /f >nul

echo [CPU] Extreme tweaks applied>>"%LOG%"
pause
goto menu

:: ==============================
:: Extreme GPU Tweaks
:: ==============================
:tweak_gpu
echo Applying GPU Tweaks...

reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f >nul
reg add "HKCU\Software\Microsoft\Avalon.Graphics" /v "DisableHWAcceleration" /t REG_DWORD /d 1 /f >nul
del /q /f "%LOCALAPPDATA%\NVIDIA\DXCache\*.*" >nul 2>&1
del /q /f "%LOCALAPPDATA%\NVIDIA\GLCache\*.*" >nul 2>&1
del /q /f "%LOCALAPPDATA%\D3DSCache\*.*" >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrLevel" /t REG_DWORD /d 0 /f >nul

echo [GPU] Extreme tweaks applied>>"%LOG%"
pause
goto menu

:: ==============================
:: NVIDIA Control Panel Extreme Tweaks
:: ==============================
:tweak_nvidia
echo [NVIDIA] Apply global settings manually if some don’t stick:
echo Low Latency Mode = Ultra, Max Perf, G-Sync/Highest Refresh, V-Sync Off, Shader Cache Unlimited, etc.
echo Full list in log.
echo [NVIDIA] Extreme tweaks logged.>>"%LOG%"
pause
goto menu

:: ==============================
:: Keyboard Tweaks ONLY
:: ==============================
:tweak_input
echo Applying Keyboard Tweaks...

reg add "HKCU\Control Panel\Keyboard" /v "KeyboardDelay" /t REG_SZ /d "0" /f >nul
reg add "HKCU\Control Panel\Keyboard" /v "KeyboardSpeed" /t REG_SZ /d "31" /f >nul

reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "506" /f >nul
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_SZ /d "122" /f >nul
reg add "HKCU\Control Panel\Accessibility\ToggleKeys" /v "Flags" /t REG_SZ /d "58" /f >nul

bcdedit /set useplatformtick yes >nul
bcdedit /set tscsyncpolicy Enhanced >nul

echo [INPUT] Keyboard tweaks applied>>"%LOG%"
pause
goto menu

:: ==============================
:: Disable Visual Effects
:: ==============================
:tweak_visuals
echo Disabling ALL Windows Visual Effects...

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f >nul
reg add "HKCU\Control Panel\Desktop" /v "Wallpaper" /t REG_SZ /d "" /f >nul
sc stop Themes >nul 2>&1
sc config Themes start= disabled >nul 2>&1

echo [VISUALS] Windows effects disabled>>"%LOG%"
pause
goto menu

:: ==============================
:: Status Checker
:: ==============================
:status
echo ================= STATUS =================
echo.
reg query "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode"
reg query "HKCU\System\GameConfigStore" /v "GameDVR_Enabled"
powershell -NoProfile -Command "Get-MMAgent | Select-Object -Property MemoryCompression"
powercfg /GETACTIVESCHEME
echo ===========================================
pause
goto menu

:: ==============================
:: ParagonPerfV4 Power Plan Import
:: ==============================
:paragonplan
set POWFILE=%~dp0ParagonPerfV4.pow
if not exist "%POWFILE%" (
  echo Could not find %POWFILE%.
  pause
  goto menu
)
echo Importing ParagonPerfV4 power plan...
powercfg -import "%POWFILE%"
for /f "tokens=3" %%G in ('powercfg /list ^| findstr /i "ParagonPerfV4"') do set NEWGUID=%%G
if "%NEWGUID%"=="" (
  echo Manual check needed with powercfg /list
  pause
  goto menu
)
powercfg -setactive %NEWGUID%
echo [POWER PLAN] ParagonPerfV4 installed and active >> "%LOG%"
echo Done! ParagonPerfV4 is now your active power plan.
pause
goto menu
