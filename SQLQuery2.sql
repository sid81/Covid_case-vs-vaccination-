use PortfolioProject;


SELECT * from
PortfolioProject..CovidDeaths$
order by 3,4;




--1.select data that weare going to be using

select location,date,population,total_cases,total_deaths,new_cases
from 
PortfolioProject..CovidDeaths$
where location='india'
order by 2;

--2.Looking at total cases vs total deaths

select location,date,population,total_cases,total_deaths,new_cases,(total_deaths/total_cases)*100 as percentage_death
from 
PortfolioProject..CovidDeaths$
where location like '%indi%'
order by 1,2;

--3.Looking at cases worldwide

select location,max(total_cases) as max_cases,max((total_deaths)/total_cases)*100 as percentage_death
from 
PortfolioProject..CovidDeaths$
group by location
order by 1,2;


--3.Looking at max percentage death of india

select max((total_deaths)/total_cases)*100 as max_percentage_death
from 
PortfolioProject..CovidDeaths$
where location like '%india%';

--3.Looking at what percentage of population got covid

select location,date,population,total_cases,total_deaths,new_cases,(total_cases/population)*100 as got_covid
from 
PortfolioProject..CovidDeaths$
where location like '%united%'
order by 1,2;

select location,max((total_cases)/population)*100 as got_covid
from 
PortfolioProject..CovidDeaths$
group by location
order by 1,2;

--4. Looking at highest infection rate compared to population

select location,population,max(total_cases) as highinfectionCount,max((total_cases)/population)*100 as percentpopulaionInfected
from 
PortfolioProject..CovidDeaths$
where continent is not null
group by location,population
order by 4
desc;

--5. Showing countries with highest deathcount per population

select location,population,max(cast(total_deaths as int)) as TotalDeath ,max((cast(total_deaths as int))/population)*100 as deathperpopulation
from 
PortfolioProject..CovidDeaths$
where continent is not null
group by location,population
order by 3
desc;

select location,population,max(cast(total_deaths as int)) as TotalDeath ,max((cast(total_deaths as int))/population)*100 as deathperpopulation
from 
PortfolioProject..CovidDeaths$
where continent is not null
group by location,population
order by 4;

--6.Lets break things down by continent
  --showing continent with highest death count per population

select continent,location, max(cast(total_deaths as int)) as TotalDeath 
from 
PortfolioProject..CovidDeaths$
where continent is  null
group by continent,location
order by 3
desc;

--7.global data

select date,sum(new_cases) as newcaseworldwide,sum(cast(new_deaths as int)) as newdeathworldwide,
sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentnewday
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2;


select *
from PortfolioProject..CovidVaccination$
order by 3,4;

--8.looking at total population vs vaccination

with popvac(continent,location,date,population,new_vaccinations,rollinvaccinated)
as
(
select d.continent,d.location,d.date,d.population,v.new_vaccinations,sum(cast(v.new_vaccinations as int))
over(partition by d.location order by d.location,d.date) as rollinvaccinated
from PortfolioProject..CovidDeaths$ as d
join PortfolioProject..CovidVaccination$ as v
on d.location=v.location
and d.date=v.date
and d.location='india'
where d.continent is not null
)
select *,(rollinvaccinated/population)*50 as Population_covered
from
popvac;

--9.Temp table

drop table if exists #percentpeoplevaccinated
create Table #percentpeoplevaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rollinvaccinated numeric
);

insert into #percentpeoplevaccinated
select d.continent,d.location,d.date,d.population,v.new_vaccinations,sum(cast(v.new_vaccinations as bigint))
over(partition by d.location order by d.location,d.date) as rollinvaccinated
from PortfolioProject..CovidDeaths$ as d
join PortfolioProject..CovidVaccination$ as v
on d.location=v.location
and d.date=v.date;

select * from #percentpeoplevaccinated;

--10.Create view to store data for data visualization

create view percentpeoplevaccinated as
select d.continent,d.location,d.date,d.population,v.new_vaccinations,sum(cast(v.new_vaccinations as bigint))
over(partition by d.location order by d.location,d.date) as rollinvaccinated
from PortfolioProject..CovidDeaths$ as d
join PortfolioProject..CovidVaccination$ as v
on d.location=v.location
and d.date=v.date
where d.continent is not null;

select * from percentpeoplevaccinated;
