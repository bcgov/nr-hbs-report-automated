SELECT
           pf.forest_file_id                             AS Licence,
           fcl.client_number                             AS ClientNumber,
           pf.file_type_code                             AS Tenure,
           pf.file_status_st                             AS File_Status,
           TO_CHAR(pf.file_status_date, 'YYYY-MM-DD' )   AS File_Status_Date,
           TO_CHAR(tt.legal_effective_dt, 'YYYY-MM-DD' ) AS Legal_Effective_Date,
           tt.tenure_term                                AS Tenure_Term,
           TO_CHAR(tt.initial_expiry_dt, 'YYYY-MM-DD' )  AS Initial_Expiry_Date,
           TO_CHAR(tt.current_expiry_dt, 'YYYY-MM-DD' )  AS Current_Expiry_Date, 
           NVL(hc.schedule_a_aac,0) + NVL(hc.schedule_b_aac,0) AS AAC,
           DECODE (pf.mgmt_unit_type
                  ,'V', SUBSTR(pf.mgmt_unit_id, 1, 2)
                  ,'U', SUBSTR(pf.mgmt_unit_id, 1, 2)
                  ,NULL)                         AS TSANumber,
           pf.mgmt_unit_type                     AS MU_Type,
           pf.mgmt_unit_ID                       AS MU_ID,
           NVL(pf.sb_funded_ind,'N')             AS BCTS,
           NVL(hc.schedule_a_aac,0)              AS Sched_A_AAC,
           NVL(hc.schedule_b_aac,0)              AS Sched_B_AAC
    FROM prov_forest_use pf,
         forest_invoice fi,
         ps_invoice_dtl pid,
         timber_mark tm,
         tenure_term tt,
         harvest_commit hc,
         (SELECT * FROM for_client_link WHERE file_client_type = 'A') fcl
    WHERE fi.invoice_type_code = 'PSI'
      AND fi.invoice_number = pid.invoice_number
      AND fi.cancellation_ind = pid.cancellation_ind
      AND pid.timber_mark = tm.timber_mark
      AND tm.forest_file_id = pf.forest_file_id
      AND hc.forest_file_id(+) = pf.forest_file_id
      AND fcl.forest_file_id(+) = pf.forest_file_id
      AND tt.forest_file_id(+) = pf.forest_file_id
    UNION
    SELECT
           pf.forest_file_id,
           fcl.client_number,
           pf.file_type_code,
           pf.file_status_st,
           TO_CHAR(pf.file_status_date, 'YYYY-MM-DD' ),
           TO_CHAR(tt.legal_effective_dt, 'YYYY-MM-DD' ),
           tt.tenure_term,
           TO_CHAR(tt.initial_expiry_dt, 'YYYY-MM-DD' ),
           TO_CHAR(tt.current_expiry_dt, 'YYYY-MM-DD' ),
           NVL(hc.schedule_a_aac,0) + NVL(hc.schedule_b_aac,0),
           DECODE (pf.mgmt_unit_type
                  ,'V', SUBSTR(pf.mgmt_unit_id, 1, 2)
                  ,'U', SUBSTR(pf.mgmt_unit_id, 1, 2)
                  ,NULL),
           pf.mgmt_unit_type,
           pf.mgmt_unit_ID,
           NVL(pf.sb_funded_ind,'N'),
           NVL(hc.schedule_a_aac,0),
           NVL(hc.schedule_b_aac,0)
    FROM prov_forest_use pf,
         forest_invoice fi,
         ws_invoice_dtl wid,
         wgt_scl_invoice wsi,
         timber_mark tm,
         tenure_term tt,
         harvest_commit hc,
         (SELECT * FROM for_client_link WHERE file_client_type = 'A') fcl
    WHERE fi.invoice_type_code = 'WSI'
      AND fi.invoice_number = wsi.invoice_number
      AND fi.cancellation_ind = wsi.cancellation_ind
      AND fi.invoice_number = wid.invoice_number
      AND fi.cancellation_ind = wid.cancellation_ind
      AND wsi.timber_mark = tm.timber_mark
      AND tm.forest_file_id = pf.forest_file_id
      AND hc.forest_file_id(+) = pf.forest_file_id
      AND fcl.forest_file_id(+) = pf.forest_file_id
      AND tt.forest_file_id(+) = pf.forest_file_id
    ORDER BY 1,2,3,4,5,6,7,8

