select * from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

-- shows likelihood of dyying if you contract covid

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%pak%'
and continent is not null
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid 

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where location like '%pak%'
and continent is not null
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 
as PercentPopulationInfected 
from PortfolioProject..CovidDeaths$
where continent is not null
Group by location, population
order by PercentPopulationInfected desc

--showing the countries with highest death count per population
 select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
 from PortfolioProject..CovidDeaths$
 where continent is not null
 group by location
 order by TotalDeathCount desc 

 --showing continents with the highest death count per population
 select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
 from PortfolioProject..CovidDeaths$
 where continent is not null
 group by continent
 order by TotalDeathCount desc

 --Global numbers
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100
as DeathPercentage from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--looking at total population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea 
join PortfolioProject..CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
from PercentPopulationVaccinated