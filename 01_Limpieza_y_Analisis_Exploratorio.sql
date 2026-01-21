--Creamos una copia de la BD para la limpieza
SELECT *  FROM STG_Propel_Data;
IF OBJECT_ID('Propel_Data_limpia', 'U') IS NOT NULL DROP TABLE Propel_Data_limpia;

SELECT * INTO Propel_Data_limpia from STG_Propel_Data;

--Limpieza de la información

UPDATE Propel_Data_limpia
set Campaign_Start_Date = REPLACE (Campaign_Start_Date,'-','/');

SELECT Campaign_Start_Date 
FROM Propel_Data_limpia
WHERE TRY_CONVERT (DATE, Campaign_Start_Date,103) IS NULL
AND Campaign_Start_Date IS NOT NULL

UPDATE Propel_Data_limpia
SET Campaign_Start_Date= TRY_CONVERT(DATE, Campaign_Start_Date,103)
where TRY_CONVERT(DATE, Campaign_Start_Date,103) is not null;

UPDATE Propel_Data_limpia
SET Campaign_Start_Date= TRY_CONVERT(DATE, Campaign_Start_Date,111)
where TRY_CONVERT(DATE, Campaign_Start_Date,111) is not null;

UPDATE Propel_Data_limpia
SET Campaign_Start_Date= TRY_CONVERT(DATE, Campaign_Start_Date,101)
where TRY_CONVERT(DATE, Campaign_Start_Date,101) is not null;



UPDATE Propel_Data_limpia
set Campaign_End_Date = REPLACE (Campaign_End_Date,'.','/');

SELECT Campaign_End_Date 
FROM Propel_Data_limpia
WHERE TRY_CONVERT (DATE, Campaign_End_Date ,103) IS NULL
AND Campaign_End_Date  IS NOT NULL

UPDATE Propel_Data_limpia
SET Campaign_End_Date = TRY_CONVERT(DATE, Campaign_End_Date ,103)
where TRY_CONVERT(DATE, Campaign_End_Date ,103) is not null;

UPDATE Propel_Data_limpia
SET Campaign_End_Date = TRY_CONVERT(DATE, Campaign_End_Date ,111)
where TRY_CONVERT(DATE, Campaign_End_Date ,111) is not null;

UPDATE Propel_Data_limpia
SET Campaign_End_Date = TRY_CONVERT(DATE, Campaign_End_Date ,101)
where TRY_CONVERT(DATE, Campaign_End_Date ,101) is not null;



UPDATE Propel_Data_limpia
set Registration_Date = REPLACE (Registration_Date,'-','/');

SELECT Registration_Date
FROM Propel_Data_limpia
WHERE TRY_CONVERT (DATE, Registration_Date ,103) IS NULL
AND Registration_Date  IS NOT NULL

UPDATE Propel_Data_limpia
SET Registration_Date  = TRY_CONVERT(DATE, Registration_Date  ,103)
where TRY_CONVERT(DATE, Registration_Date  ,103) is not null;

UPDATE Propel_Data_limpia
SET Registration_Date  = TRY_CONVERT(DATE, Registration_Date  ,111)
where TRY_CONVERT(DATE, Registration_Date  ,111) is not null;

UPDATE Propel_Data_limpia
SET Registration_Date  = TRY_CONVERT(DATE, Registration_Date  ,101)
where TRY_CONVERT(DATE, Registration_Date  ,101) is not null;


UPDATE Propel_Data_limpia
set Attendance_Date = REPLACE (Attendance_Date,'.','/');

SELECT Attendance_Date
FROM Propel_Data_limpia
WHERE TRY_CONVERT (DATE, Attendance_Date ,103) IS NULL
AND Attendance_Date  IS NOT NULL

UPDATE Propel_Data_limpia
SET Attendance_Date = TRY_CONVERT(DATE, Attendance_Date  ,103)
where TRY_CONVERT(DATE, Attendance_Date  ,103) is not null;

UPDATE Propel_Data_limpia
SET Attendance_Date = TRY_CONVERT(DATE, Attendance_Date  ,111)
where TRY_CONVERT(DATE, Attendance_Date  ,111) is not null;

UPDATE Propel_Data_limpia
SET Attendance_Date  = TRY_CONVERT(DATE, Attendance_Date ,101)
where TRY_CONVERT(DATE, Attendance_Date ,101) is not null;

ALTER TABLE Propel_Data_limpia ALTER COLUMN Campaign_Start_Date DATE;
ALTER TABLE Propel_Data_limpia ALTER COLUMN Campaign_End_Date DATE;
ALTER TABLE Propel_Data_limpia ALTER COLUMN Registration_Date DATE;
ALTER TABLE Propel_Data_limpia ALTER COLUMN Attendance_Date DATE;

EXEC sp_help 'Propel_Data_limpia';

SELECT Attendance_Date FROM Propel_Data_limpia
WHERE Attendance_Date = '1900/01/01';

UPDATE Propel_Data_limpia
SET Attendance_Date = NULL
WHERE Attendance_Date = '1900/01/01';

-- Estandarizando VERDADERO Y FALSO
UPDATE Propel_Data_limpia
SET Registered = 'Verdadero'
WHERE Registered in ('VERDADERO','Yes','YES');

UPDATE Propel_Data_limpia
SET Registered = 'Falso'
WHERE Registered in ('FALSO','No','no','NO');

UPDATE Propel_Data_limpia
SET Attended = 'Verdadero'
WHERE Attended in ('VERDADERO','Yes','YES');

UPDATE Propel_Data_limpia
SET Attended = 'Falso'
WHERE Attended in ('FALSO','No','no','NO');


-- Contamos las inconsistencias entre fechas y verdadero/falso
SELECT 
    COUNT(*) AS total_inconsistencias
FROM Propel_Data_limpia
WHERE (Registration_Date IS NOT NULL AND Registered = 'Falso') -- Casos donde hay fecha pero dice que no se registró
   OR (Registration_Date IS NULL AND Registered = 'Verdadero');

-- Cambiando de VARCHAR A BIT en Registered y Attended
UPDATE Propel_Data_limpia
SET 
    Registered = CASE WHEN Registration_Date IS NOT NULL THEN '1' ELSE '0' END,
    Attended = CASE WHEN Attendance_Date IS NOT NULL THEN '1' ELSE '0' END;

ALTER TABLE Propel_Data_limpia
ALTER COLUMN Registered BIT;

ALTER TABLE Propel_Data_limpia
ALTER COLUMN Attended BIT;

-- Eliminando inconsistencias
UPDATE Propel_Data_limpia
SET
    -- Si hay fecha, es TRUE (Registrado), de lo contrario es FALSE
    Registered = CASE
    WHEN Registration_Date IS NOT NULL THEN 1
    ELSE 0
    END,

    -- Si hay fecha de asistencia, es TRUE, de lo contrario FALSE
    Attended = CASE
    WHEN Attendance_Date IS NOT NULL THEN 1
    ELSE 0
    END;

-- limpiando espacios en blanco

update Propel_Data_limpia
Set Organization_Name = TRIM (Organization_Name);

update Propel_Data_limpia
Set Organization_Name = REPLACE (Organization_Name, '  ',' ');

update Propel_Data_limpia
Set Organization_type = REPLACE (TRIM (Organization_type), '  ',' ');

update Propel_Data_limpia
Set Country = REPLACE (TRIM (Country), '  ',' ');

update Propel_Data_limpia
Set Campaign_Name= REPLACE (TRIM (Campaign_Name), '  ',' ');

update Propel_Data_limpia
Set Campaign_Type= REPLACE (TRIM (Campaign_Type), '  ',' ');

update Propel_Data_limpia
Set Participant_Name= REPLACE (TRIM (Participant_Name), '  ',' ');

update Propel_Data_limpia
Set Segment= REPLACE (TRIM (Segment), '  ',' ');

-- Detectanto inconsistencias entre nombre y tipo de organization

SELECT 
    UPPER(TRIM(Organization_Name)) AS Nombre_Limpio,
    COUNT(DISTINCT Organization_ID) AS Cantidad_de_IDs_que_usa,
    COUNT(*) AS Total_Registros
FROM Propel_Data_limpia
GROUP BY UPPER(TRIM(Organization_Name))
ORDER BY Cantidad_de_IDs_que_usa DESC;

-- Revisando inconsistencias entre nombre y tipo de organization

SELECT 
    UPPER(TRIM([Organization_Name])) AS Nombre_Limpio,
    COUNT(DISTINCT [Organization_type]) AS Cantidad_de_Tipos,
    -- Esta es la alternativa a STRING_AGG para versiones antiguas:
    STUFF((
        SELECT DISTINCT ', ' + t2.[Organization_type]
        FROM [Propel_Data_limpia] t2
        WHERE UPPER(TRIM(t2.[Organization_Name])) = UPPER(TRIM(t1.[Organization_Name]))
        FOR XML PATH('')), 1, 2, '') AS Tipos_Detectados
FROM [Propel_Data_limpia] t1
GROUP BY UPPER(TRIM([Organization_Name]))
HAVING COUNT(DISTINCT [Organization_type]) > 1;

-- buscamos  registros duplicados
SELECT 
    [Organization_ID],
    [Organization_Name],
    [Organization_type],
    [Country],
    [Campaign_ID],
    [Campaign_Type],
    [Campaign_Start_Date],
    [Campaign_End_Date],
    [Participant_ID],
    [Registered],
    [Attended],
    [Attendance_Date],
    [Engagement_Score],
    [Segment],
    [Participant_Name], 
    [Campaign_Name], 
    [Registration_Date],
    COUNT(*) AS Repeticiones
FROM [Propel_Data_limpia]
GROUP BY [Organization_ID],[Organization_Name],[Organization_type],[Country],[Campaign_ID],[Campaign_Type],[Campaign_Start_Date],[Campaign_End_Date],
    [Participant_ID],[Registered],[Attended],[Attendance_Date],[Engagement_Score],[Segment], [Participant_Name], [Campaign_Name], [Registration_Date]
ORDER BY Repeticiones DESC;


-- eliminando 5 duplicados que encontramos
WITH CTE_Duplicados AS (
    SELECT 
        [Participant_Name], 
        [Campaign_Name], 
        [Registration_Date],
        -- Generamos un número de fila para cada grupo de duplicados
        ROW_NUMBER() OVER (
            PARTITION BY [Participant_Name], [Campaign_Name], [Registration_Date] 
            ORDER BY (SELECT NULL) -- No importa el orden, son idénticos
        ) AS NumeroFila
    FROM [Propel_Data_limpia]
)
-- Borramos solo las filas donde el número es mayor a 1
DELETE FROM CTE_Duplicados
WHERE NumeroFila > 1;

IF OBJECT_ID('Dim_Organization', 'U') IS NOT NULL
    DROP TABLE Dim_Organization;
GO

-- Creamos la tabla maestra con una llave primaria numérica (IDENTITY)
-- 1. Borramos la anterior
IF OBJECT_ID('Dim_Organization', 'U') IS NOT NULL DROP TABLE Dim_Organization;

-- 2. Creamos la nueva con el formato 'ORG000'
SELECT 
    'ORG' + FORMAT(ROW_NUMBER() OVER (ORDER BY Organization_Name), '000') AS New_Organization_ID,
    Organization_Name,
    Organization_type_Oficial
INTO Dim_Organization
FROM (
-- Usamos tu tabla ya corregida o la lógica de nombres únicos
    SELECT 
        UPPER(TRIM([Organization_Name])) AS Organization_Name,
        -- Asegúrate de usar aquí la lógica que ya habías corregido con los tipos reales
        MIN([Organization_type]) AS Organization_type_Oficial 
    FROM [Propel_Data_limpia]
    GROUP BY UPPER(TRIM([Organization_Name]))
) AS BaseUnica;


ALTER TABLE [Propel_Data_limpia]
ADD [New_Organization_ID] VARCHAR(10);

-- LLevando el nuevo ID a la tabla de hechos
UPDATE p
SET p.[New_Organization_ID] = d.[New_Organization_ID]
FROM [Propel_Data_limpia] AS p
INNER JOIN [Dim_Organization] AS d 
    ON UPPER(TRIM(p.[Organization_Name])) = d.[Organization_Name];

-- AHORA asignamos correctamente el tipo de organizacion por Data Enrichment
UPDATE Dim_Organization
SET Organization_type_Oficial = CASE 
    WHEN Organization_Name = 'COMUNIDAD DATALATAM' THEN 'Community Org'
    WHEN Organization_Name = 'EDU IMPACT'           THEN 'Social Enterprise'
    WHEN Organization_Name = 'FUNDACIÓN FUTURO'     THEN 'Foundation'
    WHEN Organization_Name = 'FUNDACIÓN LUZ VERDE'  THEN 'Foundation'
    WHEN Organization_Name = 'INNOVACCIÓN'          THEN 'NGO'
    WHEN Organization_Name = 'JÓVENES POR EL CLIMA' THEN 'Community Org'
    WHEN Organization_Name = 'PUENTES DIGITALES'    THEN 'NGO'
    WHEN Organization_Name = 'RED MUJERES+'         THEN 'Community Org'
    WHEN Organization_Name = 'SALUD CONECTA'        THEN 'Social Enterprise'
    WHEN Organization_Name = 'TECH POR TODOS'      THEN 'NGO'
    ELSE 'Other' 
END;
-- verificando
SELECT Organization_type_Oficial, COUNT(*) as Total
FROM Dim_Organization
GROUP BY Organization_type_Oficial;

--verificando
SELECT COUNT(*) AS Filas_Sin_ID
FROM [Propel_Data_limpia]
WHERE [New_Organization_ID] IS NULL;

----======== CASO CAMPAÑAS
-- Detectanto inconsistencias

SELECT 
    UPPER(TRIM(Campaign_Name)) AS NombreCamp_Limpio,
    COUNT(DISTINCT Campaign_ID) AS Cantidad_de_IDs_que_usa,
    COUNT(*) AS Total_Registros
FROM Propel_Data_limpia
GROUP BY UPPER(TRIM(Campaign_Name))
ORDER BY Cantidad_de_IDs_que_usa DESC;

-- Revisando inconsistencias entre nombre y tipo de campaña

SELECT 
    UPPER(TRIM([Campaign_Name])) AS Nombre_Limpio,
    COUNT(DISTINCT [Campaign_Type]) AS Cantidad_de_Tipos,
    -- Esta es la alternativa a STRING_AGG para versiones antiguas:
    STUFF((
        SELECT DISTINCT ', ' + t2.[Campaign_Type]
        FROM [Propel_Data_limpia] t2
        WHERE UPPER(TRIM(t2.[Campaign_Name])) = UPPER(TRIM(t1.[Campaign_Name]))
        FOR XML PATH('')), 1, 2, '') AS Tipos_Detectados
FROM [Propel_Data_limpia] t1
GROUP BY UPPER(TRIM([Campaign_Name]))
HAVING COUNT(DISTINCT [Campaign_Type]) > 1;

-- creando Dim_Campaign
IF OBJECT_ID('Dim_Campaign', 'U') IS NOT NULL DROP TABLE Dim_Campaign;

SELECT 
    'CMP' + FORMAT(ROW_NUMBER() OVER (ORDER BY Campaign_Name), '000') AS New_Campaign_ID,
    Campaign_Name,
    Campaign_Start_Date,
    Campaign_End_Date,
    CAST('' AS VARCHAR(50)) AS Campaign_Type_Official -- Creamos el espacio para el tipo
INTO Dim_Campaign
FROM (
    SELECT DISTINCT 
        UPPER(TRIM([Campaign_Name])) AS Campaign_Name,
        [Campaign_Start_Date],
        [Campaign_End_Date]
    FROM [Propel_Data_limpia]
) AS Base;
-- Asignando el tipo de campaña
UPDATE Dim_Campaign
SET Campaign_Type_Official = CASE 
    WHEN Campaign_Name = 'AI FOR SOCIAL IMPACT'        THEN 'Webinar'
    WHEN Campaign_Name = 'CLIMATE INNOVATION HUB'      THEN 'Outreach'
    WHEN Campaign_Name = 'COMMUNITY FUNDRAISING GALA'  THEN 'Fundraising'
    WHEN Campaign_Name = 'DIGITAL INCLUSION BOOTCAMP'  THEN 'Training'
    WHEN Campaign_Name = 'FUNDRAISING ACCELERATOR'     THEN 'Fundraising'
    WHEN Campaign_Name = 'IMPACT MEASUREMENT 101'      THEN 'Training'
    WHEN Campaign_Name = 'LATAM DATA SUMMIT'           THEN 'Outreach'
    WHEN Campaign_Name = 'NONPROFIT TECH CLINIC'       THEN 'Tech support'
    WHEN Campaign_Name = 'STEAM TEACHERS WORKSHOP'     THEN 'Training'
    WHEN Campaign_Name = 'WOMEN IN TECH TALKS'         THEN 'Webinar'
END;

SELECT*FROM Propel_Data_limpia

-- LLevando el nuevo ID_campaña a la tabla de hechos


ALTER TABLE [Propel_Data_limpia]
ADD [New_Campaign_ID] VARCHAR(10); 


UPDATE p
SET p.[New_Campaign_ID] = c.[New_Campaign_ID]
FROM [Propel_Data_limpia] AS p
INNER JOIN [Dim_Campaign] AS c 
    ON UPPER(TRIM(p.[Campaign_Name])) = c.[Campaign_Name]
    AND p.[Campaign_Start_Date] = c.[Campaign_Start_Date];

-- verificando
SELECT COUNT(*) AS Registros_Sin_ID_Campana
FROM [Propel_Data_limpia]
WHERE [New_Campaign_ID] IS NULL;


--corrigiendo fechas de Start_Date de campaña que eran nulas
UPDATE Propel_Data_limpia
SET Campaign_Start_Date = NULL
WHERE Campaign_Start_Date = '1900/01/01';

SELECT*FROM Propel_Data_limpia

----------------------------------CASO PARTICIPANTE
-- Detectanto inconsistencias

SELECT 
    UPPER(TRIM(Participant_Name)) AS NameParticipante_Limpio,
    COUNT(DISTINCT Participant_ID) AS Cantidad_de_IDs_que_usa,
    COUNT(*) AS Total_Registros
FROM Propel_Data_limpia
GROUP BY UPPER(TRIM(Participant_Name))
ORDER BY Cantidad_de_IDs_que_usa DESC;

SELECT
Country,
COUNT(*) AS TOTAL_REGISTROS
FROM Propel_Data_limpia
GROUP BY Country

UPDATE Propel_Data_limpia
set Country = 'Argentina'
WHERE Country in ('ARGENTINA')


-------------------------------- CASO PARTICIPANTES (luego de las inconsistencias)
-- 1. Crear la tabla maestra de Participantes
IF OBJECT_ID('Dim_Participant', 'U') IS NOT NULL DROP TABLE Dim_Participant;

SELECT 
    'PAR' + FORMAT(ROW_NUMBER() OVER (ORDER BY Participant_Name), '000') AS New_Participant_ID,
    Participant_Name
INTO Dim_Participant
FROM (
    SELECT DISTINCT UPPER(TRIM([Participant_Name])) AS Participant_Name
    FROM [Propel_Data_limpia]
) AS BaseParticipantes;

-- 2. Asegurar que la columna existe en la tabla de hechos
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('[Propel_Data_limpia]') AND name = 'New_Participant_ID')
    ALTER TABLE [Propel_Data_limpia] ADD [New_Participant_ID] VARCHAR(10);

-- 3. Mapear los IDs de la Dimensión a la Tabla de Hechos
UPDATE p
SET p.[New_Participant_ID] = d.[New_Participant_ID]
FROM [Propel_Data_limpia] AS p
INNER JOIN [Dim_Participant] AS d 
    ON UPPER(TRIM(p.[Participant_Name])) = d.Participant_Name;

SELECT*FROM Dim_Participant

-- Verifica que no existan registros sin ID de participante
SELECT COUNT(*) AS Participantes_Sin_ID FROM [Propel_Data_limpia] WHERE New_Participant_ID IS NULL;

-- dejando la tabla de hechos esbelta
ALTER TABLE [Propel_Data_limpia]
DROP COLUMN 
    [Organization_Name], 
    [Organization_type], 
    [Campaign_ID], 
    [Campaign_Name], 
    [Campaign_Type], 
    [Participant_ID], 
    [Participant_Name];
GO

UPDATE Propel_Data_limpia
set Country = 'Bolivia'
WHERE Country in ('BOLIVIA')
DELETE FROM [Propel_Data_limpia]
WHERE New_Campaign_ID IS NULL;

------========= creando una VISTA

ALTER VIEW View_Looker_Propel AS
SELECT 
    p.New_Participant_ID,
    p.New_Organization_ID,
    p.New_Campaign_ID,
    o.Organization_Name,
    o.Organization_type_Oficial,
    c.Campaign_Name,
    c.Campaign_Type_Official,
    c.Campaign_Start_Date,
    c.Campaign_End_Date,
    p.Country,
    p.Segment,
    p.Engagement_Score,
    -- 1. Nombre del Mes (Ej: Enero, Febrero...)
    FORMAT(c.Campaign_Start_Date, 'MMMM', 'es-ES') AS Mes_Nombre,
    -- 2. Número del Mes (Ej: 1, 2... para poder ordenar)
    MONTH(c.Campaign_Start_Date) AS Mes_Numero,
    CAST(p.Registered AS INT) AS Cantidad_Registrados,
    CAST(p.Attended AS INT) AS Cantidad_Asistentes
FROM [Propel_Data_limpia] AS p
LEFT JOIN [Dim_Organization] AS o ON p.New_Organization_ID = o.New_Organization_ID
LEFT JOIN [Dim_Campaign] AS c ON p.New_Campaign_ID = c.New_Campaign_ID;

SELECT * FROM dbo.View_Looker_Propel;
