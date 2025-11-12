WITH etapas_por_escola AS (
    SELECT 
        f.sk_escola,
        COUNT(DISTINCT e.etapa_modalidade) AS qtd_etapas
    FROM fato_escola f
    JOIN dim_etapa e ON f.sk_etapa = e.sk_etapa
    GROUP BY f.sk_escola
),

resumo_dependencia_regiao AS (
    SELECT 
        l.regiao,
        d.dependencia_administrativa,
        ROUND(AVG(ep.qtd_etapas), 2) AS media_etapas_por_escola,
        COUNT(DISTINCT f.sk_escola) AS total_escolas
    FROM fato_escola f
    JOIN dim_localidade l ON f.sk_localidade = l.sk_localidade
    JOIN dim_dependencia d ON f.sk_dependencia = d.sk_dependencia
    JOIN etapas_por_escola ep ON ep.sk_escola = f.sk_escola
    GROUP BY l.regiao, d.dependencia_administrativa
)

SELECT 
    regiao,
    dependencia_administrativa,
    media_etapas_por_escola,
    total_escolas
FROM resumo_dependencia_regiao
ORDER BY regiao, media_etapas_por_escola DESC;
