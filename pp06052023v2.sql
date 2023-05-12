--Select	* 
--FROM pp1..CovidDeaths
--order by 3,4


-- looking at total cases vs total deaths
--shows likelihood of dying due to covid in my country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercent
From pp1..CovidDeaths
Where location like '%india%'
order by 1,2

--looking at the total cases vs the population
--shows percentage of covid 

select location, date, population, total_cases, (total_cases/population)*100 as covidpercentage
From pp1..CovidDeaths
--Where location like '%india%'
order by 1,2

--looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as highest_infection, max((total_cases/population))*100 as covidpercentage
From pp1..CovidDeaths
--Where location like '%india%'
group by location, population
order by covidpercentage DESC

--looking at countried with highest death count per population
	select location, max(cast(total_deaths as int)) as total_deathcount
	From pp1..CovidDeaths
	Where continent is not null
	group by location
	order by total_deathcount DESC


--lets break things up by continent
--showing the continents with the highest death count
select continent, max(cast(total_deaths as int)) as total_deathcount
	From pp1..CovidDeaths
	Where continent is not null
	group by continent
	order by total_deathcount DESC

--global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
From pp1..CovidDeaths
--Where location like '%india%'
Where continent is not null
--group by date
order by 1,2


--looking at total vaccination vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as 
rollingpeoplevaccinated
from pp1..CovidDeaths dea
join pp1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte 

With popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as 
rollingpeoplevaccinated
from pp1..CovidDeaths dea
join pp1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (rollingpeoplevaccinated/population)*100
FROM popvsvac

--temp table

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as 
rollingpeoplevaccinated
from pp1..CovidDeaths dea
join pp1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (rollingpeoplevaccinated/population)*100
From #percentpopulationvaccinated

--creating view to store data for later visulations


create view percentpopulationvaccinateds as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as 
rollingpeoplevaccinated
from pp1..CovidDeaths dea
join pp1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


