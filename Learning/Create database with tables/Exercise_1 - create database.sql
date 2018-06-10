
/*

Database should have schema like below:

	- Customer
	  
		Attributes: [ attrib name | data type | integrity constraint | key ]
		- CustomerID | INT | NOT NULL | PRIMARY KEY
		- AddressID | INT | NULL | FOREIGN KEY - constraint to Address  
		- CustomerName | VARCHAR(50) | NOT NULL

		HINT! - Sales.Customers

	- Address
		
		Attributes: 
		- AddressID | INT | NOT NULL | PRIMARY KEY
		- AddressLine1 | NVARCHAR(60) | NOT NULL
		- AddressLine2 | NVARCHAR(60) | NOT NULL
		- City | NVARCHAR(30) | NOT NULL
		- PostalCode | NVARCHAR(15) | NOT NULL

		HINT! - Person.Address

	- Sales

		Attributes: 
		- SalesID | INT | NOT NULL | PRIMARY KEY 
		- ProductID | INT | NOT NULL | FOREIGN KEY - constraint to Product
		- CustomerID | INT | NOT NULL | FOREIGN KEY - constraint to Customer
		- OrderDate | DATETIME | NOT NULL  

		HINT! - Sales.SalesOrderHeader

	- Product
		
		Attributes: 
		- ProductID | INT | NOT NULL | PRIMARY KEY 
		- ProductSubCategoryID | INT | NULL | FOREIGN KEY - constraint to SubCategory
		- Name | VARCHAR(100) | NOT NULL
		- Price | MONEY | NOT NULL

		HINT! - Production.Product

	- Category

		Attributes: 
		- CategoryID | INT | NOT NULL | PRIMARY KEY 
		- Name | VARCHAR(100) | NOT NULL

		HINT! - Production.ProductCategory

	- SubCategory

		Attributes: 
		- SubCategoryID | INT | NOT NULL | PRIMARY KEY 
		- CategoryID | INT | NOT NULL | FOREIGN KEY - constraint to Category
		- Name | VARCHAR(100) | NOT NULL

		HINT! - Production.ProductSubCategory

Goal of this task:

1. Create your own database called: MyDatabase
2. Do creation script for tables including drop & create mechanism. That means the ability to recreate script infinitely.
3. Ensure data integrity by doing constraints like (NULLs, primary/foreign keys, data types)
4. Populate tables using AdventureWorks database. Relevant attribs are stored in tables pointed in HINT!. 
Your task is to find attribs and write basic SELECT statement to retrive proper data. 

If you have futher queries, feel free to ping me!
		
*/

