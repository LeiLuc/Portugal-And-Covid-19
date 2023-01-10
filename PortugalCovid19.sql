
-- Looking at the data to see if it imported properly from Excel

select *
from CovidDeaths

-- Taking a look at the data we need for Portugal
select Location, date, population, total_cases, new_cases, total_deaths
from CovidDeaths
where location = 'Portugal'

-- Death Percentage displays your chances of survival if you get covid in Portugal
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
where location = 'Portugal'
order by 1,2

-- This will display the percentage of the total Portugal population that got Covid
Select Location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
from CovidDeaths
where location = 'Portugal'

--- Portugal's Death rate vs its Infected rate of Total population
Select Location, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage, (total_cases/population)*100 as PopulationPercentage
from coviddeaths
where location = 'Portugal'
-- 0.45 died where as 54% of the total population had COVID

-- Displaying the peak DeathPercentage Portugal Suffered
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as Deathpercentage, (total_cases/population)*100 As PopulationPercentage 
from coviddeaths
where location = 'Portugal'
order by Deathpercentage DESC
-- June 2nd, 2020 Portugal suffered its highest DeathPercentage at 4.3%, but with 0.32 of the population contracting covid at the time

-- Portugals Cases by date
Select Location, date, (total_cases/population)*100 AS 'Case%' 
from coviddeaths
where location = 'Portugal'


-- Views for Cases by date in Portugal
Create View  CaseDatePOR AS
Select Location, date, (total_cases/population)*100 AS CasePer 
from coviddeaths
where location = 'Portugal'

-- GLOBAL STATS

--Highest Rates of infection vs population
Select Location, Population, MAX(total_cases) AS PeakCases, Max((total_cases/population)) * 100 as InfectedPercentage
From CovidDeaths
Group By Population, Location
Order by InfectedPercentage DESC


-- Countries that had the Highest Death Count per Population
Select Location, MAX(cast(total_deaths as bigint)) AS Deaths
From CovidDeaths
where continent is not null
Group By Location
Order by Deaths DESC

-- Global Numbers
Select SUM(New_cases) as TotalCases, SUM(CAST(new_deaths as bigint)) as TotalDeaths, SUM(cast(new_deaths as int))/Sum
(New_Cases)*100 as DeathPercentage
from COvidDeaths
where continent is not null
--Group By --date


-- The Date with highest death %
Select date, SUM(New_cases) as TotalCases, SUM(CAST(new_deaths as bigint)) as TotalDeaths, SUM(cast(new_deaths as int))/Sum
(New_Cases)*100 as DeathPercentage
from COvidDeaths
where continent is not null
Group By date
order by deathpercentage DESC

-- TEMP Table
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentpopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
SUM(Convert(bigint, vac.new_vaccinations)) over (Partition By deaths.location Order by deaths.location, deaths.date)  as RollingPeopleVaccinated
from coviddeaths deaths
Join Vaccines vac
	On deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null

Select*,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated






--- CTE
with PopvsVac (Continent, Location, Date, Population, RollingPeopleVaccinated, New_Vaccinations)
as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
SUM(Convert(bigint, vac.new_vaccinations)) over (Partition By deaths.location Order by deaths.location, deaths.date)  as RollingPeopleVaccinated
from coviddeaths deaths
Join Vaccines vac
	On deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- views for visualizations
Create View PercentPopulationVaccinated AS 
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
SUM(Convert(bigint, vac.new_vaccinations)) over (Partition By deaths.location Order by deaths.location, deaths.date)  as RollingPeopleVaccinated
from coviddeaths deaths
Join Vaccines vac
	On deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null