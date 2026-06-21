@echo off
setlocal enabledelayedexpansion

:: Archivo para guardar el estado
set STATE_FILE=%TEMP%\lid_mode_state.txt
set REG_PATH=HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power

:: Leer estado actual
if exist "%STATE_FILE%" (
    set /p MODE=<"%STATE_FILE%"
) else (
    set MODE=normal
)

:: Función para cambiar comportamiento
if "%MODE%"=="normal" (
    :: Cambiar a IGNORE
    echo Cambiando a modo IGNORE...
    
    :: Valores: 0=No action, 1=Sleep, 2=Hibernate, 3=Shutdown
    reg add "%REG_PATH%" /v LidAction /t REG_DWORD /d 0 /f >nul
    reg add "%REG_PATH%" /v LidActionAC /t REG_DWORD /d 0 /f >nul
    
    :: Aplicar cambios con powercfg
    powercfg -setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
    powercfg -setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
    powercfg -setactive SCHEME_CURRENT
    
    :: Guardar estado
    echo ignore > "%STATE_FILE%"
    
    :: Notificación
    echo ========================================
    echo   🔓 MODO IGNORE ACTIVADO
    echo   Cerrar la tapa NO suspenderá el PC
    echo ========================================
    
    :: Mostrar notificación estilo Windows
    msg * "🔓 Modo IGNORE: Cerrar tapa NO suspende" 2>nul
    
) else (
    :: Restaurar SUSPEND
    echo Restaurando modo SUSPEND...
    
    reg add "%REG_PATH%" /v LidAction /t REG_DWORD /d 1 /f >nul
    reg add "%REG_PATH%" /v LidActionAC /t REG_DWORD /d 1 /f >nul
    
    powercfg -setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 1
    powercfg -setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 1
    powercfg -setactive SCHEME_CURRENT
    
    echo normal > "%STATE_FILE%"
    
    echo ========================================
    echo   🔒 MODO SUSPEND ACTIVADO
    echo   Cerrar la tapa SUSPENDERÁ el PC
    echo ========================================
    
    msg * "🔒 Modo SUSPEND: Cerrar tapa suspende" 2>nul
)

:: Pequeña pausa para ver el resultado
echo.
echo Presiona cualquier tecla para salir...
pause >nul
exit


