-- Select Data whta I am going to be using
SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths 
ORDER BY 1,2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Spain
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths 
WHERE location like '%spain%' AND continent is not null 
ORDER BY 2;
 
 
 -- Total Cases vs Population
 -- Show what percentage of population infected with COvid
SELECT Location, Date, total_cases, population, (total_deaths/population)*100 AS PercentPopulationInfected
FROM CovidDeaths 
-- WHERE location like '%spain%'
ORDER BY 2;


-- Contries with Highest Infection Rate compared to Population
SELECT Date, Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM CovidDeaths 
WHERE continent is not null 
GROUP BY Location, population
ORDER BY PercentagePopulationInfected DESC;


-- Countries with Highest Death Count per Population
SELECT Date, Location, MAX(CAST(total_deaths as int)) AS TotalDethsCount
FROM CovidDeaths 
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDethsCount DESC;


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population
SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths as int)) AS total_deaths, 
	   SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths 
WHERE continent is not null
ORDER BY 1,2;


-- Total Population vs Vaccinations
-- Shows percentage of population that has recieved at least one Covid Vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	   SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac ON dea.location = vac.location
						   AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3


-- Using CTE to perfom Calculation on Partition By in previous query
WITH PopvsVac (continent, loacation, date, population, new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	   SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac ON dea.location = vac.location
						   AND dea.date = vac.date
WHERE dea.continent is not null 
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query
DROP TABLE if exists #PercentPopulationVaccinated
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
	   SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac ON dea.location = vac.location
                           AND dea.date = vac.date
-- where dea.continent is not null 
-- order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac ON dea.location = vac.location
						   AND dea.date = vac.date
WHERE dea.continent is not null 

