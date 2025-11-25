-- =========================================================
-- QUERY 1: Total de escolas por dependência administrativa e região.
-- Analisa como as escolas estão distribuídas entre tipos de dependência e regiões.
SELECT 
    d.reg,
    dep.dpd_adm,
    COUNT(f.cod_inep) AS tot_esc
FROM dw.fat_esc f
JOIN dw.dim_loc d ON f.srk_loc = d.srk_loc
JOIN dw.dim_dpd dep ON f.srk_dpd = dep.srk_dpd
GROUP BY d.reg, dep.dpd_adm
ORDER BY d.reg, tot_esc DESC;

-- =========================================================
-- QUERY 2: Média de porte por restrição de atendimento e UF.
-- Compara o porte médio das escolas considerando tipos de restrição e estados.
SELECT 
    l.uf,
    r.rst_desc,
    ROUND(AVG(p.prt_num), 2) AS prt_med,
    COUNT(f.cod_inep) AS tot_esc
FROM dw.fat_esc f
JOIN dw.dim_loc l ON f.srk_loc = l.srk_loc
JOIN dw.dim_prt p ON f.srk_prt = p.srk_prt
JOIN dw.dim_rst_atn r ON f.srk_rst = r.srk_rst
GROUP BY l.uf, r.rst_desc
ORDER BY l.uf, prt_med DESC;

-- =========================================================
-- QUERY 3: Total de etapas/modalidades por escola agregado por região e dependência.
-- Mede quantas etapas diferentes cada escola oferece e agrega por região e dependência.
WITH etapas_por_esc AS (
    SELECT 
        b.srk_esc,
        COUNT(DISTINCT e.etp) AS qtd_etp
    FROM dw.bridge_esc_etp b
    JOIN dw.dim_etp e ON b.srk_etp = e.srk_etp
    GROUP BY b.srk_esc
),
res_dpd_reg AS (
    SELECT 
        l.reg,
        d.dpd_adm,
        ROUND(AVG(ep.qtd_etp), 2) AS med_etp_por_esc,
        COUNT(DISTINCT f.cod_inep) AS tot_esc
    FROM dw.fat_esc f
    JOIN dw.dim_loc l ON f.srk_loc = l.srk_loc
    JOIN dw.dim_dpd d ON f.srk_dpd = d.srk_dpd
    JOIN etapas_por_esc ep ON ep.srk_esc = f.cod_inep
    GROUP BY l.reg, d.dpd_adm
)
SELECT 
    reg,
    dpd_adm,
    med_etp_por_esc,
    tot_esc
FROM res_dpd_reg
ORDER BY reg, med_etp_por_esc DESC;

-- =========================================================
-- QUERY 4: Distribuição de escolas por UF e porte.
-- Mostra quantas escolas existem por estado e faixa de porte.
SELECT
    l.uf,
    p.prt_esc,
    COUNT(*) AS total_escolas
FROM dw.fat_esc f
JOIN dw.dim_loc l ON f.srk_loc = l.srk_loc
JOIN dw.dim_prt p ON f.srk_prt = p.srk_prt
GROUP BY l.uf, p.prt_esc
ORDER BY l.uf, total_escolas DESC;

-- =========================================================
-- QUERY 5: Quantidade de escolas rurais vs urbanas por região.
-- Analisa o perfil territorial das escolas agregado por região.
SELECT
    l.reg,
    l.is_rur,
    COUNT(*) AS tot_escolas
FROM dw.fat_esc f
JOIN dw.dim_loc l ON f.srk_loc = l.srk_loc
GROUP BY l.reg, l.is_rur
ORDER BY l.reg, tot_escolas DESC;

-- =========================================================
-- QUERY 6: Dependência administrativa predominante por UF.
-- Descobre qual tipo de dependência é mais comum em cada estado.
SELECT
    l.uf,
    d.dpd_adm,
    COUNT(*) AS tot_escolas
FROM dw.fat_esc f
JOIN dw.dim_loc l ON f.srk_loc = l.srk_loc
JOIN dw.dim_dpd d ON f.srk_dpd = d.srk_dpd
GROUP BY l.uf, d.dpd_adm
ORDER BY l.uf, tot_escolas DESC;

-- =========================================================
-- QUERY 7: Número médio de etapas oferecidas por UF.
-- Mede a diversidade de modalidades de ensino por estado.
WITH ep AS (
    SELECT
        b.srk_esc,
        COUNT(*) AS qtd_etapas
    FROM dw.bridge_esc_etp b
    GROUP BY b.srk_esc
)
SELECT
    l.uf,
    ROUND(AVG(ep.qtd_etapas), 2) AS media_etapas
FROM dw.fat_esc f
JOIN ep ON ep.srk_esc = f.cod_inep
JOIN dw.dim_loc l ON f.srk_loc = l.srk_loc
GROUP BY l.uf
ORDER BY media_etapas DESC;

-- =========================================================
-- QUERY 8: Quantidade de escolas por combinação de localidade e porte.
-- Identifica quais tipos de território concentram escolas maiores ou menores.
SELECT
    l.lca,
    p.prt_esc,
    COUNT(*) AS tot_escolas
FROM dw.fat_esc f
JOIN dw.dim_loc l ON f.srk_loc = l.srk_loc
LEFT JOIN dw.dim_prt p ON f.srk_prt = p.srk_prt
GROUP BY l.lca, p.prt_esc
ORDER BY l.lca, tot_escolas DESC;

-- =========================================================
-- QUERY 9: Top 10 municípios com maior número de escolas.
-- Ranking dos municípios mais relevantes em volume de escolas.
SELECT
    l.mun,
    l.uf,
    COUNT(*) AS tot_escolas
FROM dw.fat_esc f
JOIN dw.dim_loc l ON f.srk_loc = l.srk_loc
GROUP BY l.mun, l.uf
ORDER BY tot_escolas DESC
LIMIT 10;

-- =========================================================
-- QUERY 10: Correlação simples entre porte e número de etapas.
-- Verifica se escolas maiores tendem a ter mais etapas/modalidades.
WITH etapas AS (
    SELECT 
        b.srk_esc,
        COUNT(*) AS qtd_etp
    FROM dw.bridge_esc_etp b
    GROUP BY b.srk_esc
)
SELECT
    p.prt_esc,
    ROUND(AVG(et.qtd_etp), 2) AS media_etapas
FROM dw.fat_esc f
JOIN etapas et ON et.srk_esc = f.cod_inep
JOIN dw.dim_prt p ON f.srk_prt = p.srk_prt
GROUP BY p.prt_esc
ORDER BY media_etapas DESC;
