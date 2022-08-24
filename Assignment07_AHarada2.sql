--*************************************************************************--
-- Title: Assignment07
-- Author: AHarada
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01,RRoot,Created File
-- 2022-08-22, AHarada, Completed File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_AHarada')
	 Begin 
	  Alter Database [Assignment07DB_AHarada] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_AHarada;
	 End
	Create Database Assignment07DB_AHarada;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_AHarada;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

--Look at all the data
/*Select ProductName, UnitPrice
From vProducts

--Format Price
Select ProductName, Format(UnitPrice, 'C', 'en-US') as 'USD'
From vProducts*/

--Order results
Select ProductName, Format(UnitPrice, 'C', 'en-US') as 'USD'
From vProducts
Order By ProductName

go

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.

--Look at all data
/*Select * From vCategories
Select * From vProducts

--Columns we want
Select CategoryName From vCategories
Select ProductName, CategoryID, UnitPrice From vProducts

--Join tables
Select CategoryName, ProductName, UnitPrice
From vProducts as P
Inner Join vCategories as C
On C.CategoryID = P.CategoryID

--Format to USD
Select CategoryName, ProductName, Format(UnitPrice, 'C', 'en-US') as 'USD'
From vProducts as P
Inner Join vCategories as C
On C.CategoryID = P.CategoryID*/

--Order results
Select CategoryName, ProductName, Format(UnitPrice, 'C', 'en-US') as 'USD'
From vProducts as P
Inner Join vCategories as C
On C.CategoryID = P.CategoryID
Order By CategoryName, ProductName

go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

--Look at all data
/*Select * From vProducts
Select * From vInventories

--Columns we want and join tables
Select ProductName, InventoryDate, Count as InventoryCount
From vInventories as I
Inner Join vProducts as P
On P.ProductID = I.ProductID

--Format date column
Select 
ProductName, 
DateName(mm, InventoryDate) + ', ' + Datename(yy, InventoryDate) as InventoryDate, 
Count as InventoryCount
From vInventories as I
Inner Join vProducts as P
On P.ProductID = I.ProductID

--Order results
Select 
ProductName, 
DateName(mm, InventoryDate) + ', ' + Datename(yy, InventoryDate) as InventoryDate, 
Count as InventoryCount
From vInventories as I
Inner Join vProducts as P
On P.ProductID = I.ProductID
Order By ProductName, InventoryDate*/

--Use function in Order to order by date (not alphabetical)
Select 
ProductName, 
DateName(mm, InventoryDate) + ', ' + Datename(yy, InventoryDate) as InventoryDate, 
Count as InventoryCount
From vInventories as I
Inner Join vProducts as P
On P.ProductID = I.ProductID
Order By ProductName, Format(InventoryDate, 'd', 'en-US')

go

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

--Join Tables
/*Select ProductName, InventoryDate, Count as InventoryCount
From vProducts as P
Inner Join vInventories as I
On I.ProductID = P.ProductID

--Format date
Select 
ProductName, 
DateName(mm, InventoryDate) + ', ' + Datename(yy, InventoryDate) as InventoryDate,  
Count as InventoryCount
From vProducts as P
Inner Join vInventories as I
On I.ProductID = P.ProductID

--Order Results
Select 
ProductName, 
DateName(mm, InventoryDate) + ', ' + Datename(yy, InventoryDate) as InventoryDate,  
Count as InventoryCount
From vProducts as P
Inner Join vInventories as I
On I.ProductID = P.ProductID
Order By ProductName, Format(InventoryDate, 'd', 'en-US')

go*/

--Create View and add Top
Create View vProductInventories
As
	Select Top 1000
	ProductName, 
	DateName(mm, InventoryDate) + ', ' + Datename(yy, InventoryDate) as InventoryDate,  
	Count as InventoryCount
	From vProducts as P
	Inner Join vInventories as I
	On I.ProductID = P.ProductID
	Order By ProductName, Format(InventoryDate, 'd', 'en-US')

go

-- Check that it works: Select * From vProductInventories;
go

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

--Look at all the data
/*Select * From vInventories

--Join Tables, Summarize count
Select CategoryName, InventoryDate, Sum(Count) Over(Partition By CategoryName)
From vCategories as C
Join vProducts as P
On C.CategoryID = P.CategoryID
Join vInventories as I
On I.ProductID = P.ProductID

--Group using Select Distinct, not ordering by Month
Select Distinct
CategoryName, 
DateName(mm, InventoryDate) + ', ' + Datename(yy, InventoryDate) as InventoryDate, 
Sum(Count) Over(Partition By InventoryDate, CategoryName) as InventoryCountByCategory
From vCategories as C
Join vProducts as P
On C.CategoryID = P.CategoryID
Join vInventories as I
On I.ProductID = P.ProductID
Order By CategoryName, InventoryDate

--Attempt another method to get grouping, adding extra column
Select Distinct
CategoryName, 
[InventoryDate] = Convert(varchar(50), InventoryDate), (DateName(mm, InventoryDate) + ', ' + Datename(yy, InventoryDate)),
Sum(Count) Over(Partition By InventoryDate, CategoryName) as InventoryCountByCategory
From vCategories as C
Join vProducts as P
On C.CategoryID = P.CategoryID
Join vInventories as I
On I.ProductID = P.ProductID
Order By CategoryName, InventoryDate

--Simplify, just figuring out date part
Select Distinct
[InventoryDate] = Format(InventoryDate, 'MMMMM, yyyy', 'en-US') 
From
vInventories
Order By InventoryDate

--Try without Select Distinct
Select
[InventoryDate] = DateName(mm, InventoryDate) + ', ' + Datename(yy, InventoryDate)
From
vInventories
Group By InventoryDate
Order By Cast(DateName(mm, InventoryDate) + ', ' + Datename(yy, InventoryDate) as date) 

--Finally figured it out
Select 
CategoryName, 
[InventoryDate] = DateName(mm, InventoryDate) + ', ' + Datename(yy, InventoryDate),
[InventoryCountByCategory] = Sum(I.Count)
From vInventories as I
Join vProducts as P
On I.ProductID = P.ProductID
Join vCategories as C
On P.CategoryID = C.CategoryID
Group By CategoryName, DateName(mm, InventoryDate) + ', ' + Datename(yy, InventoryDate)
Order By CategoryName, Cast(DateName(mm, InventoryDate) + ', ' + Datename(yy, InventoryDate) as date)*/
go

--Create View
Create View vCategoryInventories
As
	Select Top 1000
	CategoryName, 
	[InventoryDate] = DateName(mm, InventoryDate) + ', ' + Datename(yy, InventoryDate),
	[InventoryCountByCategory] = Sum(I.Count)
	From vInventories as I
	Join vProducts as P
		On I.ProductID = P.ProductID
	Join vCategories as C
		On P.CategoryID = C.CategoryID
	Group By CategoryName, DateName(mm, InventoryDate) + ', ' + Datename(yy, InventoryDate)
	Order By CategoryName, Cast(DateName(mm, InventoryDate) + ', ' + Datename(yy, InventoryDate) as date)

go
-- Check that it works: Select * From vCategoryInventories;
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

--Show relevant columns
/*
Select * From vProductInventories

--Show Previous Month values
Select 
PreviousMonthCount = Lag(Sum(InventoryCount)) Over(Order By Month(InventoryDate)) 
From vProductInventories
Group By InventoryDate

--Show all columns
Select 
ProductName,
InventoryDate,
InventoryCount,
PreviousMonthCount = Lag(Sum(InventoryCount)) Over(Order By Month(InventoryDate)) 
From vProductInventories
Group By ProductName, InventoryDate, InventoryCount

--Order by date
Select 
ProductName,
InventoryDate,
InventoryCount,
PreviousMonthCount = Lag(Sum(InventoryCount)) Over(Order By Month(InventoryDate)) 
From vProductInventories
Group By ProductName, InventoryDate, InventoryCount
Order By ProductName, Cast(DateName(mm, InventoryDate) + ', ' + Datename(yy, InventoryDate) as date)

--Remove Null if January, added order by Product Name in Lag
Select 
ProductName,
InventoryDate,
InventoryCount,
PreviousMonthCount = IIF(Month(InventoryDate) = 1, 0, Lag(Sum(InventoryCount)) Over(Order By ProductName, Month(InventoryDate)))
From vProductInventories
Group By ProductName, InventoryDate, InventoryCount
Order By ProductName, Cast(DateName(mm, InventoryDate) + ', ' + Datename(yy, InventoryDate) as date) */

go

Create View vProductInventoriesWithPreviousMonthCounts
As
	Select Top 1000
	ProductName,
	InventoryDate,
	InventoryCount,
	PreviousMonthCount = IIF(Month(InventoryDate) = 1, 0, Lag(Sum(InventoryCount)) Over(Order By ProductName, Month(InventoryDate)))
	From vProductInventories
	Group By ProductName, InventoryDate, InventoryCount
	Order By ProductName, Cast(DateName(mm, InventoryDate) + ', ' + Datename(yy, InventoryDate) as date) 

go

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
go

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.
-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!

--Show all data
/*
Select * From vProductInventoriesWithPreviousMonthCounts

--Show relevant counts
Select 
InventoryCount,
PreviousMonthCount,
KPI = Case
	When InventoryCount > PreviousMonthCount Then 1
	When InventoryCount = PreviousMonthCount Then 0
	When InventoryCount < PreviousMonthCount Then -1
	End
From vProductInventoriesWithPreviousMonthCounts

--Combine with other columns
Select 
ProductName,
InventoryDate,
InventoryCount,
PreviousMonthCount,
CountVsPreviousCountKPI = Case
	When InventoryCount > PreviousMonthCount Then 1
	When InventoryCount = PreviousMonthCount Then 0
	When InventoryCount < PreviousMonthCount Then -1
	End
From vProductInventoriesWithPreviousMonthCounts */
go

Create View vProductInventoriesWithPreviousMonthCountsWithKPIs
As
	Select 
	ProductName,
	InventoryDate,
	InventoryCount,
	PreviousMonthCount,
	CountVsPreviousCountKPI = Case
		When InventoryCount > PreviousMonthCount Then 1
		When InventoryCount = PreviousMonthCount Then 0
		When InventoryCount < PreviousMonthCount Then -1
		End
	From vProductInventoriesWithPreviousMonthCounts



-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

Create or Alter Function fProductInventoriesWithPreviousMonthCountsWithKPIs(@KPI int)
Returns Table
As
    Return (Select
			ProductName,
			InventoryDate,
			InventoryCount,
			PreviousMonthCount,
			CountVsPreviousCountKPI
            FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
			Where CountVsPreviousCountKPI = @KPI)
Go



/* Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/
go

/***************************************************************************************/