SELECT     tm.timber_mark             		AS TimberMark,
           tm.forest_file_id          		AS Licence,
           tm.cutting_permit_id       		AS CuttingPermitId,
		   aw.appraisal_mthd_cd				AS AppraisalMethodCode,
		   TO_CHAR(FI.INVOICE_DATE,'YYYYMM')AS Billed_Month,
		   TO_CHAR(FI.SCALE_RETURN_DATE,'YYYYMM') AS Scale_Month,
           fi.scale_site_id_nmbr      		AS ScaleSite,
           pid.hdbs_tree_species      		AS Species,
		   pid.forest_product_cd			AS Product,
           pid.log_grade              		AS Grade,
		   DECODE (pid.revenue_classn_cd
		          ,'WAV', 'A'
				  ,'WUN', 'U'
				  ,'WSA', 'A'
				  ,'WSU', 'U','N') 	  		AS WasteIndicator,
           SUM(pid.volume)            		AS Volume,
           SUM(pid.number_of_pieces)  		AS Pieces,
		   SUM(pid.amount_in_dollars) 		AS VALUE,
           pid.rate_in_dollars              AS Rate
    FROM  (SELECT * FROM forest_invoice
		   -- **** Change date to show current month ****
		   WHERE invoice_date BETWEEN TO_DATE(?, 'YYYY-MM-DD HH24:MI:SS') AND TO_DATE(?, 'YYYY-MM-DD HH24:MI:SS')
	       AND invoice_type_code = 'PSI') fi,
         ps_invoice_dtl pid,
         timber_mark tm,
		 (SELECT timber_mark,appraisal_mthd_cd,MAX(app_effective_date)
		  FROM app_worksheet GROUP BY timber_mark,appraisal_mthd_cd) aw
    WHERE fi.invoice_number = pid.invoice_number
      AND fi.cancellation_ind = pid.cancellation_ind
      AND pid.timber_mark = tm.timber_mark
	  AND aw.timber_mark(+) = tm.timber_mark
    GROUP BY tm.timber_mark,
             tm.forest_file_id,
             tm.cutting_permit_id,
		     aw.appraisal_mthd_cd,
		     TO_CHAR(FI.INVOICE_DATE,'YYYYMM'),
			 TO_CHAR(FI.SCALE_RETURN_DATE,'YYYYMM'),
             fi.scale_site_id_nmbr,
             pid.hdbs_tree_species,
             pid.log_grade,
			 pid.forest_product_cd,
		     DECODE (pid.revenue_classn_cd
		          ,'WAV', 'A'
				  ,'WUN', 'U'
				  ,'WSA', 'A'
				  ,'WSU', 'U','N'),
             pid.rate_in_dollars
	UNION
    SELECT tm.timber_mark             		AS TimberMark,
           tm.forest_file_id          		AS Licence,
           tm.cutting_permit_id       		AS CuttingPermitId,
		   aw.appraisal_mthd_cd				AS AppraisalMethodCode,
		   TO_CHAR(FI.INVOICE_DATE,'YYYYMM')AS Billed_Month,
		   TO_CHAR(FI.SCALE_RETURN_DATE,'YYYYMM')AS Scale_Month,
           fi.scale_site_id_nmbr      		AS ScaleSite,
           wid.hdbs_tree_species      		AS Species,
		   ' '								AS Product,
           wid.log_grade              		AS Grade,
		  DECODE (wsi.revenue_classn_cd
		          ,'WAV', 'A'
				  ,'WUN', 'U'
				  ,'WSA', 'A'
				  ,'WSU', 'U','N') 	  		AS WasteIndicator,
		   SUM(wid.additional_volume)  		AS Volume,
           0							    AS Pieces,
		   SUM(wid.additional_amount) 		AS VALUE,
           wid.rate_in_dollars              AS Rate
    FROM (SELECT * FROM forest_invoice
		   -- **** Change date to show current month ****
		   WHERE invoice_date BETWEEN TO_DATE(?, 'YYYY-MM-DD HH24:MI:SS') AND TO_DATE(?, 'YYYY-MM-DD HH24:MI:SS')
	       AND invoice_type_code = 'WSI') fi,
         ws_invoice_dtl wid,
         wgt_scl_invoice wsi,
         timber_mark tm,
		 (SELECT timber_mark,appraisal_mthd_cd,MAX(app_effective_date)
		  FROM app_worksheet GROUP BY timber_mark,appraisal_mthd_cd) aw
    WHERE fi.invoice_number = wsi.invoice_number
      AND fi.cancellation_ind = wsi.cancellation_ind
      AND fi.invoice_number = wid.invoice_number
      AND fi.cancellation_ind = wid.cancellation_ind
      AND wsi.timber_mark = tm.timber_mark
	  AND aw.timber_mark(+) = tm.timber_mark
    GROUP BY  tm.timber_mark,
           tm.forest_file_id,
           tm.cutting_permit_id,
		   aw.appraisal_mthd_cd,
		   TO_CHAR(FI.INVOICE_DATE,'YYYYMM'),
		   TO_CHAR(FI.SCALE_RETURN_DATE,'YYYYMM'),
           fi.scale_site_id_nmbr,
           wid.hdbs_tree_species,
           wid.log_grade,
		   DECODE (wsi.revenue_classn_cd
		          ,'WAV', 'A'
				  ,'WUN', 'U'
				  ,'WSA', 'A'
				  ,'WSU', 'U','N'),
           wid.rate_in_dollars;