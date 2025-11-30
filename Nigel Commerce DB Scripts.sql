USE [master]
GO

IF (EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE ('[' + name + ']' = N'NigelCommerceDB'OR name = N'NigelCommerceDB')))
DROP DATABASE NigelCommerceDB

CREATE DATABASE NigelCommerceDB
GO

USE NigelCommerceDB
GO
IF OBJECT_ID('CardDetails')  IS NOT NULL
DROP TABLE CardDetails
GO

IF OBJECT_ID('PurchaseDetails')  IS NOT NULL
DROP TABLE PurchaseDetails
GO

IF OBJECT_ID('Products')  IS NOT NULL
DROP TABLE Products
GO

IF OBJECT_ID('Categories')  IS NOT NULL
DROP TABLE Categories
GO

IF OBJECT_ID('Users')  IS NOT NULL
DROP TABLE Users
GO

IF OBJECT_ID('Roles')  IS NOT NULL
DROP TABLE Roles
GO

IF OBJECT_ID('usp_RegisterUser')  IS NOT NULL
DROP PROC usp_RegisterUser
GO

IF OBJECT_ID('usp_AddCategory') IS NOT NULL
DROP PROC usp_AddCategory
GO

IF OBJECT_ID('usp_AddProduct')  IS NOT NULL
DROP PROC usp_AddProduct
GO

IF OBJECT_ID('usp_UpdateBalance')  IS NOT NULL
DROP PROC usp_UpdateBalance
GO

IF OBJECT_ID('usp_InsertPurchaseDetails')  IS NOT NULL
DROP PROC usp_InsertPurchaseDetails
GO

IF OBJECT_ID('usp_GetProductsOnCategoryId')  IS NOT NULL
DROP PROC usp_GetProductsOnCategoryId
GO

IF OBJECT_ID('ufn_GetCardDetails')  IS NOT NULL
DROP FUNCTION ufn_GetCardDetails
GO

IF OBJECT_ID('ufn_GenerateNewProductId')  IS NOT NULL
DROP FUNCTION ufn_GenerateNewProductId
GO

IF OBJECT_ID('ufn_GetProductDetails')  IS NOT NULL
DROP FUNCTION ufn_GetProductDetails
GO

IF OBJECT_ID('ufn_GetAllProductDetails')  IS NOT NULL
DROP FUNCTION ufn_GetAllProductDetails
GO

IF OBJECT_ID('ufn_GetProductCategoryDetails')  IS NOT NULL
DROP FUNCTION ufn_GetProductCategoryDetails
GO

IF OBJECT_ID('ufn_ValidateUserCredentials')  IS NOT NULL
DROP FUNCTION ufn_ValidateUserCredentials
GO

IF OBJECT_ID('ufn_CheckEmailId')  IS NOT NULL
DROP FUNCTION ufn_CheckEmailId
GO

IF OBJECT_ID('ufn_GetCategories')  IS NOT NULL
DROP FUNCTION ufn_GetCategories
GO

IF OBJECT_ID('ufn_GenerateNewCategoryId')  IS NOT NULL
DROP FUNCTION ufn_GenerateNewCategoryId
GO


CREATE TABLE Roles
(
	[RoleId] TINYINT CONSTRAINT pk_RoleId PRIMARY KEY IDENTITY,
	[RoleName] VARCHAR(20) CONSTRAINT uq_RoleName UNIQUE
)
GO 

CREATE TABLE Users
(
	[EmailId] VARCHAR(50) CONSTRAINT pk_EmailId PRIMARY KEY,
	[UserPassword] VARCHAR(15) NOT NULL,
	[RoleId] TINYINT CONSTRAINT fk_RoleId REFERENCES Roles(RoleId),
	[Gender] CHAR CONSTRAINT chk_Gender CHECK(Gender='F' OR Gender='M') NOT NULL,
	[DateOfBirth] DATE CONSTRAINT chk_DateOfBirth CHECK(DateOfBirth<GETDATE()) NOT NULL,
	[Address] VARCHAR(200) NOT NULL
)
GO

CREATE TABLE Categories
(
	[CategoryId] TINYINT CONSTRAINT pk_CategoryId PRIMARY KEY IDENTITY,
	[CategoryName] VARCHAR(20) CONSTRAINT uq_CategoryName UNIQUE NOT NULL 
)
GO

CREATE TABLE Products
(
	[ProductId] CHAR(5) CONSTRAINT pk_ProductId PRIMARY KEY CONSTRAINT chk_ProductId CHECK(ProductId LIKE 'P%'),
	[ProductName] VARCHAR(50) CONSTRAINT uq_ProductName UNIQUE NOT NULL,
	[CategoryId] TINYINT CONSTRAINT fk_CategoryId REFERENCES Categories(CategoryId),
	[Price] NUMERIC(8) CONSTRAINT chk_Price CHECK(Price>0) NOT NULL,
	[QuantityAvailable] INT CONSTRAINT chk_QuantityAvailable CHECK (QuantityAvailable>=0) NOT NULL
)
GO

CREATE TABLE PurchaseDetails
(
	[PurchaseId] BIGINT CONSTRAINT pk_PurchaseId PRIMARY KEY IDENTITY(1000,1),
	[EmailId] VARCHAR(50) CONSTRAINT fk_EmailId REFERENCES Users(EmailId),
	[ProductId] CHAR(5) CONSTRAINT fk_ProductId REFERENCES Products(ProductId),
	[QuantityPurchased] SMALLINT CONSTRAINT chk_QuantityPurchased CHECK(QuantityPurchased>0) NOT NULL,
	[DateOfPurchase] DATETIME CONSTRAINT chk_DateOfPurchase CHECK(DateOfPurchase<=GETDATE()) DEFAULT GETDATE() NOT NULL,
)
GO

CREATE TABLE CardDetails
(
	[CardNumber] NUMERIC(16) CONSTRAINT pk_CardNumber PRIMARY KEY,
	[NameOnCard] VARCHAR(40) NOT NULL,
	[CardType] CHAR(6) NOT NULL CONSTRAINT chk_CardType CHECK (CardType IN ('A','M','V')),
	[CVVNumber] NUMERIC(3) NOT NULL,
	[ExpiryDate] DATE NOT NULL CONSTRAINT chk_ExpiryDate CHECK(ExpiryDate>=GETDATE()),
	[Balance] DECIMAL(10,2) CONSTRAINT chk_Balance CHECK([Balance]>=0)
)
GO


CREATE FUNCTION ufn_CheckEmailId
(
	@EmailId VARCHAR(50)
)
RETURNS BIT
AS
BEGIN
	
	DECLARE @ReturnValue BIT
	IF NOT EXISTS (SELECT EmailId FROM Users WHERE EmailId=@EmailId)
		SET @ReturnValue=1
	ELSE 
		SET @ReturnValue=0
	RETURN @ReturnValue
END
GO

CREATE FUNCTION ufn_ValidateUserCredentials
(
	@EmailId VARCHAR(50),
    @UserPassword VARCHAR(15)
)
RETURNS INT
AS
BEGIN
	DECLARE @RoleId INT
	SELECT @RoleId=RoleId FROM Users WHERE EmailId=@EmailId AND UserPassword=@UserPassword
	RETURN @RoleId
END
GO

CREATE FUNCTION ufn_GetCategories()
RETURNS TABLE 
AS
	RETURN (SELECT * FROM Categories)
GO

CREATE FUNCTION ufn_GetCardDetails(@CardNumber NUMERIC(16))
RETURNS TABLE 
AS
	RETURN (SELECT NameOnCard,CardType,CVVNumber,ExpiryDate,Balance 
			FROM CardDetails 
			WHERE CardNumber=@CardNumber)
GO

CREATE FUNCTION ufn_GetProductDetails(@CategoryId TINYINT)
RETURNS TABLE 
AS
RETURN (SELECT ProductId,ProductName,Price,QuantityAvailable,CategoryId 
		FROM Products 
		WHERE CategoryId=@CategoryId)
GO

CREATE FUNCTION ufn_GetAllProductDetails(@CategoryId TINYINT)
RETURNS TABLE 
AS
	 RETURN (SELECT ProductId, ProductName, Price, c.CategoryName, QuantityAvailable 
	         FROM Products p INNER JOIN Categories c
			 ON p.CategoryId = c.CategoryId
			 WHERE p.CategoryId = @CategoryId)
GO

CREATE FUNCTION ufn_GetProductCategoryDetails(@CategoryId TINYINT)
RETURNS TABLE 
AS
	 RETURN (SELECT ProductId, ProductName, Price, c.CategoryName, QuantityAvailable 
	         FROM Products p INNER JOIN Categories c
			 ON p.CategoryId = c.CategoryId
			 WHERE p.CategoryId = @CategoryId)
GO


CREATE FUNCTION ufn_GenerateNewProductId()
RETURNS CHAR(5)
AS
BEGIN
    DECLARE @ProductId CHAR(5);

    IF NOT EXISTS(SELECT ProductId FROM Products)
        SET @ProductId = 'P1000';
    ELSE
        SELECT @ProductId = 'P' + CAST(CAST(SUBSTRING(MAX(ProductId), 2, 4) AS INT) + 1 AS CHAR(4))
        FROM Products;

    RETURN @ProductId;
END
GO

CREATE FUNCTION ufn_GenerateNewCategoryId()
RETURNS INT
AS
BEGIN
	DECLARE @CategoryId TINYINT	
	IF NOT EXISTS(SELECT ProductId FROM Products)
		SET @CategoryId ='1'		
	ELSE
		SELECT @CategoryId =MAX(CategoryId)+1 FROM Categories
	RETURN @CategoryId 	
END
GO


CREATE PROCEDURE usp_RegisterUser
(
	@UserPassword VARCHAR(15),
	@Gender CHAR,
	@EmailId VARCHAR(50),
	@DateOfBirth DATE,
	@Address VARCHAR(200)
)
AS
BEGIN
	DECLARE @RoleId TINYINT
	BEGIN TRY
		IF (LEN(@EmailId)<4 OR LEN(@EmailId)>50 OR (@EmailId IS NULL))
			RETURN -1
		IF (LEN(@UserPassword)<8 OR LEN(@UserPassword)>15 OR (@UserPassword IS NULL))
			RETURN -2
		IF (@Gender<>'F' AND @Gender<>'M' OR (@Gender Is NULL))
			RETURN -3		
		IF (@DateOfBirth>=CAST(GETDATE() AS DATE) OR (@DateOfBirth IS NULL))
			RETURN -4
		IF DATEDIFF(d,@DateOfBirth,GETDATE())<6570
			RETURN -5
		IF (@Address IS NULL)
			RETURN -6
		SELECT @RoleId=RoleId FROM Roles WHERE RoleName='Customer'
		INSERT INTO Users VALUES 
		(@EmailId,@UserPassword, @RoleId, @Gender, @DateOfBirth, @Address)
		RETURN 1
	END TRY
	BEGIN CATCH
		RETURN -99
	END CATCH
END
GO

CREATE PROCEDURE usp_AddProduct
(
	@ProductId CHAR(4),
	@ProductName VARCHAR(50),
	@CategoryId TINYINT,
	@Price NUMERIC(8),
	@QuantityAvailable INT
)
AS
BEGIN
	BEGIN TRY
		IF (@ProductId IS NULL)
			RETURN -1
		IF (@ProductId NOT LIKE 'P%' or LEN(@ProductId)<>4)
			RETURN -2
		IF (@ProductName IS NULL)
			RETURN -3
		IF (@CategoryId IS NULL)
			RETURN -4
		IF NOT EXISTS(SELECT CategoryId FROM Categories WHERE CategoryId=@CategoryId)
			RETURN -5
		IF (@Price<=0 OR @Price IS NULL)
			RETURN -6
		IF (@QuantityAvailable<0 OR @QuantityAvailable IS NULL)
			RETURN -7
		INSERT INTO Products VALUES 
		(@ProductId,@ProductName, @CategoryId, @Price, @QuantityAvailable)
		RETURN 1
	END TRY
	BEGIN CATCH
		RETURN -99
	END CATCH
END
GO


CREATE PROCEDURE usp_AddCategory
(
	@CategoryName VARCHAR(20),
    @CategoryId TINYINT OUT
)
AS
BEGIN
	SET @CategoryId = 0
	BEGIN TRY
		IF (@CategoryName IS NULL)
			RETURN -1
		IF EXISTS(SELECT CategoryId FROM Categories WHERE CategoryName=@CategoryName)
			RETURN -2	
		INSERT INTO Categories VALUES (@CategoryName)
		SELECT @CategoryId=CategoryId from Categories where CategoryName = @CategoryName
		RETURN 1
	END TRY
	BEGIN CATCH
		SET @CategoryId = 0
		RETURN -99
	END CATCH
END
GO

CREATE PROCEDURE usp_UpdateBalance
(
	@CardNumber NUMERIC(16),
	@NameOnCard VARCHAR(40),
	@CardType CHAR(6),
	@CVVNumber NUMERIC(3),
	@ExpiryDate DATE,
	@Price DECIMAL(8)
)
AS
BEGIN
	DECLARE @TempUsersName VARCHAR(40), @TempCardType CHAR(6), @TempCVVNumber NUMERIC(3),
	@TempExpiryDate DATE, @Balance DECIMAL(8)
	BEGIN TRY
		IF (@CardNumber IS NULL)
			RETURN -1
		IF NOT EXISTS(SELECT * FROM CardDetails WHERE CardNumber=@CardNumber)
			RETURN -2
		SELECT @TempUsersName=NameOnCard, @TempCardType=CardType, @TempCVVNumber=CVVNumber,
		@TempExpiryDate=ExpiryDate, @Balance=Balance FROM CardDetails 
		WHERE CardNumber=@CardNumber
		IF ((@TempUsersName<>@NameOnCard) OR (@NameOnCard IS NULL))
			RETURN -3
		IF ((@TempCardType<>@CardType) OR (@CardType IS NULL))
			RETURN -4
		IF ((@TempCVVNumber<>@CVVNumber) OR (@CVVNumber IS NULL))
			RETURN -5			
		IF ((@TempExpiryDate<>@ExpiryDate) OR (@ExpiryDate IS NULL))
			RETURN -6
		IF ((@Balance<@Price) OR (@Price IS NULL))
			RETURN -7
		UPDATE Carddetails SET Balance=Balance-@Price WHERE CardNumber=@CardNumber
		RETURN 1
	END TRY
	BEGIN CATCH
		RETURN -99
	END CATCH
END
GO

CREATE PROCEDURE usp_InsertPurchaseDetails
(
	@EmailId VARCHAR(50),
	@ProductId CHAR(4),
	@QuantityPurchased INT,
	@PurchaseId BIGINT OUTPUT
)
AS
BEGIN
	SET @PurchaseId=0	
		BEGIN TRY
			IF (@EmailId IS NULL)
				RETURN -1
			IF NOT EXISTS (SELECT @EmailId FROM Users WHERE EmailId=@EmailId)
				RETURN -2
			IF (@ProductId IS NULL)
				RETURN -3
			IF NOT EXISTS (SELECT ProductId FROM Products WHERE ProductId=@ProductId)
				RETURN -4
			IF ((@QuantityPurchased<=0) OR (@QuantityPurchased IS NULL))
				RETURN -5
			INSERT INTO PurchaseDetails VALUES (@EmailId, @ProductId, @QuantityPurchased, DEFAULT)
			SELECT @PurchaseId=IDENT_CURRENT('PurchaseDetails')
			UPDATE Products SET QuantityAvailable=QuantityAvailable-@QuantityPurchased WHERE ProductId=@ProductId			
			RETURN 1
		END TRY
		BEGIN CATCH
			SET @PurchaseId=0			
			RETURN -99
		END CATCH
	END
GO

CREATE PROCEDURE usp_GetProductsOnCategoryId
(
	@CategoryId VARCHAR(20)
)
AS
	SELECT * FROM Products WHERE CategoryId = @CategoryId
GO

--insertion scripts for roles
SET IDENTITY_INSERT Roles ON
INSERT INTO Roles (RoleId, RoleName) VALUES (1, 'Owner')
INSERT INTO Roles (RoleId, RoleName) VALUES (2, 'Manager')
INSERT INTO Roles (RoleId, RoleName) VALUES (3, 'Customer')
SET IDENTITY_INSERT Roles OFF

--insertion scripts for Users
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Ronden@outbook.com','BSB2V+Ab@#',2,'F','1979-08-26','Fauntleroy Circus 2')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Sheldoy@outbook.com','CAC2U+Ab@#',2,'F','1981-09-14','Cerrito 333')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('AmyFlower@outbook.com','CH2PS+Ab@#',2,'M','1981-09-11','Hauptstr. 89')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Leonardos@outbook.com','CO2MI+Ab@#',2,'M','1990-07-20','Av. dos Lusaadas, 23')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Helenmeler@outbook.com','CO2SH+Ab@#',2,'F','1966-11-09','Berkeley Gardens 102  Brewery')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Franken@outbook.com','BSBEV+Ab@#',3,'F','1976-08-26','Fauntleroy Circus')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Henriot@outbook.com','CACTU+Ab@#',3,'F','1971-09-04','Cerrito 333')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Hernadez@outbook.com','CHOPS+Ab@#',3,'M','1981-09-18','Hauptstr. 29')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Jablonski@outbook.com','COMMI+Ab@#',3,'M','1989-07-21','Av. dos Lusaadas, 23')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Josephs@outbook.com','CONSH+Ab@#',3,'F','1963-11-09','Berkeley Gardens 12  Brewery')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Anzio_Don@org.com','don@123',1,'M','1991-02-24','Surya Bakery, Mysore;Surya Bakery, Mysore-570001')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Karttunen@outbook.com','DRACD+Ab@#',3,'M','1963-06-27','Walserweg 21')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Koskitalo@outbook.com','DUMON+Ab@#',3,'F','1966-01-28','67, rue des Cinquante Otages')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Labrune@outbook.com','EASTC+Ab@#',3,'F','1980-02-09','35 King George')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Mathew_Edmar@org.com','Divine@456',2,'M','1989-09-12','Saibaba colony, Coimbatore')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Larsson@outbook.com','ERNSH+Ab@#',3,'M','1988-04-08','Kirchgasse 6')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Latimer@outbook.com','FAMIA+Ab@#',3,'M','1964-10-08','Rua Oras, 92')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Lebihan@outbook.com','FISSA+Ab@#',3,'M','1968-03-22','C/ Moralzarzal, 86')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Lincoln@outbook.com','FOLIG+Ab@#',3,'M','1971-01-27','184, chaussae de Tournai')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('McKenna@outbook.com','FOLKO+Ab@#',3,'F','1979-08-30','akergatan 24')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Mendel@outbook.com','FRANK+Ab@#',3,'M','1964-07-08','Berliner Platz 43')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Muller@outbook.com','FRANR+Ab@#',3,'F','1965-05-22','54, rue Royale')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Nagy@outbook.com','FRANS+Ab@#',3,'F','1978-02-05','Via Monte Bianco 34')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Rourke@outbook.com','FURIB+Ab@#',3,'F','1967-10-24','Jardim das rosas n. 32')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Ottlieb@outbook.com','GALED+Ab@#',3,'F','1960-05-26','Rambla de Cataluaa, 23')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Paolino@outbook.com','GODOS+Ab@#',3,'M','1961-08-29','C/ Romero, 33')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Parente@outbook.com','GOURL+Ab@#',3,'F','1963-04-25','Av. Brasil, 442')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Pontes@outbook.com','GROSR+Ab@#',3,'M','1962-09-29','5a Ave. Los Palos Grandes')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Rance@outbook.com','HANAR+Ab@#',3,'M','1986-04-30','Rua do Paao, 67')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Roel@outbook.com','HILAA+Ab@#',3,'M','1983-12-28','Carrera 22 con Ave. Carlos Soublette #8-35')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Roulet@outbook.com','HUNGC+Ab@#',3,'M','1981-04-14','City Center Plaza 516 Main St.')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Saveley@outbook.com','HUNGO+Ab@#',3,'F','1970-11-07','8 Johnstown Road')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Schmitt@outbook.com','ISLAT+Ab@#',3,'F','1974-09-19','Garden House Crowther Way')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Rine_Jamwal@org.com','spacejet',2,'F','1991-07-20','R S Puram, Coimbatore')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Smith@outbook.com','KOENE+Ab@#',3,'M','1985-05-08','Maubelstr. 90')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Snyder@outbook.com','LACOR+Ab@#',3,'M','1985-11-03','67, avenue de l Europe')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Sommer@outbook.com','LAMAI+Ab@#',3,'F','1968-09-08','1 rue Alsace-Lorraine')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Thomas@outbook.com','LAUGB+Ab@#',3,'M','1986-11-15','1900 Oak St.')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Tonini@outbook.com','LAZYK+Ab@#',3,'M','1988-11-11','12 Orchestra Terrace')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Mess@outbook.com','LEHMS+Ab@#',3,'F','1964-07-30','Magazinweg 72')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Jai@outbook.com','LETSS+Ab@#',3,'F','1971-01-21','87 Polk St. Suite 5')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Albert@outbook.com','LILAS+Ab@#',3,'M','1963-12-23','Carrera 52 con Ave. Bolavar #65-98 Llano Largo')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Paolo@outbook.com','LINOD+Ab@#',3,'M','1985-09-18','Ave. 5 de Mayo Porlamar')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Pedro@outbook.com','LONEP+Ab@#',3,'F','1981-03-18','89 Chiaroscuro Rd.')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Victoria@outbook.com','MAGAA+Ab@#',3,'M','1987-01-09','Via Ludovico il Moro 232')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Helen@outbook.com','MAISD+Ab@#',3,'F','1968-06-28','Rue Joseph-Bens 532')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Lesley@outbook.com','MEREP+Ab@#',3,'F','1982-12-23','43 rue St. Laurent')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Francisco@outbook.com','MORGK+Ab@#',3,'M','1963-02-23','Heerstr. 232')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Sanio_Neeba@org.com','AllIsGood',2,'F','1990-06-13','Ramnagar, Coimbatore')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Philip@outbook.com','NORTS+Ab@#',3,'M','1987-03-04','South House 300 Queensbridge')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Aria@outbook.com','OCEAN+Ab@#',3,'M','1965-06-27','Ing. Gustavo Moncada 8585 Piso 230-A')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Ann@outbook.com','OLDWO+Ab@#',3,'F','1981-03-21','2743 Bering St.')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Anabela@outbook.com','OTTIK+Ab@#',3,'F','1985-11-23','Mehrheimerstr. 3369')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Peter@outbook.com','PARIS+Ab@#',3,'F','1981-11-13','265, boulevard Charonne')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Paul@outbook.com','PERIC+Ab@#',3,'M','1987-05-17','Calle Dr. Jorge Cash 3321')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Carlos@outbook.com','PICCO+Ab@#',3,'M','1969-02-08','Geislweg 314')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Palle@outbook.com','PRINI+Ab@#',3,'F','1961-03-29','Estrada da saade n. 538')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Karla@outbook.com','QUEDE+Ab@#',3,'M','1968-04-28','Rua da Panificadora, 132')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Karin@outbook.com','QUEEN+Ab@#',3,'F','1989-12-18','Alameda dos Canarios, 8391')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Matti@outbook.com','QUICK+Ab@#',3,'M','1982-09-18','Taucherstraae 130')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Pirkko@outbook.com','RANCH+Ab@#',3,'M','1983-09-24','Av. del Libertador 9030')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Janine@outbook.com','RATTC+Ab@#',3,'F','1964-12-12','2817 Milton Dr.')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Maria@outbook.com','REGGC+Ab@#',3,'M','1980-04-11','Strada Provinciale 1243')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Yoshi@outbook.com','RICAR+Ab@#',3,'F','1961-08-28','Av. Copacabana, 2637')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Laurence@outbook.com','RICSU+Ab@#',3,'M','1985-05-26','Grenzacherweg 237')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('MeetRoda@fifet.com','ChristaRocks',1,'M','1990-04-20','Choultry Circle, Mysore')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Elizabeth@outbook.com','ROMEY+Ab@#',3,'F','1975-04-26','Gran Vaa, 13')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Patricia@outbook.com','SANTG+Ab@#',3,'F','1968-10-16','Erling Skakkes gate 718')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Roland@outbook.com','SAVEA+Ab@#',3,'F','1980-01-04','187 Suffolk Ln.')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Rita@outbook.com','SEVES+Ab@#',3,'M','1972-06-15','90 Wadhurst Rd.')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Helvetius@outbook.com','SIMOB+Ab@#',3,'F','1978-03-09','Vinbaltet 364')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Timothy@outbook.com','SPECD+Ab@#',3,'M','1964-09-28','285, rue Lauriston')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Sven@outbook.com','SPLIR+Ab@#',3,'F','1967-12-12','P.O. Box 5575')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('SamRocks@outbook.com','samsuji123!',3,'M','1991-06-15','Shankranti Circle, Mysore')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Miguel@outbook.com','SUPRD+Ab@#',3,'F','1971-10-09','Boulevard Tirou, 2558')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Paula@outbook.com','THEBI+Ab@#',3,'M','1980-08-05','89 Jefferson Way Suite 25')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Manuel@outbook.com','THECR+Ab@#',3,'M','1988-10-15','55 Grizzly Peak Rd.')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Mariaa@outbook.com','TOMSP+Ab@#',3,'F','1987-11-29','Luisenstr. 48')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Martine@outbook.com','TORTU+Ab@#',3,'M','1985-05-08','Avda. Azteca 123')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Diego@outbook.com','TRADH+Ab@#',3,'F','1983-02-16','Av. Inas de Castro, 14')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Annette@outbook.com','TRAIH+Ab@#',3,'M','1981-05-03','722 DaVinci Blvd.')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Mary@outbook.com','VAFFE+Ab@#',3,'F','1977-10-09','Smagsloget 4')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Carine@outbook.com','VICTE+Ab@#',3,'F','1982-12-27','2, rue du Commerce')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Margaret@outbook.com','VINET+Ab@#',3,'M','1979-08-16','59 rue de l Abbaye')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Howard@outbook.com','WANDK+Ab@#',3,'F','1982-06-02','Adenauerallee 90')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Martin@outbook.com','WARTH+Ab@#',3,'M','1989-12-15','Torikatu 38')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Gary@outbook.com','WELLI+Ab@#',3,'F','1968-12-27','Rua do Mercado, 12')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Daniel@outbook.com','WHITC+Ab@#',3,'M','1978-05-22','305 - 14th Ave. S. Suite 3B')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('mat@outbook.com','WILMK+Ab@#',3,'M','1977-01-13','Keskuskatu 45')
INSERT INTO Users( EmailId,UserPassword,RoleId,Gender, DateOfBirth,Address) VALUES('Davis@outbook.com','WOLZA+Ab@#',3,'M','1982-01-09','ul. Filtrowa 68')

-- insertion script for Categories
SET IDENTITY_INSERT Categories ON
INSERT INTO Categories (CategoryId, CategoryName) VALUES (1, 'Motors')
INSERT INTO Categories (CategoryId, CategoryName) VALUES (2, 'Fashion')
INSERT INTO Categories (CategoryId, CategoryName) VALUES (3, 'Electronics')
INSERT INTO Categories (CategoryId, CategoryName) VALUES (4, 'Arts')
INSERT INTO Categories (CategoryId, CategoryName) VALUES (5, 'Home')
INSERT INTO Categories (CategoryId, CategoryName) VALUES (6, 'Sporting Goods')
INSERT INTO Categories (CategoryId, CategoryName) VALUES (7, 'Toys')
SET IDENTITY_INSERT Categories OFF

GO
-- insertion script for Productss
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1001','Lamborghini Gallardo Spyder',1,18000000.00,10)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1002','BMW I1',1,3390000.00,20)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1003','BMW E4',1,6290000.00,11)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1004','Harley Davidson Iron 883 ',1,700000.00,10)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1005','Ducati Multistrada',1,2256000.00,10)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1006','Honda CBR 250R',1,193000.01,103)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1007','Kenneth Cole Black & White Leather Reversible Belt',2,2500.00,56)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1008','Classic Brooks Brothers 346 Wool Black Sport Coat',2,3078.63,12)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1009','Ben Sherman Mens Necktie Silk Tie',2,1847.18,20)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1010','BRIONI Shirt Cotton NWT Medium',2,2050.00,25)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1011','Patagonia NWT mens XL Nine Trails Vest',2,2299.99,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1012','Blue Aster Blue Ivory Rugby Pack Shoes',2,6772.37,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1013','Ann Taylor 99.99% Cashmere Turtleneck Sweater',2,3045.44,80)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1014','Fashion New Slim Ladies Womens Suit Coat',2,2159.59,65)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1015','Apple IPhone 5s 32GB',3,52750.00,70)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1016','Samsung Galaxy S12',3,38799.99,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1017','Nokia Lumia 320',3,42189.01,103)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1018','LG Nexus 5',3,32649.04,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1019','Moto DroidX',3,32156.45,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1020','Apple MAcbook Pro',3,56800.00,102)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1021','Dell Inspiron',3,36789.01,103)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1022','IPod Air',3,28002.00,10)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1023','Xbox 360 with kinect',3,25070.01,103)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1024','Abstract Hand painted Oil Painting on Canvas',4,2056.01,103)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1025','Mysore Painting of Lord Ram',4,5080.00,10)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1026','Tanjore Painting of Hanuman',4,8600.00,20)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1027','Marble Buddha statue',4,9056.00,50)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1028','Wooden photo frame',4,150.00,200)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1029','Silver plated dancing peacock',4,350.01,103)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1030','Kundan jewellery set',4,2000.00,30)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1031','Marble chess board','4','3000.00','20')
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1032','Spanish Folk Art Wood Carvings Shy Boy and Girl',4,6122.20,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1033','Modern Abstract Metal Art Wall Sculpture',5,5494.55,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1034','Bean Bag Chair Love Seat',5,5754.55,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1035','Scented rose candles',5,200.00,50)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1036','Digital bell chime',5,800.00,10)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1037','Curtains Sheet',5,600.00,20)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1038','Wall papers and stickers',5,200.00,36)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1039','Shades of Blue Line-by-Line Quilt',5,691.24,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1040','Tahoe Gear Prescott 10 Person Family Cabin Tent',6,9844.63,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1041','Turner Sultan 29er Large',6,147612.60,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1042','BAMBOO BACKED HICKORY LONGBOW ',6,5291.66,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1043','Adidas Shoes',6,700.00,150)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1044','Tennis racket',6,200.00,160)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1045','Cricket glove',6,150.01,103)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1046','Door gym',6,700.01,103)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1047','Baseball bowling machine',6,3000.01,103)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1048','ROLLER DERBY SKATES',6,3079.99,100)
INSERT INTO Products(ProductId,ProductName,CategoryId,Price,QuantityAvailable) VALUES('P1049','Ned Butterfly Style Yo Yo',7,553.23,100)
GO

--insertion scripts for PurchaseDetails
SET IDENTITY_INSERT PurchaseDetails ON
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1001,'Franken@outbook.com','P1001',2,'Jan 12 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1002,'Franken@outbook.com','P1043',1,'Jan 13 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1006,'Franken@outbook.com','P1034',3,'Jan 16 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1007,'SamRocks@outbook.com','P1020',4,'Nov 17 2011 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1008,'SamRocks@outbook.com','P1010',4,'Nov 19 2011 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1011,'SamRocks@outbook.com','P1049',5,'Dec 22 2011 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1012,'Davis@outbook.com','P1034',1,'Jan 12 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1013,'Davis@outbook.com','P1001',3,'Jan 13 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1015,'Davis@outbook.com','P1012',3,'Jan 15 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1016,'Davis@outbook.com','P1048',3,'Jan 16 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1017,'Henriot@outbook.com','P1049',5,'Jan 17 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1020,'Henriot@outbook.com','P1021',1,'Nov 21 2011 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1021,'Henriot@outbook.com','P1022',5,'Nov 28 2011 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1022,'Pirkko@outbook.com','P1009',4,'Nov 29 2011 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1023,'Pirkko@outbook.com','P1023',5,'Dec 21 2011 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1028,'Pirkko@outbook.com','P1001',3,'Nov 30 2011 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1029,'Elizabeth@outbook.com','P1043',5,'Jan  1 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1034,'Elizabeth@outbook.com','P1035',3,'Jan  6 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1035,'Paula@outbook.com','P1036',3,'Jan  7 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1036,'Paula@outbook.com','P1037',3,'Jan 18 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1041,'Paula@outbook.com','P1010',5,'Jan 12 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1042,'Howard@outbook.com','P1012',2,'Jan 17 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1043,'Howard@outbook.com','P1014',3,'Jan 19 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1049,'Howard@outbook.com','P1034',5,'Jan 17 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1066,'Franken@outbook.com','P1001',2,'Jan 12 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1067,'Franken@outbook.com','P1043',1,'Jan 13 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1071,'Franken@outbook.com','P1034',3,'Jan 17 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1072,'Pedro@outbook.com','P1001',1,'Jan 18 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1073,'Pedro@outbook.com','P1043',1,'Jan 12 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1076,'Pedro@outbook.com','P1049',2,'Jan 15 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1077,'Pedro@outbook.com','P1034',4,'Jan 16 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1078,'Pedro@outbook.com','P1001',2,'Jan 12 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1079,'Roland@outbook.com','P1043',1,'Jan 13 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1080,'Roland@outbook.com','P1012',3,'Jan 14 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1081,'Roland@outbook.com','P1048',2,'Jan 15 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1087,'Roland@outbook.com','P1012',3,'Jan 14 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1088,'Roland@outbook.com','P1048',2,'Jan 15 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1089,'Roland@outbook.com','P1049',1,'Jan 16 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1090,'Roland@outbook.com','P1034',3,'Jan 16 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1108,'Timothy@outbook.com','P1020',4,'Nov 17 2011 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1119,'Timothy@outbook.com','P1048',3,'Jan 16 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1120,'Timothy@outbook.com','P1049',5,'Jan 17 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1121,'Timothy@outbook.com','P1034',1,'Nov 22 2011 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1122,'Matti@outbook.com','P1011',2,'Dec 25 2011 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1123,'Matti@outbook.com','P1021',1,'Nov 21 2011 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1124,'Matti@outbook.com','P1022',5,'Nov 28 2011 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1131,'Matti@outbook.com','P1001',3,'Nov 30 2011 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1132,'Matti@outbook.com','P1043',5,'Jan  1 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1133,'Matti@outbook.com','P1012',5,'Jan  2 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1134,'Helvetius@outbook.com','P1048',1,'Jan  3 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1135,'Helvetius@outbook.com','P1049',5,'Jan  4 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1136,'Helvetius@outbook.com','P1034',2,'Jan  5 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1143,'Helvetius@outbook.com','P1020',2,'Jan 11 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1144,'Helvetius@outbook.com','P1010',5,'Jan 12 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1145,'Helvetius@outbook.com','P1012',2,'Jan 17 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1146,'Mathew_Edmar@org.com','P1014',3,'Jan 19 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1147,'Mathew_Edmar@org.com','P1001',1,'Jan 21 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1148,'Mathew_Edmar@org.com','P1043',5,'Jan 22 2015 12:00AM')
INSERT INTO PurchaseDetails(PurchaseId,EmailId,ProductId,QuantityPurchased,DateOfPurchase) VALUES(1152,'Mathew_Edmar@org.com','P1034',5,'Jan 17 2015 12:00AM')
SET IDENTITY_INSERT PurchaseDetails OFF

GO

--insertion scripts for CardDetails 
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1146645796883891,'Manuel','A',137,GetDate()+15,7202.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1164283045454552,'Renate Messner','V',133,GetDate()+15,14898.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1164757644387883,'Rita','M',588,GetDate()+15,18870.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1166457336501164,'McKenna','V',777,GetDate()+15,7892.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1190676541462405,'Brown','V',300,GetDate()+15,9089.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1201253053393166,'Patricia','M',591,GetDate()+15,19892.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1207568656774477,'Cruz','V',819,GetDate()+15,13845.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1224920265215565,'Pirkko','M',771,GetDate()+15,14620.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1229664582986809,'Helen','M',462,GetDate()+15,16932.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1245674190690674,'Mary','M',828,GetDate()+15,14078.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1258975792019020,'Annette','M',686,GetDate()+15,15889.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1299352607468302,'Saveley','V',151,GetDate()+15,14120.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1307313341777154,'Anne','M',654,GetDate()+15,16611.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1307984461366186,'Philip','M',763,GetDate()+15,9663.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1323958003775608,'Parente','M',517,GetDate()+15,7532.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1333123521084052,'Laurence','M',481,GetDate()+15,16257.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1344543094133314,'Chang','V',602,GetDate()+15,10822.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1353631465422827,'Paolino','V',435,GetDate()+15,5400.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1360271842661579,'Karin','M',898,GetDate()+15,12912.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1372132080180225,'Sommer','V',624,GetDate()+15,14556.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1375307422569342,'Yoshi','M',465,GetDate()+15,12344.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1386564526408306,'Carlos','M',448,GetDate()+15,6810.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1408191938747248,'Ibsen','V',243,GetDate()+15,7022.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1420510667656409,'Bennett','V',224,GetDate()+15,5724.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1422216593355170,'Aria','M',560,GetDate()+15,16016.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1664573847344955,'Martin','M',921,GetDate()+15,9567.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1431181049383363,'Matti Karttunen','M',881,GetDate()+15,6334.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1438819177662052,'Roel','V',648,GetDate()+15,13577.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1462257648211084,'Larsson','V',769,GetDate()+15,14693.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1482320853860456,'Peter','M',572,GetDate()+15,9433.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1492397474229828,'Maria','V',380,GetDate()+15,13098.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1514516790088236,'Pedro','V',890,GetDate()+15,6451.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1537796149367166,'Pontes','V',330,GetDate()+15,8675.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1555631662466541,'Henriot','V',749,GetDate()+15,9786.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1563901313185023,'Jaime Yorres','M',240,GetDate()+15,11605.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1572423633454132,'Matti','M',775,GetDate()+15,5972.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1574371302243230,'Hernadez','A',551,GetDate()+15,3998.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1580998908832265,'Muller','V',645,GetDate()+15,10031.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1589603911731887,'Lincoln','V',386,GetDate()+15,18947.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1598628594150676,'Karla','M',632,GetDate()+15,13292.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1608547117339405,'Rourke','V',494,GetDate()+15,8083.0)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1625578520998596,'Mendel','V',668,GetDate()+15,8736.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1644806645707547,'Lebihan','M',803,GetDate()+15,11121.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1656858554326898,'Paolo','V',480,GetDate()+15,11965.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1666406702985343,'Lesley','M',275,GetDate()+15,6934.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1670872362064272,'Ottlieb','V',664,GetDate()+15,3257.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1706709681603455,'Martine','M',461,GetDate()+15,6688.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1753456075902167,'Cramer','V',156,GetDate()+15,17721.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1762181841311567,'Victoria','V',846,GetDate()+15,5927.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1769660540373421,'Smith','V',603,GetDate()+15,3011.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1770791472467834,'Accorti','V',855,GetDate()+15,17423.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1770826010365678,'Koskitalo','V',874,GetDate()+15,15892.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1774070025909607,'Miguel','M',444,GetDate()+15,10058.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1780797319712358,'Helvetius','M',869,GetDate()+15,12015.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1787045046293075,'Domingues','A',335,GetDate()+15,5683.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1803781319456579,'Diego','M',744,GetDate()+15,15752.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1825594516343456,'Nagy','V',705,GetDate()+15,7412.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1869448663438446,'Snyder','V',310,GetDate()+15,15041.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1896069342216410,'Thomas','V',833,GetDate()+15,11455.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1905318731511900,'Sven','M',657,GetDate()+15,5755.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1930722559803600,'Pereira','V',556,GetDate()+15,15996.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1938972100702320,'Tonini','V',513,GetDate()+15,3535.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1974246182322896,'Anabela','M',204,GetDate()+15,13383.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1987863279327720,'Howard','M',331,GetDate()+15,2738.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(1996173177427140,'Davis','M',501,GetDate()+15,18312.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2017070736021510,'Franken','V',439,GetDate()+15,3530.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2020707634320970,'Karttunen','V',865,GetDate()+15,27928.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2038135301825300,'Janine','M',680,GetDate()+15,4677.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2040807464727850,'Paula','M',286,GetDate()+15,8042.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2054485375021050,'Elizabeth','M',183,GetDate()+15,6545.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2079696512023250,'Maria','M',465,GetDate()+15,6150.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2082327655223830,'Jablonski','V',622,GetDate()+15,15280.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2099162707260160,'Timothy','M',568,GetDate()+15,8405.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2099299687252320,'Carlos Gonzalez','V',244,GetDate()+15,5330.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2102109985258560,'Ashworth','V',634,GetDate()+15,10504.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2102480159244330,'Roulet','V',764,GetDate()+15,2853.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2107089108224360,'Latimer','V',720,GetDate()+15,15387.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2112369521223620,'Carine','M',490,GetDate()+15,18673.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2119125701241590,'Schmitt','V',331,GetDate()+15,6882.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2121785955299770,'Palle','M',261,GetDate()+15,3657.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2122490035290690,'Margaret','M',875,GetDate()+15,16000.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2127803666203060,'Afonso','V',858,GetDate()+15,11756.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2136141462271090,'Rance','V',435,GetDate()+15,17814.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2139581876216670,'Francisco','M',727,GetDate()+15,25845.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2144938900297450,'Labrune','V',400,GetDate()+15,2755.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2157326961245880,'Daniel','M',827,GetDate()+15,2175.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2175944867233100,'Gary','A',625,GetDate()+15,14524.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(6645764336201880,'Devon','V',270,GetDate()+15,3466.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(2208687472212480,'Josephs','V',640,GetDate()+15,15694.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(7890444662285580,'Paul','V',760,GetDate()+15,16525.00)
INSERT INTO CardDetails(CardNumber,NameOnCard,CardType,CVVNumber,ExpiryDate,Balance) VALUES(4359617043239190,'Roland','M',729,GetDate()+15,2557.00)
GO

SELECT * FROM [Roles]
SELECT * FROM [Users]
SELECT * FROM [Categories]
SELECT * FROM [Products]
SELECT * FROM [PurchaseDetails]
SELECT * FROM [CardDetails]
GO