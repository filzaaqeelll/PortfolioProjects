SELECT *
FROM portfolio..CovidDeaths$
ORDER BY 3,4;


SELECT Location, date, total_cases,new_cases,total_deaths,population
FROM portfolio..CovidDeaths$
where continent is not null
ORDER BY 1,2;


--Looking at  Total Cases Vs Total Deaths
--Likelihood of dying if you contract covid in a particular country

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as  Death_Percentage
FROM portfolio..CovidDeaths$
WHERE Location like '%pakistan%'
ORDER BY 1,2;

--Looking at  Total Cases Vs Population
--What percentage of population got covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as  case_percentage
FROM portfolio..CovidDeaths$
--WHERE Location like '%pakistan%'
ORDER BY 1,2;


--Looking at Countries with Highest Infection Rate compared to Population
SELECT location,max(total_cases) as highestInfectionCount, population, max((total_cases/population)*100) as  case_percentage
FROM portfolio..CovidDeaths$
Group by location, Population
order by case_percentage desc



--Showing Countries with Highest Death Count per Population
SELECT location,max(cast(total_deaths as int)) as highestDeathCount
FROM portfolio..CovidDeaths$
where continent is not null
Group by location
order by highestDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT
--Showing continents with the highest death count per population

SELECT continent,max(cast(total_deaths as int)) as highestDeathCount
FROM portfolio..CovidDeaths$
where continent is not null
Group by continent
order by highestDeathCount desc

-- Global numbers
SELECT  date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases), 0)*100 as new_death_percentage
FROM portfolio..CovidDeaths$
Group by date
ORDER BY 1,2;


-- Looking at total population vs vaccinations

Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) OVER (Partition by d.location order by d.location, d.date) as running_vaccination_count
from portfolio..CovidDeaths$ as d
Join portfolio..CovidVaccinations$ as v
on d.location = v.location
and d.date=v.date


-- USE CTE

with PopvsVAC (Continent, location, date, population,new_vaccinations,running_vaccination_count)
as(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) OVER (Partition by d.location order by d.location, d.date) as running_vaccination_count
from portfolio..CovidDeaths$ as d
Join portfolio..CovidVaccinations$ as v
on d.location = v.location
and d.date=v.date
where d.continent is not null
)
Select*, (running_vaccination_count/population)*100 as VacPerPop
From PopvsVAC


--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population Numeric,
new_vaccinations numeric,
running_vaccination_count numeric

)
Insert into #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) OVER (Partition by d.location order by d.location, d.date) as running_vaccination_count
from portfolio..CovidDeaths$ as d
Join portfolio..CovidVaccinations$ as v
on d.location = v.location
and d.date=v.date

Select*, (running_vaccination_count/population)*100 as VacPerPop
From #PercentPopulationVaccinated


-- Creating view to store data for later visualization
Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) OVER (Partition by d.location order by d.location, d.date) as running_vaccination_count
from portfolio..CovidDeaths$ as d
Join portfolio..CovidVaccinations$ as v
on d.location = v.location
and d.date=v.date
where d.continent is not null

Select*
From PercentPopulationVaccinated