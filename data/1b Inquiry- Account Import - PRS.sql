use staging;



--/*************************   



--CHECK that the owner distribution looks reasonable amongst the users_names

--********************************/


With CTLookup as (
SELECT c.[ksl_name] , t.name, c.ksl_shortname, ksl_communityid, teamid
  FROM [KSLCLOUD_MSCRM].[dbo].[ksl_community] c
   left join  [KSLCLOUD_MSCRM].[dbo].[team] t on c.[ksl_name] = t.name
  where
  c.[ksl_name] like '%preston%'

) , Users as ( 
	
	SELECT a.*  ,s.*
	FROM [KSLCLOUD_MSCRM].[dbo].[systemuser] s
		join  (  SELECT    a.*  ,com.* FROM kiscocustom..Associate a LEFT JOIN kiscocustom..KSL_Roles r ON a.RoleID = r.RoleID
															LEFT JOIN (SELECT * FROM [KiscoCustom].[dbo].[Community] WHERE name LIKE '%balfour%') com 
																on [CommunityIDY] = a.USR_CommLocation
																or [CommunityIDY] = a.USR_CommLocation2
																or [CommunityIDY] = a.USR_CommLocation3
																or [CommunityIDY] = a.USR_CommLocation4
														WHERE
															(a.TEA_ID = '15' OR a.TEA2_ID = '15')
															AND a.USR_Active = 1
															AND a.RoleID NOT IN (1144, 20)
															--AND (
															--	a.USR_CommLocation IN (SELECT [CommunityIDY] FROM [KiscoCustom].[dbo].[Community] WHERE name LIKE '%balfour%')
															--	OR a.USR_CommLocation2 IN (SELECT [CommunityIDY] FROM [KiscoCustom].[dbo].[Community] WHERE name LIKE '%balfour%')
															--	OR a.USR_CommLocation3 IN (SELECT [CommunityIDY] FROM [KiscoCustom].[dbo].[Community] WHERE name LIKE '%balfour%')
															--	OR a.USR_CommLocation4 IN (SELECT [CommunityIDY] FROM [KiscoCustom].[dbo].[Community] WHERE name LIKE '%balfour%')
															--)
								) a on a.USR_Email = s.internalemailaddress 
	) , last_contact_data AS (
    SELECT
        activities_id AS prospect_id,
        COALESCE(activities_completed_at, activities_scheduled_at) AS contact_date
    FROM
        [Staging].[dbo].[PRS_activities]

)



SELECT *
FROM  (

  SELECT 'Insert into dbo.account ( Name , 
statuscode , ' +
'ksl_communityid , 
Ownerid , 
ksl_prospectidy , 
address2_fax ,
ksl_waitlistamount ,
ksl_initialinquirydate,' 
+ iif(description IS NULL,'', 'description,') +
+ iif(ksl_leveloflivingpreference IS NULL OR ksl_leveloflivingpreference = '', '', 'ksl_leveloflivingpreference,') +
+ iif(ksl_initialsourcecategory IS NULL,'', 'ksl_initialsourcecategory,') +
+ iif(ksl_donotcontactreason IS NULL,'', 'ksl_donotcontactreason,') +
+ iif(emailaddress3 IS NULL,'', 'emailaddress3,') +
+ iif(ksl_donotcontactdetails IS NULL,'', 'ksl_donotcontactdetails,') +
+ iif(ksl_moveintiming IS NULL,'', 'ksl_moveintiming,') +
+ iif(ksl_waitlisttransactiondate IS NULL,'', 'ksl_waitlisttransactiondate,') +
+ iif(ksl_waitlistprioritydate IS NULL,'', 'ksl_waitlistprioritydate,') +
'owneridtype ) 
  Values (''' 
  + REPLACE(Name, '''', '''''') + ''' , 
  ''' + REPLACE(statuscode, '''', '''''') + ''' , 
  ''' + CAST(ksl_communityid AS VARCHAR(MAX)) + ''' , 
  ''' + CAST(Ownerid AS VARCHAR(MAX)) + ''' , 
  ''' + REPLACE(ksl_prospectidy, '''', '''''') + ''' , 
  ''' + REPLACE(address2_fax, '''', '''''') + ''' , 
  ''' + REPLACE(ksl_waitlistamount, '''', '''''') + ''' , 
  ''' + REPLACE(ksl_initialinquirydate, '''', '''''') + ''' , 
  ' 
 + iif(description IS NULL,'', '''' + CAST(description AS VARCHAR(MAX)) + ''' , ')  
 --+ iif(description IS NULL,NULL, '''' + REPLACE(CAST(description AS VARCHAR(MAX)), '''', '''''') + ''' , ')  

+ iif(ksl_leveloflivingpreference IS NULL OR ksl_leveloflivingpreference = '', '', '''' + REPLACE(CAST(ksl_leveloflivingpreference AS VARCHAR(MAX)), '''', '''''') + ''' , ')  
+ iif(ksl_initialsourcecategory IS NULL,'', '''' + REPLACE(CAST(ksl_initialsourcecategory AS VARCHAR(MAX)), '''', '''''') + ''' , ')  
+ iif(ksl_donotcontactreason IS NULL,'', '''' + REPLACE(CAST(ksl_donotcontactreason AS VARCHAR(MAX)), '''', '''''') + ''' , ')  
+ iif(emailaddress3 IS NULL,'', '''' + REPLACE(CAST(emailaddress3 AS VARCHAR(MAX)), '''', '''''') + ''' , ')  
+ iif(ksl_donotcontactdetails IS NULL,'', '''' + REPLACE(CAST(ksl_donotcontactdetails AS VARCHAR(MAX)), '''', '''''') + ''' , ')  
+ iif(ksl_moveintiming IS NULL,'', '''' + REPLACE(CAST(ksl_moveintiming AS VARCHAR(MAX)), '''', '''''') + ''' , ')  
+ iif(ksl_waitlisttransactiondate IS NULL,'', '''' + REPLACE(CAST(ksl_waitlisttransactiondate AS VARCHAR(MAX)), '''', '''''') + ''' , ')  
+ iif(ksl_waitlistprioritydate IS NULL,'', '''' + REPLACE(CAST(ksl_waitlistprioritydate AS VARCHAR(MAX)), '''', '''''') + ''' , ')  
+ '''' + REPLACE(owneridtype, '''', '''''') + ''' ) ' AS ins,
* 
FROM (




  --DECLARE @COM VARCHAR(MAX) = '5FAD5359-4278-EE11-8179-000D3A5A82BF'
--DECLARE @TEAM VARCHAR(MAX) = '195dca9d-4178-ee11-8179-000d3a5a82bf'
  Select
			ltrim(rtrim(replace(replace(coalesce([people_first_name],'(unknown)') +' '+ coalesce([people_last_name],'(unknown)')	 , '*', ''),'None','') )) AS Name
			,[prospects_story]
			 ,      COALESCE(
        REPLACE(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE([prospects_story], 
                                '''', ''''''),    -- Handle single quotes
                                '<ul>', CHAR(13) + CHAR(10)),  -- Replace <ul> with line break
                            '</ul>', CHAR(13) + CHAR(10)),  -- Replace </ul> with line break
                        '<li>', CHAR(13) + CHAR(10) + '• '),  -- Replace <li> with line break and bullet
                    '</li>', ''),  -- Remove closing li tags
                '<br>', CHAR(13) + CHAR(10)),  -- Replace <br> with line break
            '&nbsp;', ' ') 
        story_clean

 /**************
 This should be updated for the appropriate SDs
 **************/
--,a.ksl_communityidname
		, ( select ksl_communityid
			from CTLookup ct
			where ct.ksl_shortname = p.[community])  as ksl_communityid
		,p.community
		,CASE 
				WHEN [prospects_status] = 'closed'
				THEN (
					SELECT CAST(ct.teamid AS VARCHAR(MAX))
					FROM CTLookup ct 
					WHERE ct.ksl_shortname = p.[community]
				)
				
				WHEN EXISTS (
					SELECT 1 
					FROM users u 
					WHERE COALESCE(u.yomifullname, CONCAT(u.usr_first, ' ', u.USR_last)) = p.[users_name]
							and u.shortname = p.community
				) 
						THEN (
							SELECT CAST(u.systemuserid AS VARCHAR(MAX))
							FROM users u 
							WHERE COALESCE(u.yomifullname, CONCAT(u.usr_first, ' ', u.USR_last)) = p.[users_name]
										and u.shortname = p.community
						)
				ELSE (
					SELECT CAST(ct.teamid AS VARCHAR(MAX))
					FROM CTLookup ct 
					WHERE ct.ksl_shortname = p.[community]
				)
			END AS Ownerid
		
	,CASE 
			WHEN [prospects_status] = 'closed'
				THEN (
					SELECT CAST(ct.name AS VARCHAR(MAX))
					FROM CTLookup ct 
					WHERE ct.ksl_shortname = p.[community]
				)
				
				WHEN EXISTS (
					SELECT 1 
					FROM users u 
					WHERE COALESCE(u.yomifullname, CONCAT(u.usr_first, ' ', u.USR_last)) = p.[users_name]
					and u.shortname = p.community
				) 
				THEN (
					SELECT CAST(u.yomifullname AS VARCHAR(MAX))
					FROM users u 
					WHERE COALESCE(u.yomifullname, CONCAT(u.usr_first, ' ', u.USR_last)) = p.[users_name]
					and u.shortname = p.community
				)
				ELSE (
					SELECT CAST(ct.name AS VARCHAR(MAX))
					FROM CTLookup ct 
					WHERE ct.ksl_shortname = p.[community]
				)
			END AS OwnerName


		--, case WHEN [users_name] in ('Adrian Hausman','Jeff Baird','Stacy Jorden') THEN 'systemuser' 		
		--	else'team' 
		--	end owneridtype


		, case WHEN [prospects_status] = 'closed'
					THEN 'team' 
				WHEN EXISTS (
						 SELECT 1 
					FROM users u 
					WHERE COALESCE(u.yomifullname, CONCAT(u.usr_first, ' ', u.USR_last)) = p.[users_name]
					and u.shortname = p.community ) 
					THEN 'systemuser' 		
			else'team' 
			end owneridtype	
		,	p.[users_name]
/**************

stopping point

 **************/

	,cast( [prospects_active_at]  as varchar(max)) ksl_initialinquirydate

	,CAST(CAST(p.[prospects_id] AS BIGINT) AS VARCHAR(100)) AS ksl_prospectidy
	,CAST(CAST(p.[prospects_id] AS BIGINT) AS VARCHAR(100)) AS [address2_fax]

   --,cast(p.[prospect_id] as varchar(100)) as [address2_fax]


  
   
	,case
		when [prospects_status] = 'open' then '1'
		when [prospects_status] = 'Closed' then '864960001'
				-- case when  cast(lc.last_contact as date)  >= '1/1/2024' Then '1' else   '864960001' end 
		--else '1'
		end statuscode 
,prospects_status [status]
,close_reasons_name [lost reason]
, lc.last_contact
,stages_name [stage]
    ,
	LEFT(COALESCE('Stage Name: ' + [stages_name], '') + 
   
	CHAR(13) + ''' + Char(10) + ''' +  -- Insert a new line	
	' Score: ' + COALESCE(REPLACE(p.[scores_name], '''', ''''''), '') + 
    CHAR(13) + ''' + Char(10) + ''' +  -- Insert a new line
	' Lead Source: ' + COALESCE(REPLACE([lead_sources_name], '''', ''''''), '') + 
    CHAR(13) + ''' + Char(10) + ''' +  -- Insert a new line	
	' Secdondary Lead Source: ' + COALESCE(REPLACE([secondary_lead_sources_name], '''', ''''''), '') + 
	 CHAR(13) + ''' + Char(10) + ''' +   -- Insert a new line
    ' Marital Status: ' + COALESCE([residents_marital_status], '') + 
	CHAR(13) + ''' + Char(10) + ''' +   -- Insert a new line
    ' Current Residence: ' + COALESCE([residents_current_residence], '') + 
	CHAR(13) + ''' + Char(10) + ''' +   -- Insert a new line
    ' Veteran Status: ' + COALESCE([residents_veteran_status], '') + 
    CHAR(13) + ''' + Char(10) + ''' +   -- Insert a new line
    CHAR(13) + ''' + Char(10) Traits: + ''' +   -- Insert a new line
    ' Traits: ' + COALESCE(
        STUFF((
            SELECT CHAR(13) + ''' + Char(10) + ''' + ' - ' + t.trait_categories_name + ': ' + t.traits_name
            FROM [Staging].[dbo].[PRS_traits] t
            WHERE t.traits_record_id = p.[prospects_id]
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, ''), '')

    


    + CHAR(13) + ''' + Char(10) + ''' +   -- Insert a new line
    ' ProspectStory: ' + CHAR(39) + ' + Char(10) + ' + CHAR(39) + 
    COALESCE(
        REPLACE(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE([prospects_story], 
                                '''', ''''''),    -- Handle single quotes
                                '<ul>', CHAR(13) + CHAR(10)),  -- Replace <ul> with line break
                            '</ul>', CHAR(13) + CHAR(10)),  -- Replace </ul> with line break
                        '<li>', CHAR(13) + CHAR(10) + '• '),  -- Replace <li> with line break and bullet
                    '</li>', ''),  -- Remove closing li tags
                '<br>', CHAR(13) + CHAR(10)),  -- Replace <br> with line break
            '&nbsp;', ' ')  -- Replace &nbsp; with regular space
        , 19955) 
	 AS [description]


   
   ,case
         when r.care_types_name like '%Skilled Nursing%' then '5'
         when r.care_types_name like '%Memory Care%' then '4'
         when r.care_types_name like '%Assisted Living%' then '3'     
         when r.care_types_name like '%Independent Living%' then '1'
         end  [ksl_leveloflivingpreference]
	
 ,    CASE
        WHEN p.lead_sources_name IN ('Google', 'Website', 'Website Call', 'Further-VSA', 'CallRail', 'Roobrik') 
            THEN '15AC1CB4-C27F-E311-986A-0050568B37AC'
        WHEN p.lead_sources_name = 'Social Media' 
            THEN '15AC1CB4-C27F-E311-986A-0050568B37AC'
        
        -- Physical/Traditional Marketing
        WHEN p.lead_sources_name = 'Drive By/Signage' 
            THEN '43AC1CB4-C27F-E311-986A-0050568B37AC'
        WHEN p.lead_sources_name = 'All Print Ads' 
            THEN '13AC1CB4-C27F-E311-986A-0050568B37AC'
        WHEN p.lead_sources_name = 'Direct Mail' 
            THEN '13ac1cb4-c27f-e311-986a-0050568b37ac'
        
        -- Referrals
        WHEN p.lead_sources_name IN ('Word of Mouth') 
            THEN '41AC1CB4-C27F-E311-986A-0050568B37AC'
         WHEN p.lead_sources_name IN ('Family, Friend or Resident') 
            THEN '29ac1cb4-c27f-e311-986a-0050568b37ac'
        WHEN p.lead_sources_name = 'Employee Referral' 
            THEN '23AC1CB4-C27F-E311-986A-0050568B37AC'
        WHEN p.lead_sources_name IN ('Professional Referrer - Medical', 'Professional Referrer - Non Medical') 
            THEN '25AC1CB4-C27F-E311-986A-0050568B37AC'
        
        -- Paid Referral Agency
        WHEN p.lead_sources_name IN ('A Place For Mom', 'Caring.com', 'Care Patrol', 'Local Referral Agency', 'Other Aggregator') 
            THEN '27ac1cb4-c27f-e311-986a-0050568b37ac'
        
        -- Events
        WHEN p.lead_sources_name = 'On-site Community Event' 
            THEN '51ac1cb4-c27f-e311-986a-0050568b37ac'
        --ELSE 'unknown'
    END			[ksl_initialsourcecategory]

 ,   CASE
        -- Financial (2)
        WHEN close_reasons_name = 'Financially unqualified' THEN '2'
        WHEN close_reasons_name = 'Looking for Low-Income Housing' THEN '2'
        
        -- Asked Not to be Contacted (3)
        WHEN close_reasons_name = 'Not seeking senior living' THEN '3'
        WHEN close_reasons_name = 'No further contact requested' THEN '3'
        WHEN close_reasons_name = 'Call Rail- Not Interested in Senior Living' THEN '3'
        
        -- Deceased (4)
        WHEN close_reasons_name = 'Death' THEN '4'
        
        -- Unable to reach (5)
        WHEN close_reasons_name = 'Unable to Contact' THEN '5'
        WHEN close_reasons_name = 'Could not contact after 180 days' THEN '5'
        WHEN close_reasons_name = 'Not responsive' THEN '5'
        
        -- Duplicate (11)
        WHEN close_reasons_name = 'Duplicate' THEN '11'
        
        -- Secret Shopper (864960001)
        WHEN close_reasons_name = 'Secret Shopper' THEN '864960001'
        
        -- Location/moved (864960002)
        WHEN close_reasons_name = 'Location' THEN '864960002'
        WHEN close_reasons_name = 'Family relocating' THEN '864960002'
        WHEN close_reasons_name = 'Undesirable location/ Amenities/ Apt Size' THEN '864960002'
        
        -- Medical (1)
        WHEN close_reasons_name = 'Needs higher LOC' THEN '1'
        
        -- All other values will return NULL
        ELSE NULL
    END as [ksl_donotcontactreason]
	
	,cast(p.[users_name] as varchar(100)) as [emailaddress3]
	,cast(p.close_reason_details as varchar(100)) as [ksl_donotcontactdetails]

,   CASE
        -- Hot & Boiling Hot prospects (<30 days)
        WHEN scores_name IN ('Boiling Hot', 'Hot') THEN '1'
        -- Warm prospects (<60 days)
        WHEN scores_name = 'Warm' THEN '2'
        -- Cold prospects (>2 months)
        WHEN scores_name = 'Cold' THEN '3'
        -- Freezing Cold prospects (>2 years)
        WHEN scores_name = 'Freezing Cold' THEN '4'
    END as [ksl_moveintiming]

, CASE
			when stages_name = 'Deposit' then p.prospects_active_at
			END [ksl_waitlisttransactiondate]

, CASE
			when stages_name = 'Deposit' then p.prospects_active_at
			END [ksl_waitlistprioritydate]

, '0' ksl_waitlistamount


 ------This should be updated to dedup data when using a data source other than Sherpa/Aline
   ,ROW_NUMBER() over (partition by  ltrim(rtrim([people_first_name] +' '+	[people_last_name] )) , coalesce([people_cell_phone],cast([people_home_phone] as varchar)), p.prospects_id order by [people_cell_phone] desc,[people_home_phone]desc, [people_work_phone]desc, [people_fax_number]desc, p.prospects_active_at desc) ro
   ,ROW_NUMBER() over (partition by p.community ORDER BY  p.community ) rn


  /**************
 Staging table should be updated from appropriate community 
 **************/
   FROM [Staging].[dbo].[PRS_prospects] p
   left join [Staging].[dbo].[PRS_residents] r on p.prospects_id = r.residents_prospect_id

			left join  (select * from [KSLCLOUD_MSCRM].[dbo].[account] where ksl_communityid in (select ksl_communityid from CTLookup ct )
										) a  on cast(ksl_prospectidy as varchar)= CAST(CAST(p.[prospects_id] AS BIGINT) AS VARCHAR(100))
		    left join (	SELECT prospect_id, MAX(contact_date) AS last_contact
								FROM    last_contact_data
								GROUP BY    prospect_id	) AS lc
																	ON CAST(CAST(lc.[prospect_id] AS BIGINT) AS VARCHAR(100)) = CAST(CAST(p.[prospects_id] AS BIGINT) AS VARCHAR(100))
			
   
   where 
   a.accountid is null    and

	 ( p.prospects_status not in ( 'moved_in' , 'closed')  -- active leads

-- FIND OUT IF WE NEED THIS PART			 
		-- 	 OR ( p.prospects_status = 'closed'
		-- 				and (close_reasons_name in ( 'Staying at home','Location','Other',  'Could not contact after 180 days','Chose other community') 
		-- 				or close_reasons_name is null )  -- only these lost lead reasons
		-- 				--And cast(lc.last_contact as date) > = '1/1/2020'   -- Import lost leads up to the day of last contact
		-- 				)	
		-- )
   
   and (p.close_reasons_name not in ( 'Death', 'Duplicate' ) or p.close_reasons_name is null)
	and p.prospects_discarded_at is null 
	 )  
  --and p.[prospect_id] IN ('10069230')

  ) op

  where 
  ro = 1
--   and 
--   --(
--   community <> 'riv' 
--   --or ( community <> 'riv' and rn <6))

  ) t

  order by iif(ins is null, 1, 0) desc --, iif(notes is null, 1, 0) desc 

  --where ins is not null 

  
  
  -- not contacted in the last 2 years
  -- all with scheduled activity
  -- inquired in last 2 months
  
