-- GLOBAL TOTAL CASES & TOTAL DEATHS
SELECT SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths, SUM(CAST(new_deaths as int)) / SUM(new_cases) * 100 as Death_Percentage
FROM PortfolioCovidProject..WorldCovidDeaths

-- GLOBAL TOTAL DEATHS PER CONTINENTS
SELECT location as Continent, SUM(CAST(new_deaths as int)) as Total_Deaths
FROM PortfolioCovidProject..WorldCovidDeaths
WHERE continent is null AND location not in ('World', 'European Union', 'International', 'Low income', 'High income', 'Upper middle income', 'Lower middle income')
GROUP BY location
ORDER BY Total_Deaths DESC

-- CASE PERCENTAGE PER COUNTRY
SELECT location as Country, population as Population, MAX(total_cases) as Total_Infected, MAX(total_cases) / population * 100 as Infected_Percentage
FROM PortfolioCovidProject..WorldCovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Infected_Percentage DESC

-- DAILY CASE PERCENTAGE PER COUNTRY 
SELECT location as Country, population, date as Date, MAX(total_cases) as Total_Infected, MAX(total_cases) / population * 100 as Infected_Percentage
FROM PortfolioCovidProject..WorldCovidDeaths
WHERE continent is not null
GROUP BY location, population, date
ORDER BY country, Infected_Percentage DESC