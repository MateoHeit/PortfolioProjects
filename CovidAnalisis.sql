Select *
from PortfolioProject. .CovidDeaths;

-- ELIMINO REGISTROS DE LA COLUMNA TOTAL_CASES QUE NO SEAN NUMEROS
Delete From PortfolioProject. .CovidDeaths
Where total_cases  LIKE '%[a-z]' OR total_cases is null;

-- ELIMINO REGISTROS DE LA COLUMNA total_deaths QUE NO SEAN NUMEROS
Delete From PortfolioProject. .CovidDeaths
WHERE total_deaths  LIKE '%[a-z]' OR total_deaths is null;

-- ELIMINO REGISTROS DE LA COLUMNA location QUE NO SEAN strings
Delete From PortfolioProject. .CovidDeaths
Where location NOT LIKE '%[a-z]';



-- EXPLORACION DE DATOS --

--CANTIDAD MAXIMA DE MUERTES POR LOCALIDAD
SELECT location, max(total_deaths) as max_deaths
FROM PortfolioProject. .CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY max_deaths desc



-- PORCENTAJE DE MUERTES POR LOCALIDAD (Estados Unidos) Y FECHA 
--Probabilidad de morir por COVID segun localidad
Select  location, date,  total_cases, total_deaths,	Round((total_deaths / total_cases)*100, 1) as '%deaths'
From PortfolioProject. .CovidDeaths
Where location = 'United States'
and continent is not null



-- CASOS TOTALES VS POBLACIÓN

Select  location, date, population, total_cases, ROUND((total_cases / population)*100, 5) as '%Infections'
From PortfolioProject. .CovidDeaths
Where location = 'United States'
and continent is not null



-- LOCALIDAD CON LA MAYOR TASA DE CONTAGIOS

Select  location, max(total_cases) as NumMaxContagios, population, Max(Round((total_cases / population)*100, 5)) as PercentInfect
From PortfolioProject. .CovidDeaths
Where continent Is Not Null
Group By location, population
Order By  PercentInfect Desc



-- LOCALIDAD CON MAYOR TASA DE MUERTES


Select  location, max(total_deaths) as NumMaxMuertes, population, Max(Round((total_deaths / population)*100, 5)) AS PercentDeaths
From PortfolioProject. .CovidDeaths
where continent is not null
Group by location, population
Order by  PercentDeaths Desc


-- CANTIDAD MAXIMA DE MUERTES POR CONTINENTE
Select continent, Max(total_deaths) as max_deaths
From PortfolioProject. .CovidDeaths
Where continent Is Not Null
Group by continent
Order by max_deaths Desc




-- NUMEROS GLOBALES
-- Fecha en la que se alcanza la mayor tasa de mortalidad en el periodo comprendido

Select  date,  sum(total_cases) as SumCasos, Sum(total_deaths) as SumMuertes, Round((Sum(total_deaths)/Sum(total_cases)*100 ),4) as PercentDeaths 
From PortfolioProject. .CovidDeaths
where continent Is Not Null
Group by date
Order by PercentDeaths Desc

-- TOTAL DE CASOS EN EL MUNDO HASTA LA FECHA COMPRENDIDA

Create View hola as
Select location, (Max(total_cases)) as maxCasos
From PortfolioProject. .CovidDeaths
 Group by location
--ORDER BY LOCATION

select Sum(maxCasos) as CasosTotalesMundo
from hola



-- Vacunas aplicadas por localidad y fecha
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject. .CovidDeaths dea
Join PortfolioProject. .CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent Is Not Null
Order by 2,3


-- Cantidad total de vacunas aplicadas

Select  sum(cast(vac.new_vaccinations as int)) as SumVac
From PortfolioProject. .CovidDeaths dea
Join PortfolioProject. .CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null



-- Conteo de vacunacion, de personas vacunadas y % de personas vacunadas en argentina segun fecha.


With PopvsVac(continent, location, date, population, new_vaccinations, PersonasVac)
as(

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Convert(int,vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as PersonasVac
--(PersonasVac/population)*100 as PorcentVacunados (ASI NO FUNCIONA, HAY QUE HACER UN CTE)
From PortfolioProject. .CovidDeaths dea
Join PortfolioProject. .CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)

Select *, (PersonasVac/population)*100 as PorcentVacunados
From PopvsVac
Where location = 'Argentina'
Order by PorcentVacunados Desc


-- TAMBIEN SE PUEDE HACER CON TABLAS TEMPORALES

Drop Table if exists #PorcentPersonasVac
Create Table #PorcentPersonasVac
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PersonasVac numeric)

Insert into #PorcentPersonasVac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) AS PersonasVac
--(PersonasVac/population)*100 as PorcentVacunados (ASI NO FUNCIONA, HAY QUE HACER UN CTE o TABLA TEMPORAL)
From PortfolioProject. .CovidDeaths dea
Join PortfolioProject. .CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (PersonasVac/population)*100 as PorcentVacunados
From #PorcentPersonasVac
Where location = 'Argentina'
Order by PorcentVacunados Desc



-- Creando vista para posterior visualizacion de datos

Create View PorcentPersonasVacunas as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Convert(int,vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as PersonasVac
--(PersonasVac/population)*100 as PorcentVacunados (ASI NO FUNCIONA, HAY QUE HACER UN CTE o TABLA TEMPORAL)
From PortfolioProject. .CovidDeaths dea
Join PortfolioProject. .CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3


Select *
From PorcentPersonasVacunas



