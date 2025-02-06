select *
from Portofolio..CovidDeaths$
where continent is not null
order by 3,4

--select *
--From Portofolio..CovidVaccinations$
--order by 3,4

--select data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from Portofolio..CovidDeaths$
where continent is not null
Order by 1,2


--looking at total cases vs total death ( to look for the percentage of how many died from the case)
select Location, date,population, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from Portofolio..CovidDeaths$
where location like '%indonesia%'
order by 1,2

--looking at the total case vs population
select Location, date, total_cases, population, (population/total_cases)*100 as casepersentage
from Portofolio..CovidDeaths$
where location like '%indonesia%'
order by 1,2

--looking for the country with highest infection rate compared to population
select location, population, MAX(total_cases) as highestinfectioncount, Max((total_cases/population))*100 as percentinfectedpopulation
From Portofolio..CovidDeaths$
where continent is not null
group by location, population
order by percentinfectedpopulation desc

--showing countries with hihgest death count per population 
select location, population, MAX(cast(total_deaths as int)) as highestdeathcount, Max((total_deaths/population))*100 as percentdeathpopulation
From Portofolio..CovidDeaths$
where continent is not null
group by location, population
order by highestdeathcount desc

--showing continent with highest death count perpopulation
select continent, MAX(cast(total_deaths as int)) as highestdeathcount
From Portofolio..CovidDeaths$
where continent is not null
group by continent
order by highestdeathcount desc

--showing total death on each continent caused by covid(this has better accuration 
select location, MAX(cast(total_deaths as int)) as highestdeathcount
From Portofolio..CovidDeaths$
where continent is null
group by location
order by highestdeathcount desc

--global numbers
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
from Portofolio..CovidDeaths$ 
--where location like '%indonesia%'
where continent is not null
group by date
order by 1,2

--total cases with death percentage
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
from Portofolio..CovidDeaths$ 
--where location like '%indonesia%'
where continent is not null
order by 1,2

--join two table
select*
from Portofolio..CovidDeaths$ dea
join Portofolio..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date

--looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/dea.population)*100
from Portofolio..CovidDeaths$ dea
join Portofolio..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE
with PopvsVac (Continent, location, date, population,new_vaccination, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/dea.population)*100
from Portofolio..CovidDeaths$ dea
join Portofolio..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from PopvsVac



--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_Vaccinations numeric,
rollingpeoplevaccinated numeric,
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/dea.population)*100
from Portofolio..CovidDeaths$ dea
join Portofolio..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated


--creating view to store data for visualizations
create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/dea.population)*100
from Portofolio..CovidDeaths$ dea
join Portofolio..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from percentpopulationvaccinated