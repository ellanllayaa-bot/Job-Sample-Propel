-- =============================================
-- Autor: Edith Josefina Llanllaya Alccahuaman
-- Fecha: 2026
-- Descripción: Automatización de la tabla resumen para el Dashboard de Propel.
-- =============================================
CREATE OR ALTER PROCEDURE sp_Generar_Resumen_Looker_01
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Limpiamos la tabla final si ya existe
    IF OBJECT_ID('dbo.Tabla_Final_Looker_Propel', 'U') IS NOT NULL
        DROP TABLE dbo.Tabla_Final_Looker_Propel;

    -- 2. Creación de la tabla con la estructura exacta de tu CSV
    SELECT 
        
        n.New_Participant_ID,
        p.New_Organization_ID,
        c.New_Campaign_ID,
        o.Organization_Name,
        o.Organization_type_Oficial,
        c.Campaign_Name,
        c.Campaign_Type_Official,
        
        -- Fechas y Campos de Mes
        c.Campaign_Start_Date,
        c.Campaign_End_Date,
        p.Country,
        p.Segment,
        Engagement_Score,

        FORMAT(c.Campaign_Start_Date, 'MMMM', 'es-ES') AS Mes_Nombre,
        MONTH(c.Campaign_Start_Date) AS Mes_Numero,

        -- Métricas de Participación (Casteamos a INT por seguridad)
        CAST(p.Registered AS INT) AS Cantidad_Registrados,
        CAST(p.Attended AS INT) AS Cantidad_Asistentes,
        CASE 
        WHEN SUM(CAST(Registered AS INT)) = 0 THEN 0
        ELSE (SUM(CAST(Attended AS INT)) * 100.0) / SUM(CAST(Registered AS INT))
    END AS Tasa_Conversion_Porcentaje

    INTO dbo.Tabla_Final_Looker_Propel
    FROM [Propel_Data_limpia] AS p
    INNER JOIN [Dim_Organization] AS o ON p.New_Organization_ID = o.New_Organization_ID
    INNER JOIN [Dim_Campaign] AS c ON p.New_Campaign_ID = c.New_Campaign_ID
    INNER JOIN [Dim_Participant] AS n ON p.New_Participant_ID = n.New_Participant_ID
    WHERE p.New_Campaign_ID IS NOT NULL;

    PRINT '>>> Tabla [dbo.Tabla_Final_Looker_Propel] generada con éxito con la estructura del CSV.';
END;
GO