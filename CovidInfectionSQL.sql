
Select *
From Portofolio..CovidDeaths$
Where continent is not null
order by 3,4



Select location, date, total_cases,new_cases,total_deaths,population
From Portofolio..CovidDeaths$
order by 1,2



Select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From Portofolio..CovidDeaths$
Where location like '%Egypt%'
order by 1,2


Select location, date, total_cases,population,(total_cases/population)*100 as PopulationPercentage
From Portofolio..CovidDeaths$
Where location like '%Egypt%'
order by 1,2


Select location, population,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as PopulationPercentage
From Portofolio..CovidDeaths$
--Where location like '%Egypt%'
Group by location,population
order by PopulationPercentage desc



Select continent ,max(cast(total_deaths as int)) as TotalDeathCount
From Portofolio..CovidDeaths$
--Where location like '%Egypt%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


With PopVac(continent, location, date, population,new_vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(CONVERT( int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) 
as PeopleVaccinated
--, (PeopleVaccinated/population)*100
From Portofolio..CovidDeaths$ dea
join Portofolio..CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac. date
   Where dea.continent is not null
  -- order by 2,3 
)
Select *, (PeopleVaccinated/population)*100
From PopVac




DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(CONVERT( int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) 
as PeopleVaccinated
--, (PeopleVaccinated/population)*100
From Portofolio..CovidDeaths$ dea
join Portofolio..CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac. date
  --Where dea.continent is not null
  -- order by 2,3

Select *, (PeopleVaccinated/population)*100
From #PercentPopulationVaccinated








Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(CONVERT( int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) 
as PeopleVaccinated
--, (PeopleVaccinated/population)*100
From Portofolio..CovidDeaths$ dea
join Portofolio..CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac. date
  Where dea.continent is not null
 -- order by 2,3

 Select *
 From PercentPopulationVaccinated
