@echo off
setlocal
echo ---------------------------------------------------
echo      RESCATANDO TRABAJO DE LA ULTIMA HORA
echo ---------------------------------------------------
echo.

:: --- 1. OBTENER FECHA Y HORA (METODO INFALIBLE) ---
for /f "usebackq tokens=1-5 delims=-: " %%a in (`powershell -Command "Get-Date -Format 'yyyy-MM-dd_HH-mm' "`) do set FECHA_HORA=%%a

:: --- 2. CONFIGURACIÓN ---
set "FUENTE=%APPDATA%\pgAdmin\pgadmin4.db"
set "TEMPORAL=temp_db_hora.db"
set "SALIDA=Historial_1H_%FECHA_HORA%.csv"

:: --- 3. PROCESO ---
echo [1/3] Copiando base de datos...
copy "%FUENTE%" "%TEMPORAL%" /Y >nul
if %errorlevel% neq 0 ( echo [ERROR] No encuentro pgAdmin. & pause & exit )

echo [2/3] Extrayendo datos...
(
echo .headers on
echo .mode csv
echo SELECT json_extract(CAST(unhex(query_info^) AS TEXT^), '$.query'^) as SQL, json_extract(CAST(unhex(query_info^) AS TEXT^), '$.start_time'^) as Fecha FROM query_history WHERE datetime(json_extract(CAST(unhex(query_info^) AS TEXT^), '$.start_time'^)^) ^> datetime('now', '-1 hour'^) ORDER BY srno DESC;
) > instrucciones.sql

echo [3/3] Guardando en Excel (CSV)...
sqlite3.exe "%TEMPORAL%" < instrucciones.sql > "%SALIDA%"

:: --- 4. LIMPIEZA Y CONFIRMACION ---
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