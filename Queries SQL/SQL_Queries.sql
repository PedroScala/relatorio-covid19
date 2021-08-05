SELECT *
FROM CovidDB..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM CovidDB..CovidVaccinations
--WHERE continent IS NOT NULL
--ORDER BY 3,4

-- Selecionando dados que ser�o utilizados

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDB..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total de Casos vs Total de �bitos
-- Estimativa de probabilidade de vir a �bito caso contraia COVID
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDB..CovidDeaths
WHERE location like '%brazil%' AND continent IS NOT NULL
ORDER BY 1,2

-- Total de Casos vs Popula��o
-- Percentual da popula��o que contraiu COVID
SELECT location, date, total_cases, population, (total_cases/population)*100 AS CasesPercentage
FROM CovidDB..CovidDeaths
WHERE location like '%brazil%' AND continent IS NOT NULL
ORDER BY 1,2


-- Pa�ses com maiores taxas de infec��o comparado a popula��o

SELECT location, MAX(total_cases) AS MaiorContagemInfec , population, MAX((total_cases/population))*100 AS PopTaxaInfec
FROM CovidDB..CovidDeaths
--WHERE location like '%brazil%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PopTaxaInfec DESC

-- Considerando por continente 
-- Quando separado diretamente por continente os dados se apresentam falsos (estudar isso)

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalObito
FROM CovidDB..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalObito DESC


-- Total de �bitos nos pa�ses

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalObito
FROM CovidDB..CovidDeaths
--WHERE location like '%brazil%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalObito DESC

-- Continentes com maior contagem de obtidos por populacap
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalObito
FROM CovidDB..CovidDeaths
WHERE continent IS NULL 
AND location != 'World'
AND location != 'European Union'
AND location != 'International'
GROUP BY location
ORDER BY TotalObito DESC

-- N�meros Internacionais

SELECT sum(new_cases) AS Total_Casos, SUM(CAST(new_deaths AS int)) AS Total_Obitos, SUM(cast(New_deaths AS int))/SUM(New_Cases)*100 AS Perc_Obito
FROM CovidDB..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--Popula��o Total vs Vacina��o

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
 dea.Date) AS Sub_Total_Vac
, (Sub_Total_Vac/population
FROM CovidDB..CovidDeaths dea
JOIN CovidDB..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
ORDER BY 2,3

-- Usando CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, SubTotal_Vac)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
 dea.Date) AS SubTotal_Vac
FROM CovidDB..CovidDeaths dea
JOIN CovidDB..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (SubTotal_Vac/Population)*100
FROM PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
SubTotal_Vac numeric,
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
 dea.Date) AS SubTotal_Vac
FROM CovidDB..CovidDeaths dea
JOIN CovidDB..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
SELECT *, (SubTotal_Vac/Population)*100
FROM #PercentPopulationVaccinated


-- Criando visualiza��es para an�lise explorat�ria

CREATE View PercentPopVac AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
 dea.Date) AS SubTotal_Vac
FROM CovidDB..CovidDeaths dea
JOIN CovidDB..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null


