Select *
From PortfolioProject..CovidDeadths$
Order by 3,4

--Total cases vs total deaths in Vietnam
Select location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 as death_rate
From PortfolioProject..CovidDeadths$
Where location= 'Vietnam'
Order by 1,2



--Total cases vs population in Vietnam
Select location, date, total_cases, population, (total_cases/population)*100 as infection_rate, (total_deaths/ total_cases)*100 as death_rate
From PortfolioProject..CovidDeadths$
Where location= 'Vietnam'
Order by 1,2

--Covid situation in Vietnam by time
Select location, date, total_cases, total_deaths, (total_cases/population)*100 as infection_rate
from PortfolioProject..CovidDeadths$
Where location = 'Vietnam'


--Looking at the countries with highest infection rate compared to population
Select location, population, max(total_cases) as highestinfectioncount, max((total_cases/population)*100) as infection_rate
From PortfolioProject..CovidDeadths$
group by location,population
order by infection_rate desc



--Looking at countries with highest death rate compared to population
Select top 20 location, max(cast(total_deaths as int)) as highestdeathcount, population, max((total_deaths/population)*100) as death_rate
From PortfolioProject..CovidDeadths$
group by location, population
order by death_rate desc



--Looking at continents
Select location, population, max(cast(total_deaths as int)) as highestdeathcount, max((total_deaths/population)*100) as death_rate
From PortfolioProject..CovidDeadths$
Where (continent is null) and location not like '%income%'
Group by location,population
Order by death_rate desc



--Death rate by income
Select location, population, max(cast(total_deaths as int)) as highestdeathcount, max((total_deaths/population)*100) as death_rate
From PortfolioProject..CovidDeadths$
Where (continent is null) and location like '%income%'
Group by location,population
Order by death_rate desc



-- Global numbers
Select location, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deadths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as death_rate
from PortfolioProject..CovidDeadths$
Where (location ='Vietnam' or location = 'World')
group by location



-- Total vacination vs population using CTE
With Vaccin as
(Select D.location,population, D.date, V.new_vaccinations, sum(cast(new_vaccinations as bigint))  over (Partition by D.location Order by D.location, D.date) as totalvaccinatedpeople
From PortfolioProject..CovidDeadths$ as D
Join PortfolioProject..CovidVaccination$ as V
on (D.location = V.location) and (D.date = V.date)
Where D.continent is not null)
--Order by 2,3

Select *, (totalvaccinatedpeople/population)*100
from Vaccin

-- Using temp table
Drop table if exists #Vaccinated_people
Create table #Vaccinated_people 
(
continent varchar(255),
location nvarchar(255),
population numeric,
date datetime,
new_vaccinations numeric,
totalvaccinatedpeople numeric
)

INSERT INTO #Vaccinated_people
Select D.continent, D.location,D.population, D.date, V.new_vaccinations, sum(cast(new_vaccinations as bigint))  over (Partition by D.location Order by D.location, D.date) as totalvaccinatedpeople
From PortfolioProject..CovidDeadths$ as D
Join PortfolioProject..CovidVaccination$ as V
on (D.location = V.location) and (D.date = V.date)
Where D.continent is not null
--Order by 2,3

Select *
from #Vaccinated_people

--Create Views
drop view if exists percentagepopulationvaccinated

Create View percentagepopulationvaccinated as

Select D.location,D.population,max(cast(people_fully_vaccinated as bigint)) as People_fully_vaccinated, (max(cast(people_fully_vaccinated as bigint))/D.population)*100 as Percent_People_fully_vaccinated
From PortfolioProject..CovidDeadths$ as D
Join PortfolioProject..CovidVaccination$ as V
on (D.location = V.location) and (D.date = V.date)
Where (D.location = 'World') or (D.location= 'Vietnam') or (D.location= 'Asia')
Group by D.location,D.population

Select * from percentagepopulationvaccinated
