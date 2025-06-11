SELECT
tm.timber_mark AS mark,
ou.rollup_region_code AS region,
ou.rollup_dist_code AS district,
tm.mark_status_st AS mark_status,
tm.mark_status_date,
tm.mark_issue_date,
tm.mark_expiry_date, 
tm.mark_extend_date, 
gas.sp_zone AS sp_zone,
gas.adjust_qrterly_ind,
tm.cruise_based_ind as cr_based_ind
FROM
timber_mark tm,
org_unit ou,
(
	   SELECT
	   aw.timber_mark AS mark
	  ,asp.spp_sell_pric_zone AS sp_zone
      ,aw.adjust_qrterly_ind
	   FROM
	   app_species asp,
	   app_worksheet aw
	   WHERE aw.appraisal_sts_st = 'CNF'
       AND asp.timber_mark(+) = aw.timber_mark
	   AND asp.app_effective_date(+)  = aw.app_effective_date
	   AND aw.app_effective_date = (SELECT MAX(aw2.app_effective_date)
                                   FROM app_worksheet aw2
                                  WHERE aw.timber_mark = aw2.timber_mark
                                   AND aw2.appraisal_sts_st = 'CNF')
	   GROUP BY
	   aw.timber_mark
	  ,asp.spp_sell_pric_zone
      ,aw.adjust_qrterly_ind
	  )gas
WHERE
gas.mark(+) = tm.timber_mark
AND tm.forest_district = ou.org_unit_no
GROUP BY
tm.timber_mark,
ou.rollup_region_code,
ou.rollup_dist_code,
tm.mark_status_st,
tm.mark_status_date,
tm.mark_issue_date,
tm.mark_expiry_date, 
tm.mark_extend_date, 
adjust_qrterly_ind,
gas.sp_zone,
tm.cruise_based_ind
order by 1,2,3,4,5,6
    