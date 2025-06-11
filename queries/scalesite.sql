
    SELECT ss.scale_site_id_nmbr AS ScaleSite
         , ou.org_unit_code      AS District
    FROM   scale_site ss
         , org_unit   ou
    WHERE ss.org_unit_no = ou.org_unit_no
    order by 1