SELECT DISTINCT iso_code, location, continent
FROM CovidDB..CovidDeaths
WHERE continent IS NOT NULL
