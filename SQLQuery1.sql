
--- Covid 19 Data Exploration (Feb_22)  

-- Covid death database

SELECT *
FROM covid_case_study..covid_death
WHERE continent is not null 
ORDER BY 3,4

-- Vaccination database
SELECT *
FROM covid_case_study..covid_vaccinations
WHERE continent is not null 
ORDER BY 3,4

-- Select columns from covid death database

SELECT location,date,total_cases,new_cases, total_deaths, population
FROM covid_case_study..covid_death
WHERE continent is not null 
ORDER BY 1,2

-- Total Cases vs Total Deaths

SELECT location,date,total_cases,new_cases, total_deaths, population, (total_deaths/total_cases)*100 AS death_percentage_infected
FROM covid_case_study..covid_death
WHERE continent is not null 
ORDER BY 1,2 DESC

-- Total Cases vs Population (Shows what percentage of population infected with Covid)

SELECT location,date,total_cases, population,  (total_cases/population)*100 AS percent_population_infected
FROM covid_case_study..covid_death
WHERE continent is not null
ORDER BY 1,2 DESC


-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population)*100) AS percent_population_infected
FROM covid_case_study..covid_death
GROUP BY location, population
ORDER BY 4 DESC 

-- Countries with highest percentage death count as per Population

SELECT location, MAX(CAST (total_deaths AS INT)) AS highest_death_count, (MAX(CAST(total_deaths AS INT))/population)*100 AS percent_population_death
FROM covid_case_study..covid_death
WHERE continent is not null
GROUP BY location, population
ORDER BY  3 DESC 

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent , MAX (CAST (total_deaths AS INT)) AS total_deaths, MAX (new_cases) as total_infected
FROM covid_case_study..covid_death
WHERE continent is not NULL
GROUP BY continent
ORDER BY 2 DESC

-- Global numbers

SELECT MAX(total_cases) AS total_cases, MAX (CAST(total_deaths AS INT)) AS total_deaths , (MAX (CAST (total_deaths AS INT))/ SUM (population))* 100 AS percentage_of_the_world_infected
FROM covid_case_study..covid_death


-- Joining two tables

SELECT * 
FROM covid_case_study..covid_death join covid_case_study..covid_vaccinations
ON  covid_death.location = covid_vaccinations.location and covid_death.date = covid_vaccinations.date
ORDER BY covid_death.date DESC

-- Using Temp Table to perform Calculation on Partition

DROP TABLE IF exists #percentagepopulationvaccinated
CREATE TABLE #percentagepopulationvaccinated
(
continent nvarchar(225),
Location nvarchar(225),
Date datetime,
population numeric,
New_vaccinations numeric,
rolling_people_vaccinated  numeric
)

INSERT INTO #percentagepopulationvaccinated

SELECT covid_death.continent, covid_death.location, covid_death.date, population,covid_vaccinations.new_vaccinations,
SUM (CAST (covid_vaccinations.new_vaccinations AS NUMERIC)) OVER (PARTITION BY covid_death.location ORDER BY covid_death.location,covid_death.date) AS rolloing_people_vaccinated
FROM covid_case_study..covid_death join covid_case_study..covid_vaccinations
ON  covid_death.location = covid_vaccinations.location and covid_death.date = covid_vaccinations.date
WHERE covid_death.continent is not null
ORDER BY 2,3

-- Globel view 

SELECT *, (rolling_people_vaccinated/population)*100 AS total_vaccinated_percentage
From #percentagepopulationvaccinated
ORDER BY 1,2,3

-- creating view to store

CREATE VIEW percentagepopulationvaccinated AS
SELECT covid_death.continent, covid_death.location, covid_death.date, population,covid_vaccinations.new_vaccinations,
SUM (CAST (covid_vaccinations.new_vaccinations AS NUMERIC)) OVER (PARTITION BY covid_death.location ORDER BY covid_death.location,covid_death.date) AS rolloing_people_vaccinated
FROM covid_case_study..covid_death join covid_case_study..covid_vaccinations
ON  covid_death.location = covid_vaccinations.location and covid_death.date = covid_vaccinations.date
WHERE covid_death.continent is not null

SELECT  *
FROM percentagepopulationvaccinated