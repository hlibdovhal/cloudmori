SELECT *
FROM CovidDeaths$
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations$
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths$
WHERE Location like 'Slovakia' and continent is not null
ORDER BY 1,2


SELECT Location, date, Population, total_cases, new_cases,total_deaths, (total_cases/population)*100 as ChanceToBeInfected
FROM CovidDeaths$
WHERE continent is not null
--WHERE Location like 'Slovakia'
ORDER BY 1,2

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
FROM CovidDeaths$
WHERE continent is not null
GROUP BY Location, Population 
ORDER BY PercentPopulationInfected desc
 

 SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(New_Cases)*100 as DeathPrecentage
FROM CovidDeaths$
where continent is not null
order by 1,2 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
From CovidDeaths$ dea
Join CovidVaccinations$ vac
On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3 

With PopvsVac (Continent,Location,Date,Population, New_Vaccinations, RollingPeopleVaccinated)
as
( SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
From CovidDeaths$ dea
Join CovidVaccinations$ vac
On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
SELECT *, ( RollingPeopleVaccinated/Population)*100
FROM PopvsVac


DROP Table if exists #PercentPopulationVaccinated
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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
From CovidDeaths$ dea
Join CovidVaccinations$ vac
On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

SELECT *, ( RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later vizualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
From CovidDeaths$ dea
Join CovidVaccinations$ vac
On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3 


SELECT *
From PercentPopulationVaccinated