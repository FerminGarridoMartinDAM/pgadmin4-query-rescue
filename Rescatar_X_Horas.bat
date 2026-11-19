@echo off
setlocal
echo ---------------------------------------------------
echo      RESCATAR ULTIMAS "X" HORAS (PERSONALIZADO)
echo ---------------------------------------------------
echo.

:: --- 1. OBTENER FECHA Y HORA ACTUAL ---
for /f "usebackq delims=" %%a in (`powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd_HH-mm'"`) do set "AHORA=%%a"

:: --- 2. PREGUNTAR HORAS AL USUARIO ---
set /p "HORAS=Cuantas horas hacia atras quieres rescatar? (ej: 2, 3, 5): "

:: --- 3. CONFIGURACIÓN ---
set "FUENTE=%APPDATA%\pgAdmin\pgadmin4.db"
set "TEMPORAL=temp_db_xhoras.db"
set "SALIDA=Historial_Ultimas_%HORAS%H_%AHORA%.csv"

:: --- 4. PROCESO ---
echo.
echo [1/3] Copiando base de datos...
copy "%FUENTE%" "%TEMPORAL%" /Y >nul
if %errorlevel% neq 0 ( echo [ERROR] No encuentro pgAdmin. & pause & exit )

echo [2/3] Extrayendo datos de las ultimas %HORAS% horas...
(
echo .headers on
echo .mode csv
echo SELECT json_extract(CAST(unhex(query_info^) AS TEXT^), '$.query'^) as SQL, datetime(json_extract(CAST(unhex(query_info^) AS TEXT^), '$.start_time'^), 'localtime'^) as Fecha FROM query_history WHERE datetime(json_extract(CAST(unhex(query_info^) AS TEXT^), '$.start_time'^)^) ^>= datetime('now', '-%HORAS% hours'^) ORDER BY srno DESC;
) > instrucciones.sql

echo [3/3] Guardando en Excel (CSV)...
sqlite3.exe "%TEMPORAL%" < instrucciones.sql > "%SALIDA%"

:: --- 5. LIMPIEZA Y CONFIRMACION ---
del "%TEMPORAL%"
del instrucciones.sql

echo.
echo ---------------------------------------------------
echo [EXITO] Archivo generado correctamente:
echo %SALIDA%
echo ---------------------------------------------------
echo.
echo Pulsa una tecla para terminar...
pause >nul