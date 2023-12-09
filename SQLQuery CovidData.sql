SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--WHERE continent is not null
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying of you contract covid in your country

SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%nigeria%'
and continent is not null
order by 1,2

--Total Cases vs Population

SELECT Location, date, population, total_cases,(total_cases/population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
 FROM PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by  Location, population
Order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population



SELECT Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
 FROM PortfolioProject..CovidDeaths
where continent is not null
Group by Location
Order by TotalDeathCount desc

--LETS BREAK THIS DOWN BY CONTINENT

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
 FROM PortfolioProject..CovidDeaths
where continent is null
Group by location
Order by TotalDeathCount desc

--Showing the continents with the highest death count

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
 FROM PortfolioProject..CovidDeaths
 --where location like '%states%'
where continent is not null
Group by continent
Order by TotalDeathCount desc

--GLOBAL NUMBERS

SELECT date, SUM(new_cases)as Total_Cases, SUM(cast(new_deaths as int))as Total_Deaths, SUM(cast(New_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
Group by date
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeoplevaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 2,3

  --USE CTE

with PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
  as 
  (
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3
  )
  Select *, (RollingPeopleVaccinated/Population)*100
  From PopvsVac


  --TEMP TABLE
  DROP Table if exists #PercentPopulationVaccinated
  Create Table #PercentPopulationVaccinated
  (
  Continent nvarchar(255),
  Location nvarchar(255),
  Data datetime,
  Population numeric,
  New_Vaccination numeric,
  RollingPeopleVaccinated numeric
  )

  Insert into #PercentPopulationVaccinated
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3
  
  Select *, (RollingPeopleVaccinated/Population)*100
  From #PercentPopulationVaccinated

  --Creating view to store data for data visualisations
 


CREATE VIEW 

PercentPopulationVaccinated as
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3
  
  Select* 
  From PercentPopulationVaccinated
  