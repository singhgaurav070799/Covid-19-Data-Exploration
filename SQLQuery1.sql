use PortfolioProject

select * from  PortfolioProject..CovidDeaths$
where continent is not null
order by 3, 4;


select * from PortfolioProject..CovidVaccinations$
order by 3,4 

-- select data that we are going to be using 

select location, date , total_cases, new_cases, total_deaths, population
from  PortfolioProject..CovidDeaths$
order by 1,2


-- looking at total cases VS total deaths
-- looking a death percentage with country location 
select location, date , total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercantage
from PortfolioProject..CovidDeaths$
WHERE location like '%Ind%'
order by 1,2

--looking at total_cases vs population
-- shows what population got the covid
select location, date , total_cases, population, (total_cases/population) * 100 AS Percentagepopulationinfeted
from PortfolioProject..CovidDeaths$
--WHERE location like '%Ind%'
order by 1,2




--looking at a countries with highest infected rate compare to population
select location, population, MAX(total_cases) AS HighestInfectedCount, MAX((total_cases/population)) * 100 AS Percentagepopulationinfeted
from PortfolioProject..CovidDeaths$
--WHERE location like '%Ind%'
group by location, population
order by Percentagepopulationinfeted desc


--looking at a couteries with highest death  per population 

select location, MAX(cast(total_deaths as int)) AS totaldeathscount
from PortfolioProject..CovidDeaths$ 
--WHERE location like '%Ind%'
group by location
order by  totaldeathscount desc


--showing break things by  with contient

select continent, MAX(cast(total_deaths as int)) AS totaldeathscount
from PortfolioProject..CovidDeaths$ 
--WHERE location like '%Ind%'
where continent is  not  null
group by continent
order by  totaldeathscount desc


--showing global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%Ind%'
where continent is not null 
--Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select Death.continent, Death.location, Death.date, Death.population, vacci.new_vaccinations,
sum(cast(vacci.new_vaccinations as int)) over(partition by Death.location order by Death.location, Death.date) as Rollingpeoplevaccinated
from PortfolioProject..CovidDeaths$ As Death
join PortfolioProject..CovidVaccinations$ AS Vacci
on Death.location = Vacci.location and Death.date = vacci.date
where Death.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select Death.continent, Death.location, Death.date, Death.population, vacci.new_vaccinations,
sum(cast(vacci.new_vaccinations as int) ) over (partition by Death.location order by Death.location, Death.date) as Rollingpeoplevaccinated
from PortfolioProject..CovidDeaths$ As Death
join PortfolioProject..CovidVaccinations$ AS Vacci
on Death.location = Vacci.location and Death.date = vacci.date
where Death.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as UTERollingPeopleVaccinated
From PopvsVac




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
select Death.continent, Death.location, Death.date, Death.population, vacci.new_vaccinations,
sum(cast(vacci.new_vaccinations as int) ) over (partition by Death.location order by Death.location, Death.date) as Rollingpeoplevaccinated
from PortfolioProject..CovidDeaths$ As Death
join PortfolioProject..CovidVaccinations$ AS Vacci
on Death.location = Vacci.location and Death.date = vacci.date
where Death.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


create view PopulationVaccinated as
select Death.continent, Death.location, Death.date, Death.population, vacci.new_vaccinations,
sum(cast(vacci.new_vaccinations as int) ) over (partition by Death.location order by Death.location, Death.date) as Rollingpeoplevaccinated
from PortfolioProject..CovidDeaths$ As Death
join PortfolioProject..CovidVaccinations$ AS Vacci
on Death.location = Vacci.location and Death.date = vacci.date
where Death.continent is not null

