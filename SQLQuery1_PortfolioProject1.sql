SELECT *
FROM ProjectPortfolio..CovidDeaths
WHERE Continent is not null
order by 3,4

SELECT *
FROM ProjectPortfolio..CovidVaccinations
WHERE Continent is not null
order by 3,4

--Data we will be using for the Proect
SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM ProjectPortfolio..CovidDeaths
WHERE Continent is not null
ORDER BY 1,2

--This shows Total Cases VS Total Deaths
--Displays Percentage of US Population with Covid

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE Location like '%states%'
WHERE Continent is not null
ORDER BY 1,2

-- This shows countries with the Highest Infection Count as compared to Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM ProjectPortfolio..CovidDeaths
--WHERE Location like '%states%'
WHERE Continent is not null
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

--This shows countries with the Highest Death Count Per Population

SELECT Location, MAX(Cast(Total_deaths as int)) AS HighestDeathCount
FROM ProjectPortfolio..CovidDeaths
--WHERE Location like '%states%'
WHERE Continent is not null
GROUP BY Location
ORDER BY HighestDeathCount DESC

--CHECKING FOR INFORMATION ABOUT CONTINENTS

--This shows Continent with the Highest Death Count Per Population

SELECT Continent, MAX(Cast(Total_deaths as int)) AS HighestDeathCount
FROM ProjectPortfolio..CovidDeaths
--WHERE Location like '%states%'
WHERE Continent is not null
GROUP BY Continent
ORDER BY HighestDeathCount DESC

--GLOBAL INFO ON COVID

--This breaks things down daily across the globe

SELECT date, SUM(new_cases) as Total_Cases, SUM(Cast(new_deaths AS int)) as Total_Deaths, SUM(Cast(new_deaths AS int))/SUM(new_cases)* 100 AS DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE Continent is not null
--WHERE Location like '%States%'
GROUP BY date
ORDER BY 1,2

--This shows Total Population VS Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations, 
SUM(Cast(Vac.new_vaccinations AS int)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations Vac
     ON dea.location = Vac.location
	 AND dea.date = Vac.date
WHERE dea.continent is not null 
      --AND dea.Location like '%States%'
--GROUP BY dea.continent
ORDER BY 2,3

--USE CTE

WITH PopVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations, 
SUM(Cast(Vac.new_vaccinations AS int)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations Vac
     ON dea.location = Vac.location
	 AND dea.date = Vac.date
WHERE dea.continent is not null 
      --AND dea.Location like '%States%'
--GROUP BY dea.continent
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations, 
SUM(Cast(Vac.new_vaccinations AS int)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations Vac
     ON dea.location = Vac.location
	 AND dea.date = Vac.date
--WHERE dea.continent is not null 
--GROUP BY dea.continent
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating views for later Visualization in Tableau

CREATE VIEW PercentPopulationVaccinated
AS 
SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations, 
SUM(Cast(Vac.new_vaccinations AS int)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations Vac
     ON dea.location = Vac.location
	 AND dea.date = Vac.date
WHERE dea.continent is not null 
--GROUP BY dea.continent
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated

Create view GlobalNumbers
AS
SELECT date, SUM(new_cases) as Total_Cases, SUM(Cast(new_deaths AS int)) as Total_Deaths, SUM(Cast(new_deaths AS int))/SUM(new_cases)* 100 AS DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE Continent is not null
--WHERE Location like '%States%'
GROUP BY date
--ORDER BY 1,2

SELECT *
FROM GlobalNumbers



