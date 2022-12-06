-- COVID DEATH DATA EXPLORATIONS
SELECT location,continent, date, total_cases, new_cases,total_deaths, population
FROM PortfolioCovidProject..WorldCovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioCovidProject..WorldCovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total Cases vs Population
SELECT location, date, total_cases,population, (total_cases/population)*100 as CasePercentage
FROM PortfolioCovidProject..WorldCovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Highest Infection Rate Country
SELECT location, population, MAX(total_cases) as TotalCase, MAX((total_cases/population))*100 as CasePercentage
FROM PortfolioCovidProject..WorldCovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY CasePercentage DESC

-- Highest Death Case Country
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeaths
FROM PortfolioCovidProject..WorldCovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeaths DESC

-- Highest Death Region
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeaths
FROM PortfolioCovidProject..WorldCovidDeaths
WHERE continent is null 
GROUP BY location
ORDER BY TotalDeaths DESC

-- Global Numbers
SELECT date, SUM(new_cases) as TotalCasesPerDay, SUM(CAST(new_deaths as int)) as TotalDeathsPerDay, 
SUM(CAST(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentagePerDay
FROM PortfolioCovidProject..WorldCovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2 ASC

-- COVID VACCINATION DATA EXPLORATIONS
SELECT *
FROM PortfolioCovidProject..WorldCovidDeaths as dea
LEFT JOIN PortfolioCovidProject..WorldCovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- Populations VS Vactinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed,
	SUM(CONVERT(bigint,vac.new_people_vaccinated_smoothed)) OVER (PARTITION BY dea.location ORDER BY dea.date) as VaccinationsOneCumulative,
	SUM(CONVERT(bigint,vac.new_people_vaccinated_smoothed)) OVER (PARTITION BY dea.location ORDER BY dea.date) / dea.population * 100 as VaccinationsOnePercentage
FROM PortfolioCovidProject..WorldCovidDeaths as dea
JOIN PortfolioCovidProject..WorldCovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Use CTE (Common Table Expression)
WITH PopVsVac (Conitnent, Location, Date,Population, NewVaccinationsOne, VaccinationsOneCumulative) as
	(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed,
		SUM(CONVERT(bigint,vac.new_people_vaccinated_smoothed)) OVER (PARTITION BY dea.location ORDER BY dea.date) as VaccinationsOneCumulative
	FROM PortfolioCovidProject..WorldCovidDeaths as dea
	JOIN PortfolioCovidProject..WorldCovidVaccinations as vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent is not null
	
	)
SELECT *, (VaccinationsOneCumulative/Population)*100 as VaccinationsOnePercentage --We can make use tables that already determined in cte to make new table
FROM PopVsVac ORDER BY 2,3


-- Use TEMP TABLE
IF OBJECT_ID('tempdb..##TemporaryTable') IS NOT NULL
DROP TABLE ##TemporaryTable
CREATE TABLE ##TemporaryTable 
	(Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	VaccinatedPeople numeric,
	VaccinationCumulative numeric,)

INSERT INTO ##TemporaryTable
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed,
	SUM(CONVERT(bigint,vac.new_people_vaccinated_smoothed)) OVER (PARTITION BY dea.location ORDER BY dea.date) as VaccinationsOneCumulative
FROM PortfolioCovidProject..WorldCovidDeaths as dea
JOIN PortfolioCovidProject..WorldCovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null

SELECT *, (VaccinationCumulative/Population)*100 as VaccinationPercentage 
FROM ##TemporaryTable
ORDER BY 2,3

-- CREATE VIEW TO SAVE DATA FOR VISUALIZATION
USE PortfolioCovidProject
GO
CREATE VIEW VaccinationPercentageTable as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed,
	SUM(CONVERT(bigint,vac.new_people_vaccinated_smoothed)) OVER (PARTITION BY dea.location ORDER BY dea.date) as VaccinationsOneCumulative,
	SUM(CONVERT(bigint,vac.new_people_vaccinated_smoothed)) OVER (PARTITION BY dea.location ORDER BY dea.date) / dea.population * 100 as VaccinationsOnePercentage
FROM PortfolioCovidProject..WorldCovidDeaths as dea
JOIN PortfolioCovidProject..WorldCovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
