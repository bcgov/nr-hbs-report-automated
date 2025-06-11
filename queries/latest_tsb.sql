SELECT tsb.licence,
       tsb.timber_mark,
       tsb.mgmt_unit_type,
       tsb.mgmt_unit_id,
       CASE
       WHEN tsb.tsb_id = '19A' THEN '46A'
       WHEN tsb.tsb_id = '19B' THEN '46B'
       WHEN tsb.tsb_id = '19C' THEN '46C'
       WHEN tsb.tsb_id = '19D' THEN '46D'
       WHEN tsb.tsb_id = '19E' THEN '46E'
       WHEN tsb.tsb_id = '19F' THEN '46F'
       WHEN tsb.tsb_id = '21A' THEN '46G'
       WHEN tsb.tsb_id = '21B' THEN '46H'
       WHEN tsb.tsb_id = '21C' THEN '46I'
       WHEN tsb.tsb_id = '21D' THEN '46J'
       WHEN tsb.tsb_id = '21E' THEN '46K'
       WHEN tsb.tsb_id = '25A' THEN '25E'
       WHEN tsb.tsb_id = '25B' THEN '25E'
       WHEN tsb.tsb_id = '25C' THEN '25E'
       WHEN tsb.tsb_id = '25D' THEN '25E'
       WHEN tsb.tsb_id = '30B' THEN '30I'
       WHEN tsb.tsb_id = '30D' THEN '30I'
       WHEN tsb.tsb_id = '31A' THEN '31D'
       WHEN tsb.tsb_id = '31C' THEN '31D'
       WHEN tsb.tsb_id = '33A' THEN '48A'
       WHEN tsb.tsb_id = '33B' THEN '48B'
       WHEN tsb.tsb_id = '37A' THEN '48D'
       WHEN tsb.tsb_id = '37B' THEN '48E'
       WHEN tsb.tsb_id = '33C' THEN '47A'
       WHEN tsb.tsb_id = '33C' THEN '47A'
       WHEN tsb.tsb_id = '33D' THEN '47B'
       WHEN tsb.tsb_id = '33F' THEN '47C'
       WHEN tsb.tsb_id = '37D' THEN '47D'
       ELSE tsb.tsb_id
       END as tsb_id
FROM
(
SELECT a.licence,
       a.timber_mark,
       a.mgmt_unit_type,
       a.mgmt_unit_id,
       CASE
       WHEN a.ecas_tsb is not null THEN a.ecas_tsb
       WHEN a.non_app_gas_tsb is not null THEN a.non_app_gas_tsb
       WHEN a.fta_link_tsb is not null THEN a.fta_link_tsb   
       WHEN substr(a.fta_tsb,3,1) is not null THEN a.fta_tsb
       WHEN a.hist_gas_tsb is not null THEN a.hist_gas_tsb
       ELSE null
       END as TSB_ID
FROM 
(
       SELECT mbc.forest_file_id as licence,
       mbc.timber_mark,
       mbc.mgmt_unit_type,
       mbc.mgmt_unit_id,
       substr(mbc.mgmt_unit_id,1,2) as TSA_number,
       mu.mu_name AS TSA_name,
       case
       when mbc.mgmt_unit_type = 'V' then mbc.mgmt_unit_id
       else null
       end as fta_tsb,
       case
       when ftsb.tsb_id is null then null
       else substr(mbc.mgmt_unit_id,1,2)||ftsb.tsb_id
       end as fta_link_tsb,
       hgas.historic_gas_tsb_code as hist_gas_tsb,
       case
       when gnac.gas_non_app_conf_tsb_code is null then null
       else substr(mbc.mgmt_unit_id,1,2)||gnac.gas_non_app_conf_tsb_code
       end as non_app_gas_tsb,
       etsb.ecas_tsb as ecas_tsb       
    FROM 
       mark_billed_cli mbc,
       (
        SELECT  'TSA'           AS mu_type 
              , code_argument   as mu_id
              , expanded_result as mu_name           
        FROM    code_list_table 
        WHERE   column_name = 'TSA_NUMBER'
        UNION                        
        SELECT  'TFL'           AS mu_type 
              , code_argument   as mu_id
              , expanded_result as mu_name           
        FROM    code_list_table 
        WHERE   column_name = 'TFL_NUMBER'               
        UNION
        SELECT  'WL'            AS mu_type 
              , code_argument   as mu_id
              , expanded_result as mu_name           
        FROM    code_list_table 
        WHERE   column_name = 'WOODLOT_LICENCE'
       ) mu,
    --FTA tsb_id from the tmark_tsb_link table    
    (    
    SELECT DISTINCT ttl.timber_mark,
                    ttl.tsb_id
               FROM tmark_tsb_link ttl
    )ftsb,
    -- GAS historic appraisals that are active and confirmed only                             
     (                        
     SELECT DISTINCT haw.timber_mark as timber_mark,  
           haw.tsb_number_code as historic_gas_tsb_code
     FROM historic_appraised_worksheet haw 
     WHERE haw.active_ind = 'Y'
     AND haw.appraisal_status_code = 'CON'   
     AND haw.tsb_number_code is not null
     AND haw.appraisal_effective_date = (SELECT MAX(haw2.appraisal_effective_date)
                                   FROM historic_appraised_worksheet haw2
                                  WHERE haw.timber_mark = haw2.timber_mark
                                   AND haw2.appraisal_status_code = 'CON')
     )hgas,
    -- GAS non-appraised appraisals that are confirmed only
    (
      SELECT DISTINCT naw.timber_mark as timber_mark,  
         substr(naw.tsb_number_code,3,1) as gas_non_app_conf_tsb_code
     FROM non_appraised_worksheet naw  
     WHERE naw.non_appraised_status_code = 'CON'
     AND naw.tsb_number_code is not null
     AND naw.effective_date = (SELECT MAX(naw2.effective_date)
                                   FROM non_appraised_worksheet naw2
                                  WHERE naw.timber_mark = naw2.timber_mark
                                   AND naw2.non_appraised_status_code = 'CON')
     )gnac,
     -- ECAS tsb code
    (
    SELECT DISTINCT stm.timber_mark,
                ads.tsb_number_code as ecas_tsb
       FROM appraisal_data_submission ads,
            ads_submitted_timber_mark stm,
            (
            SELECT  stm.timber_mark,          
                MAX(ads.appraisal_effective_date) AS max_app_date
          FROM appraisal_data_submission ads,
               ads_submitted_timber_mark stm
         WHERE ads.appraisal_status_code = 'CON'
           AND  ads.ecas_id = stm.ecas_id
         GROUP BY stm.timber_mark
            )mx
      WHERE ads.ecas_id = stm.ecas_id
        and ads.appraisal_status_code = 'CON'
        and stm.timber_mark = mx.timber_mark
        and ads.appraisal_effective_date = mx.max_app_date
        )etsb
   WHERE mbc.mgmt_unit_type IN ('U','V')    
     AND mbc.timber_mark = ftsb.timber_mark(+)
     AND mbc.timber_mark = hgas.timber_mark(+)
     AND mbc.timber_mark = gnac.timber_mark(+)
     AND mbc.timber_mark = etsb.timber_mark(+)
     AND DECODE(mbc.mgmt_unit_type,
                'F', 'WL',
                'U', 'TSA',
                'V', 'TSA',
                'T', 'TFL') = mu.mu_type(+)
     AND SUBSTR(mbc.mgmt_unit_id, 1, 2) = mu.mu_id(+)
     )a
GROUP BY
       a.licence,
       a.timber_mark,
       a.mgmt_unit_type,
       a.mgmt_unit_id,
       CASE
       WHEN a.ecas_tsb is not null THEN a.ecas_tsb
       WHEN a.non_app_gas_tsb is not null THEN a.non_app_gas_tsb
       WHEN a.fta_link_tsb is not null THEN a.fta_link_tsb   
       WHEN substr(a.fta_tsb,3,1) is not null THEN a.fta_tsb
       WHEN a.hist_gas_tsb is not null THEN a.hist_gas_tsb
       ELSE null
       END
)tsb
GROUP BY
       tsb.licence,
       tsb.timber_mark,
       tsb.mgmt_unit_type,
       tsb.mgmt_unit_id,
       CASE
       WHEN tsb.tsb_id = '19A' THEN '46A'
       WHEN tsb.tsb_id = '19B' THEN '46B'
       WHEN tsb.tsb_id = '19C' THEN '46C'
       WHEN tsb.tsb_id = '19D' THEN '46D'
       WHEN tsb.tsb_id = '19E' THEN '46E'
       WHEN tsb.tsb_id = '19F' THEN '46F'
       WHEN tsb.tsb_id = '21A' THEN '46G'
       WHEN tsb.tsb_id = '21B' THEN '46H'
       WHEN tsb.tsb_id = '21C' THEN '46I'
       WHEN tsb.tsb_id = '21D' THEN '46J'
       WHEN tsb.tsb_id = '21E' THEN '46K'
       WHEN tsb.tsb_id = '25A' THEN '25E'
       WHEN tsb.tsb_id = '25B' THEN '25E'
       WHEN tsb.tsb_id = '25C' THEN '25E'
       WHEN tsb.tsb_id = '25D' THEN '25E'
       WHEN tsb.tsb_id = '30B' THEN '30I'
       WHEN tsb.tsb_id = '30D' THEN '30I'
       WHEN tsb.tsb_id = '31A' THEN '31D'
       WHEN tsb.tsb_id = '31C' THEN '31D'
       WHEN tsb.tsb_id = '33A' THEN '48A'
       WHEN tsb.tsb_id = '33B' THEN '48B'
       WHEN tsb.tsb_id = '37A' THEN '48D'
       WHEN tsb.tsb_id = '37B' THEN '48E'
       WHEN tsb.tsb_id = '33C' THEN '47A'
       WHEN tsb.tsb_id = '33C' THEN '47A'
       WHEN tsb.tsb_id = '33D' THEN '47B'
       WHEN tsb.tsb_id = '33F' THEN '47C'
       WHEN tsb.tsb_id = '37D' THEN '47D'
       ELSE tsb.tsb_id
       END
ORDER BY 1,2      