SELECT 
    d.regiao,
    dep.dependencia_administrativa,
    COUNT(f.sk_escola) AS total_escolas
FROM fato_escola f
JOIN dim_localidade d ON f.sk_localidade = d.sk_localidade
JOIN dim_dependencia dep ON f.sk_dependencia = dep.sk_dependencia
GROUP BY d.regiao, dep.dependencia_administrativa
ORDER BY d.regiao, total_escolas DESC;

SELECT 
    l.uf,
    r.restricao_atendimento,
    ROUND(AVG(p.porte_numerico), 2) AS porte_medio,
    COUNT(f.sk_escola) AS total_escolas
FROM fato_escola f
JOIN dim_localidade l ON f.sk_localidade = l.sk_localidade
JOIN dim_porte p ON f.sk_porte = p.sk_porte
JOIN dim_restricao_atendimento r ON f.sk_restricao = r.sk_restricao
GROUP BY l.uf, r.restricao_atendimento
ORDER BY l.uf, porte_medio DESC;

WITH resumo_regional AS (
    SELECT 
        l.regiao,
        COUNT(DISTINCT f.sk_escola) AS total_escolas,
        SUM(f.num_etapas) AS total_etapas,
        AVG(p.porte_numerico) AS porte_medio
    FROM fato_escola f
    JOIN dim_localidade l ON f.sk_localidade = l.sk_localidade
    JOIN dim_porte p ON f.sk_porte = p.sk_porte
    GROUP BY l.regiao
)
SELECT 
    regiao,
    total_escolas,
    total_etapas,
    ROUND(porte_medio, 2) AS porte_medio,
    ROUND(
        (total_etapas * 0.5) + (porte_medio * 0.3) + (total_escolas * 0.2),
        2
    ) AS indice_relevancia
FROM resumo_regional
ORDER BY indice_relevancia DESC;