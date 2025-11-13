    SELECT FC.CLIENT_NUMBER 		AS ClientNum, 
		   CASE
		      WHEN FC.CLIENT_TYPE_CODE = 'A' THEN 'Association'
			  WHEN FC.CLIENT_TYPE_CODE = 'B' THEN 'First Nation Band'
			  WHEN FC.CLIENT_TYPE_CODE = 'C' THEN 'Corporation'
			  WHEN FC.CLIENT_TYPE_CODE = 'F' THEN 'Ministry of Forests and Range'
			  WHEN FC.CLIENT_TYPE_CODE = 'G' THEN 'Government'
			  WHEN FC.CLIENT_TYPE_CODE = 'I' THEN 'Individual'
			  WHEN FC.CLIENT_TYPE_CODE = 'L' THEN 'Limited Partnership'
			  WHEN FC.CLIENT_TYPE_CODE = 'P' THEN 'General Partnership'
			  WHEN FC.CLIENT_TYPE_CODE = 'R' THEN 'First Nation Group'
			  WHEN FC.CLIENT_TYPE_CODE = 'S' THEN 'Society'
			  WHEN FC.CLIENT_TYPE_CODE = 'T' THEN 'First Nation Tribal Council'
			  WHEN FC.CLIENT_TYPE_CODE = 'U' THEN 'Unregistered Company'
			  ELSE 'Unkonwn'
		   END AS ClientType,
		   DECODE (FC.CLIENT_TYPE_CODE, 'I', NULL, FC.CLIENT_NAME) AS ClientName,
           CASE
              WHEN FC.CLIENT_TYPE_CODE = 'I' THEN NULL
              ELSE LTRIM(
                 COALESCE(CL.address_1, '') ||
                 CASE WHEN CL.address_2 IS NOT NULL THEN ', ' || CL.address_2 ELSE '' END ||
                 CASE WHEN CL.address_3 IS NOT NULL THEN ', ' || CL.address_3 ELSE '' END ||
                 CASE WHEN CL.city IS NOT NULL THEN ', ' || CL.city ELSE '' END ||
                 CASE WHEN CL.province IS NOT NULL THEN ', ' || CL.province ELSE '' END ||
                 CASE WHEN CL.postal_code IS NOT NULL THEN ', ' || CL.postal_code ELSE '' END ||
                 CASE WHEN CL.country IS NOT NULL THEN ', ' || CL.country ELSE '' END,
                 ', '
               ) 
            END AS ClientLoc,
            CASE
		      WHEN FC.CLIENT_STATUS_CODE = 'ACT' THEN 'Active'
			  WHEN FC.CLIENT_STATUS_CODE = 'DAC' THEN 'Deactivated'
			  WHEN FC.CLIENT_STATUS_CODE = 'DEC' THEN 'Deceased'
			  WHEN FC.CLIENT_STATUS_CODE = 'REC' THEN 'Receivership'
			  WHEN FC.CLIENT_STATUS_CODE = 'SPN' THEN 'Suspended'
			  ELSE 'Unkonwn'
		   END AS ClientStatus
    FROM FOREST_CLIENT FC,
	     CLIENT_LOCATION CL
    WHERE FC.Client_number = CL.Client_number(+)