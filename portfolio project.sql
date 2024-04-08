
 


SELECT  location, date, total_cases, new_cases, total_deaths,population 
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- looking at total_cases vs total_deaths
-- Shows the probabilty of dying if you contract COVID
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/ total_cases) *100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Nigeria%'
ORDER BY 1,2

--  At total cases vs population
-- Shows what percentage of population got covid 

SELECT location, date, population, total_cases, (total_cases/ population) *100 as Case_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Nigeria%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT location, population, max(total_cases) as HighestInfectionCount, max((total_cases/ population)) *100 as Case_Percentage
FROM PortfolioProject..CovidDeaths
WHERE  location like '%africa%' AND continent is not NULL
GROUP BY location,population
ORDER BY  Case_Percentage desc

-- Showing Countries with high death rate
SELECT location, max(cast(total_deaths as int)) as HighestDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathCount desc
 
 --showing continent with highest death rate per population
 SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathCount 
FROM PortfolioProject..CovidDeaths
 WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount desc

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as Total_cases, SUM(convert (int,new_deaths))as Total_deaths, 
SUM(convert(int, new_deaths)) / SUM(new_cases) * 100 as Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
-- GROUP BY date
ORDER BY 1,2


 --looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

 --Using CTE

  WITH PopvsVac (continent,location, date, population,new_vaccinations, RollingPeopleVaccinated)
  as
  (
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
 on dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
 --order by 2,3
  )
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM PopvsVac

--TEMP TABLE 

DROP TABLE IF EXISTS  #PercentPopulationVaccinated
CREATE TABLE   #PercentPopulationVaccinated 
( 
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
) 


INSERT INTO #PercentPopulationVaccinated 
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingpPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
 on dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
 --order by 2,3

 SELECT *, (RollingPeopleVaccinated/population)*100  
FROM #PercentPopulationVaccinated

--Creating View to store data for visualization

Create View PercentPopulationVaccination as 
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingpPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
 on dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
 --order by 2,3

 SELECT * 
 FROM PercentPopulationVaccination