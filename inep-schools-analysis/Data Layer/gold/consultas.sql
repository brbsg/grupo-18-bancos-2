SELECT 
    d.reg,
    dep.dpd_adm,
    COUNT(f.srk_esc) AS tot_esc
FROM dw.fat_esc f
JOIN dw.dim_loc d ON f.srk_loc = d.srk_loc
JOIN dw.dim_dpd dep ON f.srk_dpd = dep.srk_dpd
GROUP BY d.reg, dep.dpd_adm
ORDER BY d.reg, tot_esc DESC;

SELECT 
    l.uf,
    r.rst_desc,
    ROUND(AVG(p.prt_num), 2) AS prt_med,
    COUNT(f.srk_esc) AS tot_esc
FROM dw.fat_esc f
JOIN dw.dim_loc l ON f.srk_loc = l.srk_loc
JOIN dw.dim_prt p ON f.srk_prt = p.srk_prt
JOIN dw.dim_rst_atn r ON f.srk_rst = r.srk_rst
GROUP BY l.uf, r.rst_desc
ORDER BY l.uf, prt_med DESC;

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
        COUNT(DISTINCT f.srk_esc) AS tot_esc
    FROM dw.fat_esc f
    JOIN dw.dim_loc l ON f.srk_loc = l.srk_loc
    JOIN dw.dim_dpd d ON f.srk_dpd = d.srk_dpd
    JOIN etapas_por_esc ep ON ep.srk_esc = f.srk_esc
    GROUP BY l.reg, d.dpd_adm
)

SELECT 
    reg,
    dpd_adm,
    med_etp_por_esc,
    tot_esc
FROM res_dpd_reg
ORDER BY reg, med_etp_por_esc DESC;