-- SELECT *
FROM covid_deaths
ORDER BY 3,4

-- SELECT *
FROM covid_vaccinations
ORDER BY 3,4

SELECT location, date, population, total_cases, new_cases, total_deaths
FROM covid_deaths

-- Looking at Total cases vs Total deaths
SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covid_deaths
WHERE date = (SELECT MAX(date)
FROM covid_deaths) 
ORDER BY death_percentage DESC

-- DEATH PERCENTAGES IN PAKISTAN
-- shows the likelihood of dying if you contract covid in PAKISTAN
SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covid_deaths
WHERE location = 'Pakistan' AND total_deaths IS NOT NULL

-- LOOKING AT TOTAL CASES BY. POPULATION
SELECT location, date, population, total_cases, total_deaths, (total_cases/population)*100 AS cases_per_population
FROM covid_deaths
WHERE date = (SELECT MAX(date) 
FROM covid_deaths) AND CONTINENT IS NOT NULL
ORDER BY cases_per_population DESC
LIMIT 20

--SELECT location,  population, MAX(total_cases), MAX((total_cases/population)*100) AS population_infected
--FROM covid_deaths
--GROUP BY location,population
--ORDER BY 4 DESC

-- CASES PER POPULATION IN PAKISTAN
-- shows what percentage of population of pak contracted covid
SELECT location, date, population, total_cases, total_deaths, (total_cases/population)*100 AS cases_per_population
FROM covid_deaths
WHERE location = 'Pakistan' AND total_cases IS NOT NULL
ORDER BY date DESC

-- LOOKING AT TOTAL deaths BY. POPULATION
SELECT * 
FROM (SELECT location, date, population, total_cases, total_deaths, (total_deaths/population)*100 AS deaths_per_population
FROM covid_deaths
WHERE date = (SELECT MAX(date) 
FROM covid_deaths) 
ORDER BY deaths_per_population DESC
) AS death_table
WHERE deaths_per_population IS NOT NULL
LIMIT 20

-- CHANGE A FIELD TYPE
--SELECT DISTINCT CAST(location AS varchar)
--FROM covid_deaths
--ORDER BY 1 

-- LET'S BREAK THINGS DOWN BY CONTINENTS
SELECT continent, SUM(total_cases) AS cases_sum, SUM(total_deaths) AS deaths_sum, SUM(population) AS total_population, COUNT(location) AS total_countries 
FROM
(SELECT *
FROM covid_deaths
WHERE date = (SELECT MAX(date) FROM covid_deaths) AND continent IS NOT NULL) AS latest_data
GROUP BY continent

-- Global Number
SELECT date, SUM(new_cases) AS new_cases_world, SUM(new_deaths) AS new_deaths_world
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1

-- total cases and deaths across the world
SELECT total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage 
FROM covid_deaths 
WHERE location='World' AND date = (SELECT MAX(date) FROM covid_deaths)



-- joining vaccination table with deaths table
SELECT *
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.date = v.date AND d.location = v.location
WHERE d.continent IS NOT NULL

-- DAILY VACCINATIONS FOR ALL THE COUNTRIES
SELECT d.date, d.continent, d.location, d.population, v.new_vaccinations
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.date = v.date AND d.location = v.location
WHERE d.continent IS NOT NULL AND v.new_vaccinations IS NOT NULL
ORDER BY 3,1

-- LOOKING AT TOTAL VACCINATIONS BY POPULATION
SELECT d.date, d.continent, d.location, d.population, 
	SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_sum
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.date = v.date AND d.location = v.location
WHERE d.continent IS NOT NULL AND v.new_vaccinations IS NOT NULL
ORDER BY 3,1


-- Using CTE to perform Calculation on Partition By in previous query
With PercentPopulationVaccinated (date,continent ,location , population ,rolling_sum)
AS 
(
SELECT d.date, d.continent, d.location, d.population, 
	SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_sum
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.date = v.date AND d.location = v.location
WHERE d.continent IS NOT NULL AND v.new_vaccinations IS NOT NULL
--ORDER BY 3,1
)

Select *, (rolling_sum/population)*100 AS vaccinated_per_pop
From PercentPopulationVaccinated


-- total people vaccinated for all the locations

Select location, MAX(rolling_sum), MAX((rolling_sum/population)*100 ) AS vaccinated_per_pop
From PercentPopulationVaccinated
GROUP BY location
ORDER BY 3 DESC



--- CREATE A VIEW FOR LATER VISUALIZATION

Create View PercentPopulationVaccinated as
SELECT d.date, d.continent, d.location, d.population, 
	SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_sum
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.date = v.date AND d.location = v.location
WHERE d.continent IS NOT NULL AND v.new_vaccinations IS NOT NULL




