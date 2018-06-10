USE MyDatabase

/*
	Drop & Create
*/
DROP TABLE IF EXISTS [dbo].[Sales];
DROP TABLE IF EXISTS [dbo].[Category];
DROP TABLE IF EXISTS [dbo].[SubCategory];
DROP TABLE IF EXISTS [dbo].[Customer];
DROP TABLE IF EXISTS [dbo].[Address];
DROP TABLE IF EXISTS [dbo].[Product];

/*
	Create table
*/

CREATE TABLE [dbo].[Address]
(
	AddressID INT NOT NULL PRIMARY KEY,
	AddressLine1 NVARCHAR(60) NOT NULL, 
	AddressLine2 NVARCHAR(60) NOT NULL, 
	Citi NVARCHAR(30) NOT NULL,
	Postalcode NVARCHAR(15) NOT NULL
);
CREATE TABLE [dbo].[Customer]
(
	CustomerID INT NOT NULL PRIMARY KEY,
	AddressID INT NOT NULL, 
	CustomerName NVARCHAR(15) NOT NULL,
	CONSTRAINT Customer_AddressID_FK
	FOREIGN KEY (AddressID) REFERENCES [Address](AddressID)
);
CREATE TABLE [dbo].[Category]
(
	CategoryID INT NOT NULL PRIMARY KEY,
	Name VARCHAR(100) NOT NULL 
);
CREATE TABLE [dbo].[SubCategory]
(
	SubCategoryID INT NOT NULL PRIMARY KEY,
	CategoryID INT NOT NULL,
	Name VARCHAR(100) NOT NULL,
	CONSTRAINT SubCategory_CategoryID_FK
	FOREIGN KEY (CategoryID) REFERENCES Category (CategoryID)
);
CREATE TABLE [dbo].[Product]
(
	ProductID INT NOT NULL PRIMARY KEY,
	ProductSubCategoryID INT, 
	Name NVARCHAR(100) NOT NULL, 
	Price MONEY NOT NULL,
	CONSTRAINT Product_ProductSubCategoryID_FK
	FOREIGN KEY (ProductSubCategoryID) REFERENCES SubCategory(SubCategoryID)
);
CREATE TABLE [dbo].[Sales] 
(
	SalesID INT NOT NULL PRIMARY KEY,
	ProductID INT NOT NULL, 
	CustomerID INT NOT NULL, 
	Orderdate DATETIME NOT NULL,
	CONSTRAINT Sales_CustomerID_FK
	FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
	CONSTRAINT Sales_ProductID_FK
	FOREIGN KEY (ProductID) REFERENCES [dbo].[Product](ProductID)
);