# 🛠️ pgAdmin 4 Query Rescue

Pack de scripts automatizados para Windows que permite recuperar consultas SQL del historial interno de **pgAdmin 4** (pgadmin4.db) sin necesidad de instalar programas adicionales.

Ideal para rescatar prácticas o trabajo de clase cuando pgAdmin se cierra inesperadamente o se olvida guardar el archivo .sql.

## ✨ Características

- **Sin instalaciones:** Utiliza el motor portable oficial sqlite3.exe.
- **Seguro para pgAdmin:** Trabaja sobre una copia temporal de la base de datos para evitar bloqueos incluso si pgAdmin está abierto.
- **Nombres automáticos:** Formatea fechas y horas con PowerShell para funcionar en cualquier configuración regional de Windows.
- **5 modos de rescate:** Desde recuperación rápida de la última hora hasta filtrado interactivo por rango horario exacto.

---

## 📦 Scripts incluidos

| Script | Qué recupera | Comportamiento del archivo CSV |
| :--- | :--- | :--- |
| **Extraer_Ultima_Hora.bat** | Consultas de los últimos 60 minutos. | Crea un archivo nuevo con fecha y hora en cada ejecución (Historial_1H_AAAA-MM-DD_HH-MM.csv). |
| **Rescatar_HOY.bat** | Consultas de las últimas 24 horas. | Actualiza el mismo archivo durante el día y crea uno nuevo al cambiar de fecha (Historial_Dia_AAAA-MM-DD.csv). |
| **Rescatar_X_Horas.bat** | Consultas de las últimas *N* horas (interactivo). | Crea un archivo único indicando las horas seleccionadas (Historial_Ultimas_XH_...csv). |
| **Rescatar_Rango_Horas.bat** | Consultas de una fecha y tramo horario exacto (Desde / Hasta). | Crea un archivo con el día y el rango horario (Historial_Rango_AAAA-MM-DD_de_HH-MM_a_HH-MM.csv). |
| **Rescatar_TODO_ABSOLUTO.bat** | Todo el historial almacenado desde la instalación. | Sobrescribe siempre el mismo archivo (Historial_COMPLETO_Backup.csv). |

---

## 🚀 Cómo usarlo

1. Descarga el proyecto desde la pestaña **Releases** (recomendado) o en Code → Download ZIP.
2. **Descomprime** la carpeta completa en tu Escritorio (no ejecutes los scripts desde dentro del ZIP).
3. Haz **doble clic** en el script que necesites.
4. Sigue las instrucciones en pantalla (si elegiste un script interactivo) y pulsa una tecla al finalizar.
5. Abre el archivo .csv generado en la misma carpeta con Excel, LibreOffice Calc o VS Code.

📄 También tienes la guía detallada en PDF dentro de [docs/Guia_Rescate_SQL_pgAdmin4.pdf](docs/Guia_Rescate_SQL_pgAdmin4.pdf).

> **⚠️ Aviso de Windows SmartScreen:**  
> Al ser scripts .bat locales sin firma comercial, Windows Defender puede mostrar *"Windows protegió su PC"*. Haz clic en **Más información** → **Ejecutar de todas formas**. Puedes abrir cualquier .bat con clic derecho → **Editar** para auditar el código.

> **⚠️ No borres sqlite3.exe:**  
> Es el motor que utilizan los scripts para consultar y decodificar la base de datos temporal.

---

## 🔧 Método manual alternativo (DB Browser)

Si prefieres extraer las consultas manualmente:

1. Descarga [DB Browser for SQLite](https://sqlitebrowser.org/dl/).
2. Pulsa Win + R, escribe %APPDATA%\pgAdmin\ y copia pgadmin4.db en tu Escritorio.
3. Abre la copia con DB Browser, ve a la pestaña **Ejecutar SQL** y ejecuta:

``sql
SELECT 
    json_extract(CAST(unhex(query_info) AS TEXT), '$.query') AS SQL,
    datetime(json_extract(CAST(unhex(query_info) AS TEXT), '$.start_time'), 'localtime') AS Fecha
FROM query_history
ORDER BY srno DESC;