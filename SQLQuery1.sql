SELECT * FROM dbo.[CovidDeaths$]
WHERE continent IS NOT NULL
ORDER BY 3, 4

--SELECT * FROM dbo.[CovidVaccinations$]
--ORDER BY 1, 2 

--Select data that we are going to be using

SELECT location, date, population, total_cases, new_cases, total_deaths 
FROM dbo.[CovidDeaths$]
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Looking at total deaths and total cases
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS percentagepopulationinfected
FROM dbo.[CovidDeaths$]
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1, 2

-- Looking at total cases and population
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, population, (total_cases/population)*100 AS casespercentage
FROM dbo.[CovidDeaths$]
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1, 2

--Looking at countries with hightest infection rate compared to population
SELECT location, MAX(total_cases) AS highestinfectioncount, population, MAX(total_cases/population)*100 AS percentagepopulationinfected
FROM dbo.[CovidDeaths$]
--WHERE location LIKE '%states%'
GROUP BY location, population
WHERE continent IS NOT NULL
ORDER BY percentagepopulationinfected DESC

--Showing countries with highest death count per population
 SELECT location, MAX(CAST(total_deaths AS INT)) AS totaldeathcount
FROM dbo.[CovidDeaths$]
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY totaldeathcount DESC

--Let's break thing down by continent
 SELECT location, MAX(CAST(total_deaths AS INT)) AS totaldeathcount
FROM dbo.[CovidDeaths$]
--WHERE location LIKE '%states%'
WHERE continent IS NULL
GROUP BY location
ORDER BY totaldeathcount DESC

--Showing the continent with the highest desath count per population
 SELECT continent, MAX(CAST(total_deaths AS INT)) AS totaldeathcount
FROM dbo.[CovidDeaths$]
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totaldeathcount DESC

--Global number
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS deathpercentage
FROM dbo.[CovidDeaths$]
WHERE continent IS NOT NULL

--Looking at total population vs vaccinations
WITH popvsvac (continent, location, date, population, new_vaccinatins, rollingpoplevaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpoplevaccinated
FROM dbo.[CovidDeaths$] dea
JOIN dbo.[CovidVaccinations$] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--GROUP BY 2, 3
)
SELECT *, (popvsvac.rollingpoplevaccinated/popvsvac.population)*100
FROM popvsvac

--TEMP TABLE

DROP TABLE PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATE,
Population NUMERIC,
New_vaccinations NUMERIC,
Rollingpeoplevaccinated NUMERIC
)
INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rollingpoplevaccinated
FROM dbo.[CovidDeaths$] dea
JOIN dbo.[CovidVaccinations$] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--GROUP BY 2, 3
SELECT *, (Rollingpeoplevaccinated/Population)*100
FROM PercentPopulationVaccinated


--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rollingpoplevaccinated
FROM dbo.[CovidDeaths$] dea
JOIN dbo.[CovidVaccinations$] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--GROUP BY 2, 3
