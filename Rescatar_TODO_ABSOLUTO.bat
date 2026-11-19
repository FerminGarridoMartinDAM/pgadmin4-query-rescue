@echo off
setlocal
echo ---------------------------------------------------
echo      RESCATANDO TODO EL HISTORIAL (BACKUP TOTAL)
echo ---------------------------------------------------
echo.

set "FUENTE=%APPDATA%\pgAdmin\pgadmin4.db"
set "TEMPORAL=temp_db_full.db"
set "SALIDA=Historial_COMPLETO_Backup.csv"

echo [1/3] Copiando base de datos...
copy "%FUENTE%" "%TEMPORAL%" /Y >nul
if %errorlevel% neq 0 ( echo [ERROR] No encuentro pgAdmin. & pause & exit )

echo [2/3] Extrayendo cientos de registros...
(
echo .headers on
echo .mode csv
echo SELECT json_extract(CAST(unhex(query_info^) AS TEXT^), '$.query'^) as SQL, json_extract(CAST(unhex(query_info^) AS TEXT^), '$.start_time'^) as Fecha FROM query_history ORDER BY srno DESC;
) > instrucciones.sql

echo [3/3] Guardando...
sqlite3.exe "%TEMPORAL%" < instrucciones.sql > "%SALIDA%"

del "%TEMPORAL%"
del instrucciones.sql

echo.
echo ---------------------------------------------------
echo [EXITO] Backup completo guardado en:
echo %SALIDA%
echo ---------------------------------------------------
echo.
echo Pulsa una tecla para terminar...
pause >nul