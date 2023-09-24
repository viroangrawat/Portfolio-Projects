select * 
from PortfolioProject..CovidDeaths
order by location, date

--select * 
--from PortfolioProject..CovidVaccinations
--order by location, date

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by location, date 

--death percentage
select location, date, total_cases, total_deaths, round((CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100, 2) AS Deathpercentage
from PortfolioProject..CovidDeaths
where location = 'United States' and continent is not null
order by location, date 

--infection percentage
select location, max(CONVERT(float, total_cases)) as HighestCases, population, 
	Max(round((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100, 2)) AS InfectionPercentage
from PortfolioProject..CovidDeaths
--where location = 'United States'
where continent is not null
group by location, population
order by InfectionPercentage desc

--location with highest death count per population
select location, max(CONVERT(float, total_deaths)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location = 'United States'
where continent is not null
group by location
order by TotalDeathCount desc

--continent with highest death count per population
select continent, max(CONVERT(float, total_deaths)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location = 'United States'
where continent is not null
group by continent
order by TotalDeathCount desc

--gloabl numbers
select sum(convert(float, new_deaths)) as TotalDeaths, sum(new_cases) as TotalCases, 
	round((sum(convert(float, new_deaths)) / nullif(sum(new_cases), 0) *100), 2) as 'DeathPercentage'
from PortfolioProject..CovidDeaths
where continent is not null
--group by date 
order by TotalCases

--Population vs Vaccination
with popvsvac
as(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(float, v.new_vaccinations)) over(partition by d.location order by d.location, d.date) as RollingPopulationVaccianted 
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
on d.location = v.location and v.date = d.date
where d.continent is not null
--order by d.location, d.date
)
select *, round((RollingPopulationVaccianted / nullif(population, 0)) * 100, 3) as 'RollingPopulationVaccianted%' 
from popvsvac


--create view for visualizations
create view PercentPopulationVaccinated as 
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(float, v.new_vaccinations)) over(partition by d.location order by d.location, d.date) as RollingPopulationVaccianted 
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
on d.location = v.location and v.date = d.date
where d.continent is not null

