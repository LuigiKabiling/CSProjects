/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/



--Overviewing the tables for Vaccinations & Deaths

SELECT *
FROM CSPROJECT..CovidVaccinations
ORDER BY 3,4

SELECT *
FROM CSPROJECT..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--Selecting the Column that we are going to need from CovidDeaths Table

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CSPROJECT..CovidDeaths
ORDER BY 1,2

--Total Cases vs Total Deaths
--This query shows the how likely you are to die (shown in percentage) if you contracted covid in US

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CSPROJECT..CovidDeaths
WHERE location like '%states%' AND continent IS NOT NULL
ORDER BY 1,2

--Total cases vs Total population
--This query shows the percentage of the total population that has contracted Covid.

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PopulationPerc
FROM CSPROJECT..CovidDeaths
WHERE location like '%states%' AND continent IS NOT NULL
ORDER BY 1,2

--Highest Infection Rates
--This query shows countries with highest infection rates compared to its population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectionRate
FROM CSPROJECT..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectionRate DESC

--Highest Death Counts Per Counrty compared to their population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount --'Total_Deaths' was formatted as 'NVARCHAR' 'CAST' was used to convert it to an INT 
FROM CSPROJECT..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Viewing continents Death Counts
--Showing continents with highest death count

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount --'Total_Deaths' was formatted as 'NVARCHAR' 'CAST' was used to convert it to an INT 
FROM CSPROJECT..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global covid cases and deaths per day

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage
FROM CSPROJECT..CovidDeaths
--WHERE location like '%states%' AND 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Sum of Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage
FROM CSPROJECT..CovidDeaths
--WHERE location like '%states%' AND 
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--Overviewig CovidVaccination table

SELECT *
FROM CSPROJECT..CovidVaccinations

--JOINING the CovidVaccination table and CovidDeath table

SELECT *
FROM CSPROJECT..CovidDeaths AS dea
JOIN CSPROJECT..CovidVaccinations AS vac
		ON dea.location = vac.location AND
		dea.date = vac.date

--Showing total population vs total vaccination per country

SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CSPROJECT..CovidDeaths AS dea
JOIN CSPROJECT..CovidVaccinations AS vac
		ON dea.location = vac.location AND
		dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Total population vs total vaccination with rolling vacination count

SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VaccinationRollingCount --CONVERT fucntion was used to convert 'vac.new_vaccinations' from being an NVARCHAR into an INTEGER
FROM CSPROJECT..CovidDeaths AS dea
JOIN CSPROJECT..CovidVaccinations AS vac
		ON dea.location = vac.location AND
		dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Number of people vaccinated in a country
--This query shows the number of people vaccinated in a country by dividing the VaccinationRollingCount to the country's population
--Method 1: Using Common Table Expressions (CTE)

WITH popvsvac (continent, location, date, population, new_vaccinations, VaccinationRollingCount)
AS
(
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VaccinationRollingCount --CONVERT fucntion was used to convert 'vac.new_vaccinations' from being an NVARCHAR into an INTEGER
FROM CSPROJECT..CovidDeaths AS dea
JOIN CSPROJECT..CovidVaccinations AS vac
		ON dea.location = vac.location AND
		dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT*, (VaccinationRollingCount/population)*100 AS #_of_people_vaccinated
FROM popvsvac

--Method 2: Using Temporary Tables

DROP TABLE IF EXISTS #percent_of_people_vaccinated
CREATE TABLE #percent_of_people_vaccinated
(
continent NVARCHAR (255),
location NVARCHAR (255),
date datetime,
population numeric,
new_vaccinations numeric,
VaccinationRollingCount numeric
)

INSERT INTO #percent_of_people_vaccinated
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VaccinationRollingCount --CONVERT fucntion was used to convert 'vac.new_vaccinations' from being an NVARCHAR into an INTEGER
FROM CSPROJECT..CovidDeaths AS dea
JOIN CSPROJECT..CovidVaccinations AS vac
		ON dea.location = vac.location AND
		dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT*, (VaccinationRollingCount/population)*100 AS #_of_people_vaccinated
FROM #percent_of_people_vaccinated

--Creating views for visualization
--View 1: %_of_people_vaccinated_ with rolling count

CREATE VIEW PercentofPeopleVaccinated AS
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VaccinationRollingCount --CONVERT fucntion was used to convert 'vac.new_vaccinations' from being an NVARCHAR into an INTEGER
FROM CSPROJECT..CovidDeaths AS dea
JOIN CSPROJECT..CovidVaccinations AS vac
		ON dea.location = vac.location AND
		dea.date = vac.date
WHERE dea.continent IS NOT NULL


--View 2: Sum of Global Numbers

CREATE VIEW Sum_of_Global_Numbers AS
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage
FROM CSPROJECT..CovidDeaths
--WHERE location like '%states%' AND 
WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY 1,2


--View 3: Highest Death Counts Per Counrty compared to their population

CREATE VIEW Death_Counts_Per_Counrty AS
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount --'Total_Deaths' was formatted as 'NVARCHAR' 'CAST' was used to convert it to an INT 
FROM CSPROJECT..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location
--ORDER BY TotalDeathCount DESC


--View 4: Total Cases vs Total Deaths
--This query shows the how likely you are to die (shown in percentage) if you contracted covid in US

CREATE VIEW TotalCaseVsTotalDeaths AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CSPROJECT..CovidDeaths
WHERE location like '%states%' AND continent IS NOT NULL
--ORDER BY 1,2

--View 5: Total cases vs Total population
--This query shows the percentage of the total population that has contracted Covid

CREATE VIEW TotalCaseVsTotalPopulation AS
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PopulationPerc
FROM CSPROJECT..CovidDeaths
WHERE location like '%states%' AND continent IS NOT NULL
--ORDER BY 1,2