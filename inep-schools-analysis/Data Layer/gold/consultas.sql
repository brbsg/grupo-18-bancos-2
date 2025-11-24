SELECT 
    d.regiao,
    dep.dependencia_adm,
    COUNT(f.sk_escola) AS total_escolas
FROM dw.fato_escola f
JOIN dw.dim_localidade d ON f.sk_localidade = d.sk_localidade
JOIN dw.dim_dependencia dep ON f.sk_dependencia = dep.sk_dependencia
GROUP BY d.regiao, dep.dependencia_adm
ORDER BY d.regiao, total_escolas DESC;

SELECT 
    l.uf,
    r.restricao_desc,
    ROUND(AVG(p.porte_numerico), 2) AS porte_medio,
    COUNT(f.sk_escola) AS total_escolas
FROM dw.fato_escola f
JOIN dw.dim_localidade l ON f.sk_localidade = l.sk_localidade
JOIN dw.dim_porte p ON f.sk_porte = p.sk_porte
JOIN dw.dim_restricao_atendimento r ON f.sk_restricao = r.sk_restricao
GROUP BY l.uf, r.restricao_desc
ORDER BY l.uf, porte_medio DESC;

WITH etapas_por_escola AS (
    SELECT 
        b.sk_escola,
        COUNT(DISTINCT e.etapa) AS qtd_etapas
    FROM dw.bridge_escola_etapa b
    JOIN dw.dim_etapa e ON b.sk_etapa = e.sk_etapa
    GROUP BY b.sk_escola
),

resumo_dependencia_regiao AS (
    SELECT 
        l.regiao,
        d.dependencia_adm,
        ROUND(AVG(ep.qtd_etapas), 2) AS media_etapas_por_escola,
        COUNT(DISTINCT f.sk_escola) AS total_escolas
    FROM dw.fato_escola f
    JOIN dw.dim_localidade l ON f.sk_localidade = l.sk_localidade
    JOIN dw.dim_dependencia d ON f.sk_dependencia = d.sk_dependencia
    JOIN etapas_por_escola ep ON ep.sk_escola = f.sk_escola
    GROUP BY l.regiao, d.dependencia_adm
)

SELECT 
    regiao,
    dependencia_adm,
    media_etapas_por_escola,
    total_escolas
FROM resumo_dependencia_regiao
ORDER BY regiao, media_etapas_por_escola DESC;