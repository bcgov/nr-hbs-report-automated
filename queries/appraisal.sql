SELECT  aw.timber_mark AS mark
       ,TO_CHAR(aw.app_effective_date, 'YYYY-MM-DD' ) AS app_effective_date
	   ,TO_CHAR(aw.expiry_date, 'YYYY-MM-DD' ) AS app_expiry_date
	   ,aw.ttl_merchntbl_area AS Total_Merch_Area
       ,aw.cruise_grades_ind AS Cruise_Grades_Ind
       ,asp.HDBS_TREE_SPECIES AS Species
FROM   app_worksheet aw,
	   app_species asp
WHERE  aw.app_effective_date = asp.app_effective_date 
   AND aw.timber_mark = asp.timber_mark
   AND aw.appraisal_sts_st = 'CNF'
GROUP BY
	    aw.timber_mark
	   ,aw.app_effective_date
	   ,aw.expiry_date
	   ,aw.ttl_merchntbl_area
       ,aw.cruise_grades_ind
       ,asp.HDBS_TREE_SPECIES
ORDER BY 1,2,3,4