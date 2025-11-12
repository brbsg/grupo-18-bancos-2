WITH resumo_regional AS (
    SELECT
        l.regiao,
        COUNT(DISTINCT f.sk_escola) AS total_escolas,
        COUNT(b.sk_etapa) AS total_etapas,
        AVG(p.porte_numerico) AS porte_medio
    FROM fato_escola f
    JOIN dim_localidade l ON f.sk_localidade = l.sk_localidade
    LEFT JOIN dim_porte p ON f.sk_porte = p.sk_porte
    LEFT JOIN bridge_escola_etapa b ON b.sk_escola = f.sk_escola
    GROUP BY l.regiao
)
SELECT
    regiao,
    total_escolas,
    total_etapas,
    ROUND(porte_medio, 2) AS porte_medio,
    -- índice ponderado de relevância
    ROUND(
        (total_etapas * 0.5) + (porte_medio * 0.3) + (total_escolas * 0.2),
        2
    ) AS indice_relevancia
FROM resumo_regional
ORDER BY indice_relevancia DESC;
