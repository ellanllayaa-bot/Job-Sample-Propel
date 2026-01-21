-- ¿Cuántas organizaciones o participantes únicos estuvieron activos POR MES?
-- POR MES
SELECT 
    FORMAT([Campaign_Start_Date], 'MMMM') AS Mes,
    COUNT(DISTINCT New_Organization_ID) AS Orgs_Unicas,
    COUNT(DISTINCT New_Participant_ID) AS Participantes_Unicos
FROM Tabla_Final_Looker_Propel
WHERE [Campaign_Start_Date] IS NOT NULL
GROUP BY FORMAT([Campaign_Start_Date], 'MMMM')
ORDER BY Mes;

-- ¿Cuántas organizaciones o participantes únicos estuvieron activos POR PAÍS?
SELECT 
    UPPER(Country) as Country,
    COUNT(DISTINCT New_Organization_ID) AS Orgs_Unicas,
    COUNT(DISTINCT New_Participant_ID) AS Participantes_Unicos
FROM Tabla_Final_Looker_Propel
WHERE [Campaign_Start_Date] IS NOT NULL
GROUP BY UPPER (Country)
ORDER BY UPPER (Country);

-- ¿Qué campañas tienen la mayor conversión (inscritos → asistentes)?
SELECT 
    c.Campaign_Name,
    c.Campaign_Type_Official,
    SUM(CAST(Cantidad_Registrados AS INT)) AS Total_Inscritos,
    SUM(CAST(Cantidad_Asistentes AS INT)) AS Total_Asistentes,
    CASE 
        WHEN SUM(CAST(Cantidad_Registrados AS INT)) = 0 THEN 0
        ELSE (SUM(CAST(Cantidad_Asistentes AS INT)) * 100.0) / SUM(CAST(Cantidad_Registrados AS INT))
    END AS Tasa_Conversion_Porcentaje
FROM Tabla_Final_Looker_Propel AS p
INNER JOIN [Dim_Campaign] AS c ON p.New_Campaign_ID = c.New_Campaign_ID
GROUP BY c.Campaign_Name, c.Campaign_Type_Official
ORDER BY Tasa_Conversion_Porcentaje DESC;

--¿Cuáles son los 5 países con mayor participación?
-- Para este caso,consideré que los países con mayor participación son aquellos que mejor tasa de conversión tienen.
SELECT TOP 5
    [Country],
    CASE 
        WHEN SUM(CAST(Cantidad_Registrados AS INT)) = 0 THEN 0
        ELSE (SUM(CAST(Cantidad_Asistentes AS INT)) * 100.0) / SUM(CAST(Cantidad_Registrados AS INT))
    END AS Total_Participaciones
FROM Tabla_Final_Looker_Propel
GROUP BY [Country]
ORDER BY Total_Participaciones DESC;

-- Métrica para monitorear el compromiso (engagement)
----- a Índice de Recurrencia (Sticky Factor)
SELECT 
    Participaciones_por_Persona,
    COUNT(*) AS Cantidad_de_Participantes,
    (COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT New_Participant_ID) FROM [Propel_Data_limpia])) AS Porcentaje_del_Total
FROM (
    SELECT New_Participant_ID, COUNT(*) AS Participaciones_por_Persona
    FROM Tabla_Final_Looker_Propel
    GROUP BY New_Participant_ID
) AS Sub
GROUP BY Participaciones_por_Persona
ORDER BY Participaciones_por_Persona DESC;

--Abandonos
SELECT 
    Country,
    SUM(CAST(Cantidad_Registrados AS INT)) AS Inscritos,
    SUM(CAST(Cantidad_Asistentes AS INT)) AS Asistentes,
    (1 - (SUM(CAST(Cantidad_Asistentes AS INT)) * 1.0 / NULLIF(SUM(CAST(Cantidad_Registrados AS INT)), 0))) * 100 AS Porcentaje_Abandono
FROM Tabla_Final_Looker_Propel
GROUP BY Country
ORDER BY Porcentaje_Abandono DESC;

-- ¿Qué campañas tienen la mayor conversión (inscritos → asistentes) EN BOLIVIA?
SELECT 
    c.Campaign_Name,
    c.Campaign_Type_Official,
    SUM(CAST(Cantidad_Registrados AS INT)) AS Total_Inscritos,
    SUM(CAST(Cantidad_Asistentes AS INT)) AS Total_Asistentes,
    CASE 
        WHEN SUM(CAST(Cantidad_Registrados AS INT)) = 0 THEN 0
        ELSE (SUM(CAST(Cantidad_Asistentes AS INT)) * 100.0) / SUM(CAST(Cantidad_Registrados AS INT))
    END AS Tasa_Conversion_Porcentaje
FROM Tabla_Final_Looker_Propel AS p
INNER JOIN [Dim_Campaign] AS c ON p.New_Campaign_ID = c.New_Campaign_ID
WHERE Country = 'Bolivia'
GROUP BY c.Campaign_Name, c.Campaign_Type_Official
ORDER BY Tasa_Conversion_Porcentaje DESC;

-- ¿Qué organizaciones tienen la mayor conversión (inscritos → asistentes) EN BOLIVIA?
SELECT 
    c.Organization_Name,
    c.Organization_type_Oficial,
    SUM(CAST(Cantidad_Registrados AS INT)) AS Total_Inscritos,
    SUM(CAST(Cantidad_Asistentes AS INT)) AS Total_Asistentes,
    CASE 
        WHEN SUM(CAST(Cantidad_Registrados AS INT)) = 0 THEN 0
        ELSE (SUM(CAST(Cantidad_Asistentes AS INT)) * 100.0) / SUM(CAST(Cantidad_Registrados AS INT))
    END AS Tasa_Conversion_Porcentaje
FROM Tabla_Final_Looker_Propel AS p
INNER JOIN [Dim_Organization] AS c ON p.New_Organization_ID = c.New_Organization_ID
WHERE Country = 'Bolivia'
GROUP BY c.Organization_Name, c.Organization_type_Oficial
ORDER BY Tasa_Conversion_Porcentaje DESC;