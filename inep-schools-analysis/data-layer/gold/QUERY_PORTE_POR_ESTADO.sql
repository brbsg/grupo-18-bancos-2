SELECT
    l.uf,
    r.restricao_desc,
    ROUND(AVG(p.porte_numerico), 2) AS porte_medio,
    COUNT(f.sk_escola) AS total_escolas
FROM fato_escola f
JOIN dim_localidade l ON f.sk_localidade = l.sk_localidade
JOIN dim_porte p ON f.sk_porte = p.sk_porte
JOIN dim_restricao_atendimento r ON f.sk_restricao = r.sk_restricao
GROUP BY l.uf, r.restricao_desc, l.uf
ORDER BY l.uf, porte_medio DESC;