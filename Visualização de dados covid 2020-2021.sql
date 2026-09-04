/* ============================================================
   1. VISUALIZAÇÃO INICIAL DOS DADOS
   ============================================================ */

SELECT *
FROM projeto_portfolio..mortes_covid
WHERE continent IS NOT NULL
ORDER BY 3, 4;


/* ============================================================
   2. SELECIONANDO OS DADOS PRINCIPAIS
   ============================================================ */

SELECT 
    Location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM projeto_portfolio..mortes_covid
WHERE continent IS NOT NULL
ORDER BY 1, 2;


/* ============================================================
   3. TOTAL DE CASOS VS TOTAL DE MORTES
   ============================================================
   Mostra a porcentagem de mortes em relação aos casos
   ============================================================ */

SELECT 
    Location,
    date,
    total_cases,
    total_deaths,
    (CAST(total_deaths AS FLOAT) / NULLIF(total_cases, 0)) * 100 
        AS DeathPercentage
FROM projeto_portfolio..mortes_covid
WHERE location LIKE '%states%'
  AND continent IS NOT NULL
ORDER BY 1, 2;


/* ============================================================
   4. TOTAL DE CASOS VS POPULAÇÃO
   ============================================================
   Mostra qual porcentagem da população foi infectada
   ============================================================ */

SELECT 
    Location,
    date,
    Population,
    total_cases,
    (CAST(total_cases AS FLOAT) / NULLIF(population, 0)) * 100 
        AS PercentPopulationInfected
FROM projeto_portfolio..mortes_covid
WHERE continent IS NOT NULL
ORDER BY 1, 2;


/* ============================================================
   5. PAÍSES COM MAIOR TAXA DE INFECÇÃO
   ============================================================ */

SELECT 
    Location,
    Population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX(
        (CAST(total_cases AS FLOAT) / NULLIF(population, 0)) * 100
    ) AS PercentPopulationInfected
FROM projeto_portfolio..mortes_covid
WHERE continent IS NOT NULL
GROUP BY 
    Location,
    Population
ORDER BY PercentPopulationInfected DESC;


/* ============================================================
   6. PAÍSES COM MAIOR NÚMERO DE MORTES
   ============================================================ */

SELECT 
    Location,
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM projeto_portfolio..mortes_covid
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;


/* ============================================================
   7. ANÁLISE POR CONTINENTE
   ============================================================ */

SELECT 
    continent,
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM projeto_portfolio..mortes_covid
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


/* ============================================================
   8. NÚMEROS GLOBAIS
   ============================================================ */

SELECT 
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS INT)) AS total_deaths,
    (
        CAST(SUM(CAST(new_deaths AS INT)) AS FLOAT)
        / NULLIF(SUM(new_cases), 0)
    ) * 100 AS DeathPercentage
FROM projeto_portfolio..mortes_covid
WHERE continent IS NOT NULL;


/* ============================================================
   9. POPULAÇÃO VS VACINAÇÃO
   ============================================================
   Calcula o número acumulado de vacinações ao longo do tempo
   ============================================================ */

SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,

    SUM(
        CONVERT(BIGINT, vac.new_vaccinations)
    ) OVER (
        PARTITION BY dea.Location
        ORDER BY dea.Date
    ) AS RollingPeopleVaccinated

FROM projeto_portfolio..mortes_covid AS dea

JOIN projeto_portfolio..vacinacoes_covid AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date

WHERE dea.continent IS NOT NULL

ORDER BY 2, 3;


/* ============================================================
   10. CTE
   ============================================================
   Utiliza uma CTE para calcular o percentual acumulado
   da população vacinada
   ============================================================ */

WITH PopvsVac
(
    Continent,
    Location,
    Date,
    Population,
    New_Vaccinations,
    RollingPeopleVaccinated
)
AS
(
    SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,

        SUM(
            CONVERT(BIGINT, vac.new_vaccinations)
        ) OVER (
            PARTITION BY dea.Location
            ORDER BY dea.Date
        ) AS RollingPeopleVaccinated

    FROM projeto_portfolio..mortes_covid AS dea

    JOIN projeto_portfolio..vacinacoes_covid AS vac
        ON dea.location = vac.location
        AND dea.date = vac.date

    WHERE dea.continent IS NOT NULL
)

SELECT 
    *,
    (
        CAST(RollingPeopleVaccinated AS FLOAT)
        / NULLIF(Population, 0)
    ) * 100 AS PercentPopulationVaccinated
FROM PopvsVac;


/* ============================================================
   11. TABELA TEMPORÁRIA
   ============================================================ */

DROP TABLE IF EXISTS #PercentPopulationVaccinated;


CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_Vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);


INSERT INTO #PercentPopulationVaccinated
(
    Continent,
    Location,
    Date,
    Population,
    New_Vaccinations,
    RollingPeopleVaccinated
)

SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,

    SUM(
        CONVERT(BIGINT, vac.new_vaccinations)
    ) OVER (
        PARTITION BY dea.Location
        ORDER BY dea.Date
    ) AS RollingPeopleVaccinated

FROM projeto_portfolio..mortes_covid AS dea

JOIN projeto_portfolio..vacinacoes_covid AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date

WHERE dea.continent IS NOT NULL;


SELECT 
    *,
    (
        CAST(RollingPeopleVaccinated AS FLOAT)
        / NULLIF(Population, 0)
    ) * 100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated;


/* ============================================================
   12. VIEW
   ============================================================
   Cria uma View para utilizar posteriormente em visualizações
   ============================================================ */

CREATE OR ALTER VIEW PercentPopulationVaccinated AS

SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,

    SUM(
        CONVERT(BIGINT, vac.new_vaccinations)
    ) OVER (
        PARTITION BY dea.Location
        ORDER BY dea.Date
    ) AS RollingPeopleVaccinated

FROM projeto_portfolio..mortes_covid AS dea

JOIN projeto_portfolio..vacinacoes_covid AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date

WHERE dea.continent IS NOT NULL;