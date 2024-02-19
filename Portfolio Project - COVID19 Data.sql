Select * 
FROM PortfolioProjects..CovidDeaths$
where continent is not null
ORDER BY 3,4

--Select * 
--FROM PortfolioProjects..CovidVaccinations$
--ORDER BY 3,4

--Select Data we're going to be using
Select Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..CovidDeaths$
Order By 1,2

--Looking at total cases vs total deaths.
Select Location, Date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths$
Where Location = 'Nigeria'
Order By 1,2

--Looking at total cases vs population, to show % of population infected with COVID.
Select Location, Date, population, total_cases, (total_cases/population)*100 as InfectionRate
FROM PortfolioProjects..CovidDeaths$
Where Location = 'Nigeria'
Order By 1,2

--Looking at countries with highest infection rate compared to population.
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as HighestInfectionRate
FROM PortfolioProjects..CovidDeaths$
where continent is not null
Group By location, population
Order By HighestInfectionRate desc

--Showing countries with highest death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths$
where continent is not null
Group By location
Order By TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--showing continents with highest death count.
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths$
where continent is null and location in ('Africa', 'Asia', 'North America', 'South America', 'Oceania', 'Europe')
Group By location
Order By TotalDeathCount desc

--Global numbers
select date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths$
where continent is not null
group by date
order by 1,2

--looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths$ as dea
Join PortfolioProjects..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE
With PopvsVac (Continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths$ as dea
Join PortfolioProjects..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--Use Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths$ as dea
Join PortfolioProjects..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating view to store data for later visualizations
Create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths$ as dea
Join PortfolioProjects..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

