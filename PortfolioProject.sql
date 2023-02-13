SELECT * FROM PortfolioProjects..CovidDeaths
WHERE continent is not null
ORDER BY 3,4;

--SELECT * FROM PortfolioProjects..CovidVaccinations
--ORDER BY 3,4;

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..CovidDeaths
WHERE continent is not null
ORDER BY 1,2;

-- Looking at Total Cases Vs Total Deaths
-- Shows likelihood of dying if you contract covid-19 in your country

SELECT Location, date, total_cases, total_deaths, (Total_deaths/total_cases)* 100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
ORDER BY 1,2;


-- Looking at Total Cases Vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, Population, total_cases, (total_cases/population)* 100 AS PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
ORDER BY 1,2;

-- Looking at country with highest infection rate compared to population

SELECT Location, Population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))* 100 AS PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;

-- Showing Countries with the Highest Death Count per Population

SELECT Location, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM PortfolioProjects..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY Location
ORDER BY Total_Death_Count DESC;

-- Let's break things down by continent


-- showing the continents with the highest death count

SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM PortfolioProjects..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is null
GROUP BY location
ORDER BY Total_Death_Count DESC;


-- Global NUMBERS

SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage --, total_deaths, (Total_deaths/total_cases)* 100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

-- Looking at Total Population Vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
(RollingPeopleVaccinated/population) *100
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;


--- USE CTE

WITH PopvsVac (Continent, Location, Date, Population,New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated;


-- Creating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) *100
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3;