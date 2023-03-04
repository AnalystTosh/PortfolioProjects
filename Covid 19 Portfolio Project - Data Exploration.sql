/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

select * from CovidDeaths
where continent is not null
order by 3,4
--select * from CovidDeaths
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PorfolioProject..CovidDeaths
order by 1,2

-- Looking at Total cases vs Total Deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PorfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at Total case vs Total Population
-- Shows what percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PorfolioProject..CovidDeaths
where location like '%Kenya%'
Order by 1,2

-- Looking at countries with highest infection rate compare to population
select location, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
from PorfolioProject..CovidDeaths
-- where location like '%states%'
Group by population, location
order by PercentPopulationInfected desc


--Showing countries with the highest death count per population
select location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
from PorfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount Desc

-- Let's break things down by continent

-- Showing continents with the highest death count per population

select continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
from PorfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount Desc

-- Global Numbers
select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from PorfolioProject..CovidDeaths
where continent is not null
-- Group By date
order by 1, 2

select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from PorfolioProject..CovidDeaths
where continent is not null
Group By date
order by 1, 2

-- Looking at Total Population vs Vaccinations
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	SUM(CAST(vaccinations.new_vaccinations as int)) OVER (Partition by deaths.location order by deaths.location, deaths.date) as RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths deaths
Join PorfolioProject..CovidVaccinations vaccinations
	on deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
where deaths.continent is not null
order by 2,3

-- Create a CTE
WITH PopVsVac(continent,location, date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	SUM(CAST(vaccinations.new_vaccinations as int)) OVER (Partition by deaths.location order by deaths.location, deaths.date) as RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths deaths
Join PorfolioProject..CovidVaccinations vaccinations
	on deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
where deaths.continent is not null
-- order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100 as VaccinatedPercentage
from PopVsVac


-- Create Temp table

Drop Table if Exists #PercentPopVaccinated
Create Table #PercentPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated bigint
)
Insert into #PercentPopVaccinated
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	SUM(CAST(vaccinations.new_vaccinations as bigint)) OVER (Partition by deaths.location order by deaths.location, deaths.date) as RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths deaths
Join PorfolioProject..CovidVaccinations vaccinations
	on deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
--where deaths.continent is not null
-- order by 2,3
select *,(RollingPeopleVaccinated/population)*100 as VaccinatedPercentage
from #PercentPopVaccinated

-- Creating view to store data for later visualizations

Create view PercentPopulationVaccinated
as
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	SUM(CAST(vaccinations.new_vaccinations as bigint)) OVER (Partition by deaths.location order by deaths.location, deaths.date) as RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths deaths
Join PorfolioProject..CovidVaccinations vaccinations
	on deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
where deaths.continent is not null
-- order by 2,3
select *
from PercentPopulationVaccinated
