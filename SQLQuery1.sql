select *
from PortfolioProject..[covid-deaths]
where continent is not null 
order by 3,4

--select *
--from PortfolioProject..[covid-vaccinations]
--order by 3,4

--select data that we are going to be using 

select location, date, total_cases_per_million, new_cases, total_deaths, population 
from PortfolioProject..[covid-deaths]
where continent is not null 
order by 1,2

-- looking at total cases VS total deaths

select location, date, total_cases_per_million, total_deaths
from PortfolioProject..[covid-deaths]
where location like '%norway%'
and continent is not null 
order by 1,2
 
 -- looking at tottal cases VS population
 -- show what percentage of population got covid
select location, date, population, total_cases_per_million, (total_cases_per_million/population)*100 as PercentPopulationInfected 
from PortfolioProject..[covid-deaths]
where location like '%france%'
and continent is not null 
order by 1,2

--  looking at countries with highest infection  rate comparing to population

select location, population, MAX(total_cases_per_million) as HighestInfecionCount, Max((total_cases_per_million/population))*100 as PercentPopulationInfected
from PortfolioProject..[covid-deaths]
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

-- showing countries with highest death count per population 

select location, MAX(total_deaths) as HighestDeathCount, Max((total_deaths/population))*100 as DeathPercent
from PortfolioProject..[covid-deaths]
--where location like '%states%'
where continent is not null 
group by location, total_deaths
order by DeathPercent desc

-- by breaking things down by continent

select continent, MAX(cast(total_deaths as int)) as HighestDeathCount, Max((total_deaths/population))*100 as DeathPercent
from PortfolioProject..[covid-deaths]
--where location like '%north america%'
where continent is not null 
group by continent
order by HighestDeathCount desc

--Global Number 

select  date, SUM(new_cases) as total_cases, Sum(new_deaths) as total_deaths
from PortfolioProject..[covid-deaths]
--where location like '%norway%'
where continent is not null 
group by date
order by 1,2

--looking at life expectancy of total population

select dea.continent, dea.location, dea.date, dea.population, vac.life_expectancy, 
Sum(CONVERT(int, vac.life_expectancy)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingLifeExpectancy
from PortfolioProject..[covid-deaths] dea
join PortfolioProject..[covid-vaccinations] vac 
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
order by 2,3



--  Use CTE

With PopVSLE (continent, location, date, population,life_expectancy, RollingLifeExpectancy)
as  
(
select dea.continent, dea.location, dea.date, dea.population, vac.life_expectancy, 
Sum(CONVERT(int, vac.life_expectancy)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingLifeExpectancy
from PortfolioProject..[covid-deaths] dea
join PortfolioProject..[covid-vaccinations] vac 
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3
)
select*, (RollingLifeExpectancy/population)*100
from PopVSLE



-- temp table

drop table if exists #percentpeoplelifeexpectance
Create table percentpeoplelifeexpectance
(
location nvarchar(255),
continent nvarchar(255),
date datetime,
population numeric,
life_expectancy numeric,
RollingLifeExpectancy numeric

)
insert into percentpeoplelifeexpectance
select dea.continent, dea.location, dea.date, dea.population, vac.life_expectancy, 
Sum(CONVERT(int, vac.life_expectancy)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingLifeExpectancy
from PortfolioProject..[covid-deaths] dea
join PortfolioProject..[covid-vaccinations] vac 
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3


select*, (RollingLifeExpectancy/population)*100
from percentpeoplelifeexpectance


-- creating view to store data for later visualizations 
create view percentpeoplelifeexpectancy1 as 
select dea.continent, dea.location, dea.date, dea.population, vac.life_expectancy, 
Sum(CONVERT(int, vac.life_expectancy)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingLifeExpectancy
from PortfolioProject..[covid-deaths] dea
join PortfolioProject..[covid-vaccinations] vac 
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3


select *
from percentpeoplevaccination