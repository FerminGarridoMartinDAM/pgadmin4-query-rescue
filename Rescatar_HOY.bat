@echo off
setlocal
echo ---------------------------------------------------
echo      RESCATANDO TRABAJO DE LAS ULTIMAS 24H
echo ---------------------------------------------------
echo.

:: --- 1. OBTENER FECHA (METODO INFALIBLE) ---
for /f "usebackq tokens=1 delims= " %%a in (`powershell -Command "Get-Date -Format 'yyyy-MM-dd' "`) do set FECHA=%%a

:: --- 2. CONFIGURACIÓN ---
set "FUENTE=%APPDATA%\pgAdmin\pgadmin4.db"
set "TEMPORAL=temp_db_hoy.db"
set "SALIDA=Historial_Dia_%FECHA%.csv"

:: --- 3. PROCESO ---
echo [1/3] Copiando base de datos...
copy "%FUENTE%" "%TEMPORAL%" /Y >nul
if %errorlevel% neq 0 ( echo [ERROR] No encuentro pgAdmin. & pause & exit )

echo [2/3] Filtrando ultimas 24 horas...
(
echo .headers on
echo .mode csv
echo SELECT json_extract(CAST(unhex(query_info^) AS TEXT^), '$.query'^) as SQL, json_extract(CAST(unhex(query_info^) AS TEXT^), '$.start_time'^) as Fecha FROM query_history WHERE datetime(json_extract(CAST(unhex(query_info^) AS TEXT^), '$.start_time'^)^) ^> datetime('now', '-24 hours'^) ORDER BY srno DESC;
) > instrucciones.sql

echo [3/3] Guardando archivo...
sqlite3.exe "%TEMPORAL%" < instrucciones.sql > "%SALIDA%"

:: --- 4. FINAL ---
del "%TEMPORAL%"
del instrucciones.sql

echo.
echo ---------------------------------------------------
echo [EXITO] Archivo actualizado:
echo %SALIDA%
echo ---------------------------------------------------
echo.
echo Pulsa una tecla para terminar...
pause >nul