Select *
From PorfolioProject.dbo.CovidDeaths
Where continent is not null


--Select *
--from PorfolioProject.dbo.CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PorfolioProject.dbo.CovidDeaths
order by 1,2



--looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PorfolioProject.dbo.CovidDeaths
Where location like '%states%'
order by 1,2



--looking at the total cases vs population
--shows what percentage of population got covid

Select Location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
From PorfolioProject.dbo.CovidDeaths
Where location like '%states%'
order by 1,2



--looking at countries with highest infection rate compared to population
Select Location, population, sum(total_cases) as TotalInfectionCount, (sum(total_cases)/population) as PercentPopulationInfected
From PorfolioProject.dbo.CovidDeaths
Where continent is not null
Group by Location, population
order by PercentPopulationInfected desc


--last date of data
Select max(date)
From PorfolioProject.dbo.CovidDeaths
Where continent is not null



--showing countries with highest death count per population
Select Location, population, sum(cast(total_deaths as int)) as TotalDeathCount, (sum(cast(total_deaths as int)))/population*100 as PercentPopulationDeath
From PorfolioProject.dbo.CovidDeaths
Where continent is not null AND total_deaths is not null
Group by Location, population
order by PercentPopulationDeath desc


--break things down by continent
--showing continents with highest death count per population
Select continent, sum(population) as totalpopulation, sum(cast(total_deaths as int)) as TotalDeathCount, (sum(cast(total_deaths as int)))/sum(population)*100 as PercentPopulationDeath
From PorfolioProject.dbo.CovidDeaths
Where continent is not null AND total_deaths is not null
Group by continent
order by PercentPopulationDeath desc



--global numbers
Select date, sum(total_cases) as WTotalCases, sum(cast(total_deaths as int)) as WTotalDeaths, (sum(cast(total_deaths as int)))/(sum(total_cases))*100 as WDeathPercentage
From PorfolioProject.dbo.CovidDeaths
Where continent is not null
Group by date
order by 1



--looking at countries with total vaccinations
Select dea.continent, dea.location, sum(cast(vac.new_vaccinations as int)) as TotalVac
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null AND vac.new_vaccinations is not null
	Group by dea.location, dea.continent
	Order by 3


Select dea.continent, dea.date, dea.location, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null AND vac.new_vaccinations is not null
	Group by dea.location, dea.continent, dea.date, vac.new_vaccinations
	Order by 2, 3



-- population vs vaccinations (use CTE)
With PopvsVac AS
(Select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null AND vac.new_vaccinations is not null
	Group by dea.location, dea.continent, dea.date, vac.new_vaccinations, dea.population
)
Select location, date, (RollingPeopleVaccinated/population)*100 as PercentVac
From PopvsVac


-- population vs vaccinations (create table)
Drop table if exists #PercentPopulationVaccinated1
Create table #PercentPopulationVaccinated1
(continent nvarchar(255),
date datetime,
location nvarchar(255),
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated1

Select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null AND vac.new_vaccinations is not null
	Group by dea.location, dea.continent, dea.date, vac.new_vaccinations, dea.population

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated1


--view
Create View PercentPopulationVaccinated as
Select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null AND vac.new_vaccinations is not null
	Group by dea.location, dea.continent, dea.date, vac.new_vaccinations, dea.population