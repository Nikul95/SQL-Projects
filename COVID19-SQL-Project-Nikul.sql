SELECT *
FROM NikulCOVID19PortfolioProject..COVIDDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM NikulCOVID19PortfolioProject..COVIDVaccinations
--ORDER BY 3,4

-- The first step in this project is to select the data that I will be using.

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM NikulCOVID19PortfolioProject..COVIDDeaths
WHERE continent is not null
ORDER BY 1,2

-- I will be looking at the Total Cases vs Total Deaths. 
--This shows the likelihood of dying if you contract COVID19 in the UK.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM NikulCOVID19PortfolioProject..COVIDDeaths
Where location like '%kingdom%'
and continent is not null
ORDER BY 1,2


-- I will now look at Total Cases vs Population 
-- This show what population of the country has gotten COVID19 in the UK.


SELECT location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
FROM NikulCOVID19PortfolioProject..COVIDDeaths
Where location like '%kingdom%'
and continent is not null
ORDER BY 1,2


-- I will now look at countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM NikulCOVID19PortfolioProject..COVIDDeaths
--Where location like '%kingdom%'and continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

-- I will now look at Countries with the Highest Death Count per Population

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM NikulCOVID19PortfolioProject..COVIDDeaths
--Where location like '%kingdom%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


-- I am now going to break things down by Continent


SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM NikulCOVID19PortfolioProject..COVIDDeaths
--Where location like '%kingdom%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc



-- I am now going to show GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM 
(new_cases)*100 as DeathPercentage
FROM NikulCOVID19PortfolioProject..COVIDDeaths
--Where location like '%kingdom%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM 
(new_cases)*100 as DeathPercentage
FROM NikulCOVID19PortfolioProject..COVIDDeaths
--Where location like '%kingdom%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- I have joined the COVIDDeaths and COVIDVaccinations tables together

SELECT *
FROM NikulCOVID19PortfolioProject..COVIDDeaths DEA
JOIN NikulCOVID19PortfolioProject..COVIDVaccinations VAC
    On DEA.location = VAC.location
	and DEA.date = VAC.date

-- I am now going to look at Total Population vs Vaccinations
SELECT DEA.continent, DEA.location, dea.date, dea.population, VAC.new_vaccinations
FROM NikulCOVID19PortfolioProject..COVIDDeaths DEA
JOIN NikulCOVID19PortfolioProject..COVIDVaccinations VAC
    On DEA.location = VAC.location
	and DEA.date = VAC.date
WHERE DEA.continent is not NULL
	ORDER BY 2,3


SELECT DEA.continent, DEA.location, dea.date, dea.population, VAC.new_vaccinations
, SUM(CAST(VAC.new_vaccinations as int)) OVER (Partition by DEA.location ORDER BY DEA.location,
DEA.date) as RollingPeopleVaccinated
FROM NikulCOVID19PortfolioProject..COVIDDeaths DEA
JOIN NikulCOVID19PortfolioProject..COVIDVaccinations VAC
    On DEA.location = VAC.location
	and DEA.date = VAC.date
WHERE DEA.continent is not NULL
ORDER BY 2,3

SELECT DEA.continent, DEA.location, dea.date, dea.population, VAC.new_vaccinations
, SUM(CONVERT(int,VAC.new_vaccinations)) OVER (Partition by DEA.location ORDER BY DEA.location,
DEA.date) as RollingPeopleVaccinated
FROM NikulCOVID19PortfolioProject..COVIDDeaths DEA
JOIN NikulCOVID19PortfolioProject..COVIDVaccinations VAC
    On DEA.location = VAC.location
	and DEA.date = VAC.date
WHERE DEA.continent is not NULL
ORDER BY 2,3


-- USE CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT DEA.continent, DEA.location, dea.date, dea.population, VAC.new_vaccinations
, SUM(CONVERT(int,VAC.new_vaccinations)) OVER (Partition by DEA.location ORDER BY DEA.location,
DEA.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM NikulCOVID19PortfolioProject..COVIDDeaths DEA
JOIN NikulCOVID19PortfolioProject..COVIDVaccinations VAC
    On DEA.location = VAC.location
	and DEA.date = VAC.date
WHERE DEA.continent is not NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac





-- CREATING A TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, dea.date, dea.population, VAC.new_vaccinations
, SUM(CONVERT(bigint,VAC.new_vaccinations)) OVER (Partition by DEA.location ORDER BY DEA.location,
  DEA.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM NikulCOVID19PortfolioProject..COVIDDeaths DEA
JOIN NikulCOVID19PortfolioProject..COVIDVaccinations VAC
    On DEA.location = VAC.location
	and DEA.date = VAC.date
--WHERE DEA.continent is not NULL
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated




-- Creating View to Store for Later Visualisations
CREATE VIEW PercentPopulationVaccinated as
SELECT DEA.continent, DEA.location, dea.date, dea.population, VAC.new_vaccinations
, SUM(CONVERT(bigint,VAC.new_vaccinations)) OVER (Partition by DEA.location ORDER BY DEA.location,
  DEA.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM NikulCOVID19PortfolioProject..COVIDDeaths DEA
JOIN NikulCOVID19PortfolioProject..COVIDVaccinations VAC
    On DEA.location = VAC.location
	and DEA.date = VAC.date
WHERE DEA.continent is not NULL
-- ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated