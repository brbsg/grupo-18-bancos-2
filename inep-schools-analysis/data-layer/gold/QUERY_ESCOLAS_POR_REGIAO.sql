SELECT
    d.regiao,
    dep.dependencia_adm,
    COUNT(f.sk_escola) AS total_escolas
FROM fato_escola f
JOIN dim_localidade d ON f.sk_localidade = d.sk_localidade
JOIN dim_dependencia dep ON f.sk_dependencia = dep.sk_dependencia
GROUP BY d.regiao, dep.dependencia_adm, d.regiao
ORDER BY d.regiao, total_escolas DESC;