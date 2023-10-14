/*

Covid 19 Data for Tableau Visualization

*/

--Tables used for Tableau Visualization 

SELECT dea.continent, dea.location, dea.date, dea.population, 
CONVERT (INT, dea.total_cases) AS totalCase, CONVERT (INT, dea.total_deaths) AS totalDeath, vac.total_vaccinations,vac.total_tests, 
(vac.total_vaccinations/dea.population)*100 AS perc_of_vaccinated_ppl
FROM CSPROJECT..CovidDeaths AS dea
JOIN CSPROJECT..CovidVaccinations AS vac
ON dea.location = vac.location AND
	dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 3

SELECT continent,location, date, new_tests,new_vaccinations,total_tests,total_vaccinations
FROM CSPROJECT..CovidVaccinations
ORDER BY 3
