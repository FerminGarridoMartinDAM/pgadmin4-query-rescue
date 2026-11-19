@echo off
setlocal
echo ---------------------------------------------------
echo      RESCATAR POR RANGO DE HORAS (DESDE - HASTA)
echo ---------------------------------------------------
echo.

:: --- 1. OBTENER FECHA DE HOY ---
for /f "usebackq delims=" %%a in (`powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd'"`) do set "HOY=%%a"

:: --- 2. PREGUNTAR FECHA Y RANGO AL USUARIO ---
set "FECHA_BUSQUEDA=%HOY%"
set /p "FECHA_INPUT=1. Pulsa Enter para HOY (%HOY%) o escribe otra fecha (AAAA-MM-DD): "
if not "%FECHA_INPUT%"=="" set "FECHA_BUSQUEDA=%FECHA_INPUT%"

echo.
set /p "HORA_DESDE=2. Hora DESDE (formato 24h, ej: 16:00): "
set /p "HORA_HASTA=3. Hora HASTA (formato 24h, ej: 19:30): "

:: Añadir cero inicial si el usuario escribe 9:00 en lugar de 09:00
if "%HORA_DESDE:~1,1%"==":" set "HORA_DESDE=0%HORA_DESDE%"
if "%HORA_HASTA:~1,1%"==":" set "HORA_HASTA=0%HORA_HASTA%"

:: Cambiar los dos puntos (:) por guion (-) para el nombre del archivo
set "DESDE_LIMPIO=%HORA_DESDE::=-%"
set "HASTA_LIMPIO=%HORA_HASTA::=-%"

:: --- 3. CONFIGURACIÓN ---
set "FUENTE=%APPDATA%\pgAdmin\pgadmin4.db"
set "TEMPORAL=temp_db_rango.db"
set "SALIDA=Historial_Rango_%FECHA_BUSQUEDA%_de_%DESDE_LIMPIO%_a_%HASTA_LIMPIO%.csv"

:: --- 4. PROCESO ---
echo.
echo [1/3] Copiando base de datos...
copy "%FUENTE%" "%TEMPORAL%" /Y >nul
if %errorlevel% neq 0 ( echo [ERROR] No encuentro pgAdmin. & pause & exit )

echo [2/3] Extrayendo consultas del dia %FECHA_BUSQUEDA% (%HORA_DESDE% a %HORA_HASTA%)...
(
echo .headers on
echo .mode csv
echo SELECT json_extract(CAST(unhex(query_info^) AS TEXT^), '$.query'^) as SQL, datetime(json_extract(CAST(unhex(query_info^) AS TEXT^), '$.start_time'^), 'localtime'^) as Fecha FROM query_history WHERE datetime(json_extract(CAST(unhex(query_info^) AS TEXT^), '$.start_time'^), 'localtime'^) BETWEEN '%FECHA_BUSQUEDA% %HORA_DESDE%:00' AND '%FECHA_BUSQUEDA% %HORA_HASTA%:59' ORDER BY srno DESC;
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