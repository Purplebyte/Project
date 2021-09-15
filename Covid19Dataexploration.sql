/*
Covid 19 Data Exploration
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From [portfolio project] ..coviddeath2
Where continent is not null 
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From [portfolio project] ..coviddeath2
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows possibility of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [portfolio project] ..coviddeath2
Where Location like 'India'
and continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From [portfolio project] ..coviddeath2
Where location like 'India'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [portfolio project] ..coviddeath2
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [portfolio project] ..coviddeath2
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- Shows contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [portfolio project] ..coviddeath2
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [portfolio project] ..coviddeath2
where continent is not null 
Group By date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [portfolio project] ..coviddeath2
where continent is not null 
--Group By date
order by 1,2

-- Total Population vs Vaccinations

Select Death.continent, Death.location, Death.date, Death.population, Vaccine.new_vaccinations
From [portfolio project] ..coviddeath2 Death
Join [portfolio project] ..covidvaccination2 Vaccine
	On Death.location = Vaccine.location
	and Death.date = Vaccine.date
where Death.continent is not null 
order by 2,3

-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select Death.continent, Death.location, Death.date, Death.population, Vaccine.new_vaccinations
,SUM(cast(Vaccine.new_vaccinations as bigint)) OVER (Partition by Death.Location Order by Death.location, Death.Date) as RollingPeopleVaccinated
From [portfolio project] ..coviddeath2 Death
Join [portfolio project] ..covidvaccination2 Vaccine
	On Death.location = Vaccine.location
	and Death.date = Vaccine.date
where Death.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, new_Vaccinations, RollingPeopleVaccinated)
as
(
Select Death.continent, Death.location, Death.date, Death.population, Vaccine.new_vaccinations
, SUM(Cast(Vaccine.new_vaccinations as bigint)) OVER (Partition by Death.Location Order by Death.location, Death.Date) as RollingPeopleVaccinated
From [portfolio project] ..coviddeath2 Death
Join [portfolio project] ..covidvaccination2 Vaccine
	On Death.location = Vaccine.location
	and Death.date = Vaccine.date
where Death.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentagePeopleVaccinated
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select Death.continent, Death.location, Death.date, Death.population, Vaccine.new_vaccinations
, SUM(Cast(Vaccine.new_vaccinations as bigint)) OVER (Partition by Death.Location Order by Death.location, Death.Date) as RollingPeopleVaccinated
From [portfolio project] ..coviddeath2 Death
Join [portfolio project] ..covidvaccination2 Vaccine
	On Death.location = Vaccine.location
	and Death.date = Vaccine.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
order by 2,3

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select Death.continent, Death.location, Death.date, Death.population, Vaccine.new_vaccinations
, SUM(Cast(Vaccine.new_vaccinations as bigint)) OVER (Partition by Death.Location Order by Death.location, Death.Date) as RollingPeopleVaccinated
From [portfolio project] ..coviddeath2 Death
Join [portfolio project] ..covidvaccination2 Vaccine
	On Death.location = Vaccine.location
	and Death.date = Vaccine.date
	where Death.continent is not null
