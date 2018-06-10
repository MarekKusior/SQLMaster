USE [AdventureWorks2012]
GO
/****** Object:  UserDefinedFunction [dbo].[ufnGetAccountingStartDate]    Script Date: 18.05.2018 19:58:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION dbo.ufnGetTotalCosts
(
	@SalesOrderID INT
)
RETURNS MONEY
AS
BEGIN
	
	DECLARE @total_cost AS MONEY;

	SELECT 
		@total_cost = AVG(pp.ListPrice)
	FROM 
		Sales.SalesOrderDetail AS sod 
		INNER JOIN Production.Product AS pp 
			ON sod.ProductID = pp.ProductID
	WHERE 
		sod.SalesOrderID = @SalesOrderID;

	RETURN @total_cost;
END
GO

