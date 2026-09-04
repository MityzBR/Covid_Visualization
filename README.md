# COVID-19 Data Analysis — SQL Server

## Sobre o projeto

Este projeto consiste em uma análise exploratória de dados da COVID-19 utilizando **SQL Server**, com o objetivo de transformar dados brutos de casos, mortes, população e vacinação em informações relevantes para análise.

Durante o projeto, foram utilizadas diferentes técnicas de SQL para investigar a evolução da pandemia, identificar países com maiores taxas de infecção e mortalidade e analisar a relação entre população e vacinação.

O projeto também explora recursos mais avançados do SQL Server, como **Window Functions, CTEs, Temporary Tables e Views**.

---

## Objetivos

* Analisar a evolução dos casos de COVID-19 ao longo do tempo;
* Calcular taxas de mortalidade;
* Identificar países com maiores taxas de infecção em relação à população;
* Identificar países e continentes com maior número de mortes;
* Obter indicadores globais da pandemia;
* Relacionar dados de mortalidade com dados de vacinação;
* Calcular o número acumulado de vacinações;
* Calcular o percentual da população vacinada;
* Preparar dados para futuras visualizações e dashboards.

---

## Tecnologias utilizadas

* **SQL Server**
* **T-SQL**
* **SQL Server Management Studio (SSMS)**
* **GitHub**

---

## Estrutura dos dados

O projeto utiliza duas tabelas principais:

### `mortes_covid`

Contém informações relacionadas a:

* Localização;
* Continente;
* Data;
* População;
* Casos totais;
* Novos casos;
* Mortes totais;
* Novas mortes.

### `vacinacoes_covid`

Contém informações relacionadas à vacinação, incluindo:

* Localização;
* Data;
* Novas vacinações.

As duas tabelas são relacionadas através de:

```sql
location
date
```

---

## Análises realizadas

### 1. Exploração inicial dos dados

A primeira etapa consiste em explorar a estrutura e os registros disponíveis na base.

```sql
SELECT *
FROM projeto_portfolio..mortes_covid
WHERE continent IS NOT NULL
ORDER BY 3, 4;
```

O objetivo é entender os dados antes de iniciar os cálculos e análises.

---

### 2. Taxa de mortalidade

Foi calculada a porcentagem de mortes em relação ao número total de casos:

```text
Taxa de mortalidade =
(Total de mortes / Total de casos) × 100
```

Esse indicador permite analisar a proporção de casos que resultaram em morte.

---

### 3. Percentual da população infectada

Também foi calculado o percentual da população infectada:

```text
Percentual infectado =
(Total de casos / População) × 100
```

Essa abordagem permite comparar países levando em consideração suas diferenças populacionais.

---

### 4. Países com maior taxa de infecção

Utilizando `GROUP BY` e `MAX()`, foram identificados os maiores números de casos registrados e os maiores percentuais de infecção em relação à população.

```sql
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;
```

---

### 5. Países com maior número de mortes

Foi realizada uma análise para identificar os países com os maiores números acumulados de mortes.

```sql
MAX(CAST(total_deaths AS INT))
```

O `CAST` foi utilizado para garantir que os valores fossem tratados como números antes da agregação.

---

### 6. Análise por continente

Os dados também foram agrupados por continente para obter uma visão mais ampla da distribuição das mortes.

```sql
GROUP BY continent
ORDER BY TotalDeathCount DESC;
```

---

### 7. Indicadores globais

Foram calculados os números globais de:

* Total de casos;
* Total de mortes;
* Taxa global de mortalidade.

Para isso, foi utilizada a função de agregação `SUM()`.

---

## Análise de vacinação

Uma das principais etapas do projeto foi relacionar os dados de mortes com os dados de vacinação.

Para isso, foi utilizado `JOIN` entre as tabelas:

```sql
FROM projeto_portfolio..mortes_covid AS dea

JOIN projeto_portfolio..vacinacoes_covid AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
```

Essa combinação permite analisar os dados de vacinação em conjunto com informações demográficas e epidemiológicas.

---

## Window Functions

Para calcular o número acumulado de vacinações ao longo do tempo, foi utilizada uma **Window Function**:

```sql
SUM(CONVERT(BIGINT, vac.new_vaccinations))
OVER (
    PARTITION BY dea.Location
    ORDER BY dea.Date
) AS RollingPeopleVaccinated
```

O `PARTITION BY` separa os cálculos por localização, enquanto o `ORDER BY` garante que o acumulado seja calculado cronologicamente.

Exemplo conceitual:

| Data  | Novas vacinações | Acumulado |
| ----- | ---------------: | --------: |
| Dia 1 |              100 |       100 |
| Dia 2 |              200 |       300 |
| Dia 3 |              150 |       450 |
| Dia 4 |              300 |       750 |

---

## CTE

Também foi utilizada uma **Common Table Expression (CTE)** para organizar o cálculo da vacinação acumulada e posteriormente calcular o percentual da população vacinada.

```sql
WITH PopvsVac AS
(
    ...
)
SELECT *,
       (RollingPeopleVaccinated / Population) * 100
FROM PopvsVac;
```

A CTE facilita a organização de consultas complexas e permite trabalhar com resultados intermediários.

---

## Temporary Table

Outra abordagem utilizada foi uma **Temporary Table**:

```sql
CREATE TABLE #PercentPopulationVaccinated
```

A tabela temporária foi utilizada para armazenar os resultados intermediários da análise de vacinação.

Posteriormente, os dados armazenados foram utilizados para calcular o percentual da população vacinada.

---

## View

Por fim, foi criada uma **View** para disponibilizar os dados de vacinação acumulada para futuras análises e visualizações:

```sql
CREATE OR ALTER VIEW PercentPopulationVaccinated AS
...
```

A View permite reutilizar uma consulta complexa sem precisar escrever novamente toda a lógica.

Isso também facilita a integração futura com ferramentas de visualização e Business Intelligence.

---

## Principais conceitos de SQL utilizados

| Conceito          | Aplicação                                    |
| ----------------- | -------------------------------------------- |
| `SELECT`          | Seleção dos dados                            |
| `WHERE`           | Filtragem dos registros                      |
| `LIKE`            | Busca por padrões                            |
| `ORDER BY`        | Ordenação dos resultados                     |
| `GROUP BY`        | Agrupamento dos dados                        |
| `MAX()`           | Identificação de valores máximos             |
| `SUM()`           | Cálculo de totais                            |
| `CAST()`          | Conversão de tipos                           |
| `CONVERT()`       | Conversão de tipos                           |
| `JOIN`            | Relacionamento entre tabelas                 |
| `NULLIF()`        | Prevenção de divisão por zero                |
| `OVER()`          | Funções de janela                            |
| `PARTITION BY`    | Criação de grupos dentro de Window Functions |
| `CTE`             | Organização de consultas complexas           |
| `Temporary Table` | Armazenamento temporário de resultados       |
| `VIEW`            | Reutilização de consultas                    |

---

## Insights que podem ser extraídos

A partir das consultas desenvolvidas, é possível construir análises como:

* Quais países apresentaram os maiores percentuais de população infectada?
* Quais países registraram o maior número de mortes?
* Como os números variaram entre os continentes?
* Qual foi a taxa global de mortalidade?
* Como a vacinação evoluiu ao longo do tempo?
* Qual percentual da população foi vacinado ao longo do período analisado?

---

## Próximos passos

Como evolução do projeto, os dados preparados no SQL Server podem ser utilizados para construir um **dashboard interativo** em ferramentas de Business Intelligence.

Possíveis visualizações:

* Evolução de casos ao longo do tempo;
* Evolução de mortes;
* Mapa mundial de infecções;
* Ranking de países;
* Taxa de mortalidade;
* Percentual da população infectada;
* Evolução da vacinação;
* Percentual acumulado da população vacinada.

---

## O que este projeto demonstra

Este projeto demonstra a aplicação prática de SQL para **análise e transformação de dados**, indo além de consultas básicas.

Entre as principais competências desenvolvidas estão:

* Exploração e tratamento de dados;
* Análise exploratória;
* Criação de indicadores;
* Agregação de grandes volumes de dados;
* Relacionamento entre tabelas;
* Window Functions;
* CTEs;
* Temporary Tables;
* Views;
* Preparação de dados para Business Intelligence.

---

## Autor

**Pedro**

Estudante de **Análise e Desenvolvimento de Sistemas**, com interesse em **Dados, Tecnologia, UX/UI e desenvolvimento de soluções digitais**.

---

## Licença

Este projeto foi desenvolvido para fins de estudo e construção de portfólio.
