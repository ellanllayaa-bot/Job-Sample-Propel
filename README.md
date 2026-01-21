Contenido:
01_Limpieza_y_Analisis_Exploratorio.sql: Proceso técnico de preparación de datos.
02_ETL_Final_Propel.sql: Automatización y creación de la tabla maestra.
03_Consultas_Negocio.sql: Consultas estratégicas listas para responder preguntas de negocio.
Cómo ejecutar:
Asegúrese de tener las tablas originales cargadas en su entorno de SQL Server.
1.	Ejecute el script 01_Limpieza_y_Analisis_Exploratorio.sql para preparar el entorno.
2.	Ejecute el script 02_ETL_Final_Propel.sql para compilar el procedimiento almacenado en su servidor.
3.	Para procesar los datos y generar la tabla maestra que alimenta el dashboard, ejecute: EXEC sp_Generar_Resumen_Looker_01;
4.	Para visualizar los resultados finales, ejecute: SELECT * FROM Tabla_Final_Looker_Propel;
5.	Ejecute el script 03_Consultas_Negocio.sql 
