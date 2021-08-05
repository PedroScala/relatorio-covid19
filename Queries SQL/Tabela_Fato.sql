/******Tabela Fato******/
SELECT [iso_code]
      ,[date]
      ,[total_cases]
      ,[new_cases]
      ,[total_deaths]
      ,[new_deaths]
	  ,population
  FROM [CovidDB].[dbo].[CovidDeaths]
  WHERE continent IS NOT NULL
  ORDER BY date desc