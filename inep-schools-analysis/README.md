# Análise Exploratória de Dados - Escolas INEP

## 📋 Visão Geral

Este projeto realiza uma análise exploratória completa dos dados de escolas brasileiras do INEP (Instituto Nacional de Estudos e Pesquisas Educacionais Anísio Teixeira), utilizando três tipos principais de visualizações:

- **Gráficos de Pizza**: Para distribuições categóricas
- **Gráficos de Regressão Linear**: Para identificar relações entre variáveis numéricas  
- **Gráficos de Boxplot**: Para análises estatísticas de distribuições

## 🏗️ Arquitetura Medallion

O projeto segue o padrão **Medallion Architecture**:

### Bronze Layer (`bronze/`)
- **Dados brutos**: `escolas_inep.csv` - Catálogo completo de escolas do INEP
- **Dicionário de Dados**: - Dicionário dos dados brutos no CSV
- **Análise Bruta**: - Gráficos com a análise dos dados brutos do CSV

### Transform Layer (`transform/`)
- **Tratamento**: `tratamento.ipynb` - Limpeza, padronização e criação de colunas derivadas e envio para o banco de dados postgres

### Silver Layer
- **MER, DER, DLD**: - Modelagem dos dados tratados
- **Dados tratados**: - Dataset limpo e estruturado

### Gold Layer (`gold/`)
- **A fazer**

## 📊 Tipos de Análises Realizadas

### 1. Gráficos de Pizza
- Distribuição por dependência administrativa (pública vs privada)
- Distribuição por região do Brasil
- Distribuição rural vs urbana

### 2. Gráficos de Regressão Linear
- Relação entre porte da escola e número de etapas oferecidas
- Distribuição geográfica (latitude vs longitude)
- Relação entre porte da escola e localização

### 3. Gráficos de Boxplot
- Distribuição do número de etapas por região
- Distribuição da latitude por dependência administrativa
- Distribuição do número de etapas por porte da escola

## 🚀 Como Executar

### Pré-requisitos
```bash
python3 -m venv venv_inep
source venv_inep/bin/activate
pip install -r requirements.txt
```

### Execução Sequencial
1. **Bronze**: Execute `bronze/ingestao.ipynb` para carregar os dados brutos
2. **Transform**: Execute `transform/tratamento.ipynb` para tratar os dados e enviar para o banco de dados postgres 
3. **Silver**: MER, DER, DLD e análise dos dados tratados comparados com os dados brutos

## 📈 Principais Insights

### Distribuições Categóricas
- Maioria das escolas são públicas (municipais e estaduais)
- Concentração nas regiões Sudeste e Nordeste
- Predominância de escolas urbanas sobre rurais

### Relações Numéricas
- Relação positiva entre porte da escola e número de etapas oferecidas
- Escolas maiores tendem a estar mais concentradas em áreas urbanas
- Distribuição geográfica natural pelo território brasileiro

### Análises Estatísticas
- Diferentes regiões apresentam padrões distintos na oferta educacional
- Escolas federais mostram distribuição geográfica específica
- Escolas maiores oferecem mais etapas educacionais

## 🛠️ Tecnologias Utilizadas

- **PySpark**: Processamento distribuído de dados
- **Pandas**: Manipulação de dados
- **Matplotlib/Seaborn**: Visualizações
- **Scikit-learn**: Análises estatísticas
- **Jupyter**: Ambiente de desenvolvimento

