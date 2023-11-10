Select*
From PortfolioProject..CovidDeaths
order by 2,3,4

--Select*
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths,(cast(total_deaths as float)/total_cases)*100 AS DeatchPercentage, population
From PortfolioProject..CovidDeaths
WHERE location like 'Germany' 
AND continent is not null
ORDER BY 1,2

-- Total Cases vs Population

Select location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
WHERE location like 'Vietnam'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

Select location, population, Max(cast(total_cases as int)) AS HighestInfectionCount, MAX((total_cases)/population)*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
--WHERE location like 'Germany'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Countries with highest death count per population

Select location, MAX(cast(total_cases as int)) AS MaxTotalCases, Max(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE location like 'Germany'
WHERE continent is not null
GROUP BY location, population
ORDER BY totalDeathCount DESC

-- Now by continent, showing continent with the hightest death count

Select continent, MAX(cast(total_cases as int)) AS MaxTotalCases, Max(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE location like 'Germany'
WHERE continent is not null
GROUP BY continent
ORDER BY totalDeathCount DESC



-- Global numbers by date

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeatchPercentage
From PortfolioProject..CovidDeaths
--WHERE location like 'Germany' 
WHERE continent is not null and date Between '2020-01-19' and '2023-10-22'
GROUP BY date
ORDER BY 1,2

--global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeatchPercentage
From PortfolioProject..CovidDeaths
--WHERE location like 'Germany' 
WHERE continent is not null and date Between '2020-01-19' and '2023-10-22'
ORDER BY 1,2

-- total populatin vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(new_vaccinations as bigint)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as  dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3

--Using CTE to display Population vs Vaccinated

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(new_vaccinations as bigint)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as  dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null and dea.location='Germany'
--ORDER BY 2,3
)
SELECT*,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- Percentage People Vaccinated per Country

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(new_vaccinations as bigint)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as  dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3
)
SELECT Continent, Location, Population, (MAX(RollingPeopleVaccinated)/Population)*100 as PercentageVaccinated
FROM PopvsVac
GROUP BY Location, Continent, Population
ORDER BY Continent

--Using Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(new_vaccinations as bigint)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as  dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3

SELECT Continent, Location, Population, (MAX(RollingPeopleVaccinated)/Population)*100 as PercentageVaccinated
FROM #PercentPopulationVaccinated
GROUP BY Location, Continent, Population
ORDER BY Continent

