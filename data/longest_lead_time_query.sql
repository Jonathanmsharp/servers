SELECT TOP 1 c.Lead_AccountID, c.PotentialResidentName, c.InitialInquiryDate, c.MoveInDate, DATEDIFF(day, c.InitialInquiryDate, c.MoveInDate) as DaysToMoveIn, c.Initial_Source, c.Source_Category, f.ksl_CommunityIdName FROM [DataWarehouse].[dbo].[Dim_CRM] c INNER JOIN [DataWarehouse].[dbo].[Fact_Lead] f ON c.Lead_AccountID = f.Lead_AccountID WHERE YEAR(c.MoveInDate) = 2024 AND c.IsMovedIn = 1 AND c.InitialInquiryDate IS NOT NULL ORDER BY DATEDIFF(day, c.InitialInquiryDate, c.MoveInDate) DESC;
