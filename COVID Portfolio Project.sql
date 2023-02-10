Select *
From PortfolioProject..CovidDeaths
order by 3,4


-- Select data that we are going to be using

Select Location, date, total_cases, new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2


-- Looking at Total cases vs Total Deaths
-- Shows the liklehood of dying if you contact covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeatPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentafe of population got covid

Select Location, date, total_cases, population, (total_cases/population)*100 as Percentpopulationinfected
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%states%'
Order by 1,2


-- Looking at countries with highest infection rate compared to population
--
Select Location, population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location, population
Order by PercentPopulationInfected desc


-- Showing Countires with highest death count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc


-- Let's break things down by continent


Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null
Group by location
Order by TotalDeathCount desc


-- Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


--Global numbers

Select  SUM(new_cases) Total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeatPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
Order by 1,2


-- Looking at total population vs vaccinations

Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.Location, 
  dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
Order by 2,3


-- Use CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(Convert(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.Location, 
  dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--Order by 2,3
)	
Select * , (RollingPeopleVaccinated/population)*100
From popvsvac


-- Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(Convert(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.Location, 
  dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--Order by 2,3

Select * , (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualization

Create view PercentPopulationVaccinated as 
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(Convert(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.Location, 
  dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--Order by 2,3

Select * 
From PercentPopulationVaccinated