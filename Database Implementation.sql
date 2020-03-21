/*
														Project: Hospital Management
														Team Member: Anwesh Praharaj


	A. CREATE DATABASE
	B. CREATE SYMMETRIC ENCRYPTION
	C. DROP CONSTARINT ( FK , UNIQUE, DEFAULT ) 
	D. DROP STORE PROCEDURE
	E. DROP USER DEFINE TABLE TYPE ( UDT )
	F. DROP AND CREATE FUNCTIONS
	G. DROP AND CREATE TABLE
	I. CREATE CONSTARINT ( FK , UNIQUE, DEFAULT )
	J. CREATE USER DEFINE TABLE TYPE ( UDT )
	K. CREATE STORE PROCEDURE
	L. CREATE TRIGGER
	M. DATA INSERT SCRIPTS ( Using SSMS Import wizard , Store Procedure and Insert SQL scripts ) 
	N. CREATE VIEW

NOTE:- 
	1. Used Column Data Encryption for Password Column in dbo.Employee Table
	2. Table-level CHECK Constraints based on a function
		- Add a table check constraint on dbo.EmployeeDetails to insert data in case age of the employee between 19 and 60 .
			 CONSTRAINT CHECK_EmployeeDetails_Age CHECK (dbo.fn_CalculateAge([DateOfBirth]) BETWEEN 19 AND 60)
		- Add a table check constraint on dbo.PatientAppointment  to insert only employeeID which role is doctor.
			 CONSTRAINT CHECK_PatientAppoitment_Doctor CHECK ([dbo].[fn_GetEmployeeRole]([EmployeeID]) = 'Doctor'),
	3. Computed Columns based on a function
		- add PatientRegNo as Computed column in dbo.patient by calling a function fn_generatePatientRegNo . This function has a logic to generate Reg number.
			[PatientRegNo] AS ([dbo].[fn_GeneratePatientRegNo]([FirstName],[LastName],[DateOfBirth])),
		- add Comment as Computed column in dbo.PatientLabReport by calling a function fn_getcommentforLabReport . Depending on Lab result this function
		  will determinde whether the result is positive or Negative.
		  [Comment] AS (dbo.fn_GetCommentsForLabReport([LabTestID], [TestValue]))

	4. Views for Report:- 
		- [dbo].[vw_GetDiseaseCount] --- This will return Number of Patient for each disease
		- [dbo].[vw_GetPatientDetails] --This will return Patient Details. 
		- [dbo].[vw_GetEmployeeDetails] -- This will return Employee Details.

	5. Triggers:- 
		- tr_UpdateLabReportBilling : This trigger will insert billing information in dbo.PatientBilling table depend on the Labtest from dbo.PatientLabReport Table.
		- tr_UpdateAttendantBilling : This trigger will insert billing information in dbo.PatientBilling table depend on the Attendant from dbo.PatientAttendant Table.
*/

/************************************************************************************************/
--- A. CREATE DATABASE
/************************************************************************************************/
IF DB_ID('HospitalManagementSystem') IS NULL
BEGIN
	CREATE DATABASE HospitalManagementSystem
END

GO
/***********************************************************************************************/
---- B. CREATE SYMMETRIC ENCRYPTION
/***********************************************************************************************/
USE HospitalManagementSystem
CREATE MASTER KEY
ENCRYPTION BY PASSWORD = 'Bp5PynEH3T;2gzJd';

-- Create certificate to protect symmetric key
CREATE CERTIFICATE HospitalManagementCertificate
WITH SUBJECT = 'HospitalManagement Certificate',
EXPIRY_DATE = '2026-10-31';

-- Create symmetric key to encrypt data
CREATE SYMMETRIC KEY HospitalManagementSymmetricKey
WITH ALGORITHM = AES_128
ENCRYPTION BY CERTIFICATE HospitalManagementCertificate;

-- Open symmetric key
OPEN SYMMETRIC KEY HospitalManagementSymmetricKey
DECRYPTION BY CERTIFICATE HospitalManagementCertificate;


GO
/*------------------------------------------------------------------------------
C. DROP CONSTARINT ( FK , UNIQUE, DEFAULT ) 
--------------------------------------------------------------------------------*/
USE HospitalManagementSystem
GO
IF (OBJECT_ID('FK_EmployeeDetails_Employee_IDX', 'F') IS NOT NULL)
BEGIN
		ALTER TABLE dbo.EmployeeDetails  DROP  CONSTRAINT [FK_EmployeeDetails_Employee_IDX]
END
IF (OBJECT_ID('FK_EmployeeDetails_Role_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.EmployeeDetails  DROP  CONSTRAINT [FK_EmployeeDetails_Role_IDX]
END
IF (OBJECT_ID('FK_EmployeeDepartment_Employee_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.EmployeeDepartment  DROP  CONSTRAINT [FK_EmployeeDepartment_Employee_IDX]
END
IF (OBJECT_ID('FK_EmployeeDepartment_Department_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.EmployeeDepartment  DROP  CONSTRAINT [FK_EmployeeDepartment_Department_IDX]
END
IF (OBJECT_ID('FK_PatientInsurance_Patient_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.PatientInsurance  DROP  CONSTRAINT [FK_PatientInsurance_Patient_IDX]
END
IF (OBJECT_ID('FK_PatientRegister_Patient_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.PatientRegister  DROP  CONSTRAINT [FK_PatientRegister_Patient_IDX]
END
IF (OBJECT_ID('FK_PatientRegister_PatientInsurance_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.PatientRegister  DROP  CONSTRAINT [FK_PatientRegister_PatientInsurance_IDX]
END
IF (OBJECT_ID('FK_PatientBilling_PatientRegister_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.PatientBilling  DROP  CONSTRAINT [FK_PatientBilling_PatientRegister_IDX]
END
IF (OBJECT_ID('FK_PatientBilling_PatientAddress_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.PatientBilling  DROP  CONSTRAINT [FK_PatientBilling_PatientAddress_IDX]
END
IF (OBJECT_ID('FK_PatientLabReport_PatientRegister_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.PatientLabReport  DROP  CONSTRAINT [FK_PatientLabReport_PatientRegister_IDX]
END
IF (OBJECT_ID('FK_PatientLabReport_LabTest_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.PatientLabReport  DROP  CONSTRAINT [FK_PatientLabReport_LabTest_IDX]
END
IF (OBJECT_ID('FK_PatientDisease_PatientRegister_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.PatientDisease  DROP  CONSTRAINT [FK_PatientDisease_PatientRegister_IDX]
END
IF (OBJECT_ID('FK_PatientDisease_Disease_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.PatientDisease  DROP  CONSTRAINT [FK_PatientDisease_Disease_IDX]
END
IF (OBJECT_ID('FK_PatientAppoitment_Patient_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.PatientAppointment  DROP  CONSTRAINT [FK_PatientAppoitment_Patient_IDX]
END
IF (OBJECT_ID('FK_PatientAppoitment_Employee_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.PatientAppointment  DROP  CONSTRAINT [FK_PatientAppoitment_Employee_IDX]
END
IF (OBJECT_ID('FK_PatientAttendant_PatientRegister_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.PatientAttendant  DROP  CONSTRAINT [FK_PatientAttendant_PatientRegister_IDX]
END
IF (OBJECT_ID('FK_PatientAttendant_Employee_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.PatientAttendant  DROP  CONSTRAINT [FK_PatientAttendant_Employee_IDX]
END
IF (OBJECT_ID('FK_EmployeeAddressMapping_EmployeeDetails_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.EmployeeAddressMapping  DROP  CONSTRAINT [FK_EmployeeAddressMapping_EmployeeDetails_IDX]
END
IF (OBJECT_ID('FK_EmployeeAddressMapping_AddressType_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.EmployeeAddressMapping  DROP  CONSTRAINT [FK_EmployeeAddressMapping_AddressType_IDX]
END
IF (OBJECT_ID('FK_EmployeeAddressMapping_Address_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.EmployeeAddressMapping  DROP  CONSTRAINT [FK_EmployeeAddressMapping_Address_IDX]
END
IF (OBJECT_ID('FK_PatientAddressMapping_Patient_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.PatientAddressMapping  DROP  CONSTRAINT [FK_PatientAddressMapping_Patient_IDX]
END
IF (OBJECT_ID('FK_PatientAddressMapping_AddressType_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.PatientAddressMapping  DROP  CONSTRAINT [FK_PatientAddressMapping_AddressType_IDX]
END
IF (OBJECT_ID('FK_PatientAddressMapping_Address_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.PatientAddressMapping  DROP  CONSTRAINT [FK_PatientAddressMapping_Address_IDX]
END
IF (OBJECT_ID('FK_Feedback_Patient_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.Feedback DROP  CONSTRAINT [FK_Feedback_Patient_IDX] 
END
IF (OBJECT_ID('FK_Feedback_Employee_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.Feedback  DROP CONSTRAINT [FK_Feedback_Employee_IDX] 
END
IF (OBJECT_ID('FK_Employee_CreatedBy_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.employee  DROP CONSTRAINT [FK_Employee_CreatedBy_IDX]
END
IF (OBJECT_ID('FK_PatientAppointment_CreatedBy_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.PatientAppointment  DROP CONSTRAINT FK_PatientAppointment_CreatedBy_IDX
END
IF (OBJECT_ID('FK_PatientRegister_CreatedBy_IDX', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.PatientRegister  DROP CONSTRAINT FK_PatientRegister_CreatedBy_IDX
END

IF (OBJECT_ID('UQ_EmployeeDetails_EmployeeID', 'UQ') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.EmployeeDetails DROP CONSTRAINT UQ_EmployeeDetails_EmployeeID
END
IF (OBJECT_ID('UQ_Address', 'UQ') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.Address DROP CONSTRAINT UQ_Address
END
--IF (OBJECT_ID('UQ_Patient_PatientRegNo', 'UQ') IS NOT NULL)
--BEGIN
--	ALTER TABLE dbo.Patient DROP CONSTRAINT UQ_Patient_PatientRegNo
--END
IF (OBJECT_ID('UQ_PatientRegister_PatientID_AdmittedON', 'UQ') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.PatientRegister DROP CONSTRAINT UQ_PatientRegister_PatientID_AdmittedON
END
IF (OBJECT_ID('UQ_PatientAddressMapping', 'UQ') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.PatientAddressMapping DROP CONSTRAINT UQ_PatientAddressMapping
END
IF (OBJECT_ID('UQ_PatientLabReport', 'UQ') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.PatientLabReport DROP CONSTRAINT UQ_PatientLabReport
END
IF (OBJECT_ID('UQ_EmployeeAddressMapping', 'UQ') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.EmployeeAddressMapping DROP CONSTRAINT UQ_EmployeeAddressMapping
END
IF (OBJECT_ID('DF_Feedback_CreatedON', 'D') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.Feedback DROP CONSTRAINT DF_Feedback_CreatedON
END
IF (OBJECT_ID('DF_Employee_CreatedON', 'D') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.Employee DROP CONSTRAINT DF_Employee_CreatedON
END
IF (OBJECT_ID('DF_PatientAppointment_CreatedON', 'D') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.PatientAppointment DROP CONSTRAINT DF_PatientAppointment_CreatedON
END
IF (OBJECT_ID('DF_PatientRegister_CreatedON', 'D') IS NOT NULL)
BEGIN
	ALTER TABLE dbo.PatientRegister DROP CONSTRAINT DF_PatientRegister_CreatedON
END




GO
/*************************************************************************************
---- D. DROP PROCEDURE
***************************************************************************************/

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_InsertEmployeeDetails')
BEGIN
	DROP PROCEDURE dbo.usp_InsertEmployeeDetails
END

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_UpdateEmployeeAddress')
BEGIN
	DROP PROCEDURE dbo.usp_UpdateEmployeeAddress
END

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_AddNewPatient')
BEGIN
	DROP PROCEDURE dbo.usp_AddNewPatient
END

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_RegisterNewAppoitment')
BEGIN
	DROP PROCEDURE dbo.usp_RegisterNewAppoitment
END

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_PatientCheckin')
BEGIN
	DROP PROCEDURE dbo.usp_PatientCheckin
END
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_AddPatientLabReport')
BEGIN
	DROP PROCEDURE dbo.usp_AddPatientLabReport
END
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_UpdatePatientAddress')
BEGIN
	DROP PROCEDURE dbo.usp_UpdatePatientAddress
END
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_RegisterFeedback')
BEGIN
	DROP PROCEDURE dbo.usp_RegisterFeedback
END
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'OpenKeys')
BEGIN
	DROP PROCEDURE [dbo].[OpenKeys]
END
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_PatientPayment')
BEGIN
	DROP PROCEDURE [dbo].[usp_PatientPayment]
END


GO
/***********************************************************************************************
---- E. DROP USER DEFINE TABLE TYPE ( UDT )
************************************************************************************************/
IF type_id('UDT_HospitalEmployee') IS NOT NULL
BEGIN
        DROP TYPE [dbo].[UDT_HospitalEmployee]
END

IF type_id('UDT_AddressInput') IS NOT NULL
BEGIN
        DROP TYPE [dbo].[UDT_AddressInput]
END
IF type_id('UDT_Patient') IS NOT NULL
BEGIN
		DROP TYPE [dbo].[UDT_Patient]
END
IF type_id('UDT_Attendant') IS NOT NULL
BEGIN
		DROP TYPE [dbo].[UDT_Attendant]
END
IF type_id('UDT_LabTestDetails') IS NOT NULL
BEGIN
		DROP TYPE [dbo].[UDT_LabTestDetails]
END
GO
/******************************************************************************************
F. DROP AND CREATE FUNCTIONS
*******************************************************************************************/

IF object_id(N'fn_FormatPhone', N'FN') IS NOT NULL
BEGIN
    DROP FUNCTION [dbo].[fn_FormatPhone]
END
GO
CREATE  function [dbo].[fn_FormatPhone](@Phone varchar(30)) 
returns varchar(30)
As
Begin
declare @FormattedPhone varchar(30)

set     @Phone = replace(@Phone, '.', '-') --alot of entries use periods instead of dashes
set @FormattedPhone =
    Case
      When isNumeric(@Phone) = 1 Then
        case
          when len(@Phone) = 10 then '('+substring(@Phone, 1, 3)+')'+ ' ' +substring(@Phone, 4, 3)+ '-' +substring(@Phone, 7, 4)
          when len(@Phone) = 7  then substring(@Phone, 1, 3)+ '-' +substring(@Phone, 4, 4)
          else @Phone
        end
      When @phone like '[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9]' Then '('+substring(@Phone, 1, 3)+')'+ ' ' +substring(@Phone, 5, 3)+ '-' +substring(@Phone, 8, 4)
      When @phone like '[0-9][0-9][0-9] [0-9][0-9][0-9] [0-9][0-9][0-9][0-9]' Then '('+substring(@Phone, 1, 3)+')'+ ' ' +substring(@Phone, 5, 3)+ '-' +substring(@Phone, 9, 4)
      When @phone like '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' Then '('+substring(@Phone, 1, 3)+')'+ ' ' +substring(@Phone, 5, 3)+ '-' +substring(@Phone, 9, 4)
      Else @Phone
    End
return  @FormattedPhone
END
GO 
---SELECT dbo.fn_CalculateAge('1990-01-18')
--- Drop Table because of CHECK constaint.
IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'dbo.EmployeeDetails') and 
OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
		DROP TABLE dbo.EmployeeDetails
END
IF object_id(N'fn_CalculateAge', N'FN') IS NOT NULL
BEGIN
    DROP FUNCTION [dbo].[fn_CalculateAge]
END
GO
CREATE FUNCTION dbo.fn_CalculateAge
(
  @BirthDate datetime
)
RETURNS INT
AS
BEGIN
	DECLARE @CurrentDate DATETIME = GETDATE()
	IF @BirthDate > @CurrentDate
	RETURN 0

	DECLARE @Age int
	SELECT @Age = DATEDIFF(YY, @BirthDate, @CurrentDate) - 
	  CASE WHEN(
		(MONTH(@BirthDate)*100 + DAY(@BirthDate)) >
		(MONTH(@CurrentDate)*100 + DAY(@CurrentDate))
	  ) THEN 1 ELSE 0 END

	RETURN @Age

END
GO
---- Need to drop the table because it was used as computed column.
IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'dbo.Patient') and 
OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
		DROP TABLE dbo.Patient
END
IF object_id(N'fn_GeneratePatientRegNo', N'FN') IS NOT NULL
BEGIN
    DROP FUNCTION [dbo].[fn_GeneratePatientRegNo]
END
GO
CREATE  FUNCTION [dbo].[fn_GeneratePatientRegNo]
(@FirstName varchar(30), @LastName VARCHAR(30) , @DOB DATETIME) 
RETURNS VARCHAR(30)
AS
BEGIN
		DECLARE @RegNumber VARCHAR(30)

		SET @RegNumber = CONCAT(
								LTRIM(RTRIM(LEFT(@FirstName,3))),
								LTRIM(RTRIM(RIGHT(@LastName,3))),
								CAST(DATEPART(MM,@DOB) AS VARCHAR(2)),
								CAST(DATEPART(DD,@DOB) AS VARCHAR(2))
								--SUBSTRING(REPLACE((select NewUniqID from dbo.vw_getNewID),'-',''),1,9)
								)
		RETURN @RegNumber
END
GO
IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'dbo.Employee') and 
OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
		DROP TABLE dbo.Employee
END
IF object_id(N'fn_GenerateEmployeeNo', N'FN') IS NOT NULL
BEGIN
    DROP FUNCTION [dbo].[fn_GenerateEmployeeNo]
END
GO
CREATE  FUNCTION [dbo].[fn_GenerateEmployeeNo]
(@EmployeeID INT)
RETURNS VARCHAR(30)
AS
BEGIN
		DECLARE @RegNumber VARCHAR(30)

		SET @RegNumber =  CONCAT('EMP',YEAR(GETDATE()),RIGHT('000'+CAST( @EmployeeID AS VARCHAR(3)),3))

		RETURN @RegNumber
END
GO
--- Need to drop Table because it was reffered as CHECK constaint.
IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'dbo.PatientAppointment') AND OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
		DROP TABLE dbo.PatientAppointment
END
GO
IF object_id(N'fn_GetEmployeeRole', N'FN') IS NOT NULL
BEGIN
    DROP FUNCTION [dbo].[fn_GetEmployeeRole]
END
GO
CREATE FUNCTION [dbo].[fn_GetEmployeeRole]
(@EmployeeID INT)
RETURNS VARCHAR(20)
AS
BEGIN
	 DECLARE @RoleDesc VARCHAR(20)

		SET @RoleDesc =  ( SELECT TOP 1 C.RoleDesc 
				 FROM dbo.Employee A 
				 JOIN dbo.EmployeeDetails B 
					ON A.EmployeeID = B.EmployeeID
				 JOIN dbo.Role C
					ON C.RoleID = B.RoleID
				 WHERE A.EmployeeID = @EmployeeID
				)
		RETURN @RoleDesc
END
GO
IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'dbo.PatientLabReport') and 
OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
		DROP TABLE dbo.PatientLabReport
END
IF object_id(N'fn_GetCommentsForLabReport', N'FN') IS NOT NULL
BEGIN
    DROP FUNCTION [dbo].[fn_GetCommentsForLabReport]
END
GO
CREATE FUNCTION dbo.fn_GetCommentsForLabReport
(
	@TestID INT, @Result VARCHAR(10)
)
RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @Temp_Result INT = CAST(ISNULL(@Result,'0') AS INT)
			,@Output VARCHAR(100)
	
	SELECT @Output = (
		CASE WHEN @Temp_Result >= CAST(MinValue AS INT ) AND @Temp_Result <= CAST(MaxValue AS INT) 
			THEN 'NEGATIVE'
			WHEN @Temp_Result < CAST(MinValue AS INT ) OR @Temp_Result > CAST(MaxValue AS INT) 
			THEN 'POSITIVE'
			ELSE '' END)
	FROM 
	dbo.LabTest
	WHERE LabTestID = @TestID 

	RETURN @Output
END
GO
IF object_id(N'fn_GetLabTestCost', N'FN') IS NOT NULL
BEGIN
    DROP FUNCTION [dbo].[fn_GetLabTestCost]
END
GO
CREATE FUNCTION dbo.fn_GetLabTestCost
(
	@TestID INT
)
RETURNS DECIMAL(8,2)
AS
BEGIN
	DECLARE @Amount DECIMAL(8,2)
	SELECT @Amount = ( CASE WHEN TestName = 'Insulin' THEN 150
							WHEN TestName = 'Immunoglobulin M' THEN 230
							WHEN TestName = 'AFB Blood Culture' THEN 100
							WHEN TestName = 'Blood Pressure' THEN 80
							WHEN TestName = 'Hepatitis A IgG' THEN 96
							WHEN TestName = 'Snake Bite Venom Detection' THEN 50
							WHEN TestName = 'GALA Gene Test' THEN 230
							WHEN TestName = 'EJ antibodies' THEN 300
							WHEN TestName = 'Cancer Gene 1' THEN 100
							WHEN TestName = 'Zika virus PCR' THEN 900
							WHEN TestName = 'R0-52 antibodies' THEN 290
							ELSE 0.00
							END)
	FROM dbo.LabTest
	WHERE LabTestID = @TestID

	RETURN @Amount

END
GO


/***************************************************************************************
----- G. DROP AND CREATE TABLE
*****************************************************************************************/
-- -----------------------------------------------------
-- 1. Table `dbo.Employee`
-- -----------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'dbo.Employee') and 
OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
		DROP TABLE dbo.Employee
END
	CREATE TABLE dbo.Employee (
	  [EmployeeID] INT IDENTITY(1,1) NOT NULL,
	  [EmployeeNumber] AS ([dbo].[fn_GenerateEmployeeNo]([EmployeeID])),
	  [EmailID] VARCHAR(45) NULL,
	  [Password] VARBINARY(250) NULL,
	  [CreatedBy] INT NULL,
	  [CreatedOn] DATETIME NULL,
	  PRIMARY KEY CLUSTERED 
	   (
   		[EmployeeID] ASC
	   )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	   ) ON [PRIMARY]

GO
-- -----------------------------------------------------
-- 2. Table `dbo.Role`
-- -----------------------------------------------------

IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'dbo.Role') and 
OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
		DROP TABLE dbo.Role
END

CREATE TABLE dbo.Role (
  [RoleID] INT IDENTITY(1,1) NOT NULL,
  [RoleDesc] VARCHAR(45) NULL,
  PRIMARY KEY CLUSTERED 
  (
	[RoleID] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]

GO

-- -----------------------------------------------------
-- 3. Table `dbo.EmployeeDetails`
-- -----------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'dbo.EmployeeDetails') and 
OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
		DROP TABLE dbo.EmployeeDetails
END

CREATE TABLE dbo.EmployeeDetails (
  [EmployeeDetailsID] INT IDENTITY(1,1) NOT NULL,
  [EmployeeID] INT NULL,
  [FirstName] VARCHAR(45) NULL,
  [LastName] VARCHAR(45) NULL,
  [DateOfBirth] DATE NULL,
  [Gender] VARCHAR(45) NULL,
  [PhoneNumber] VARCHAR(45) NULL,
  [RoleID] INT NULL,
  [CreatedOn] DATETIME NULL,
  [ModifiedOn] DATETIME NULL,
  CONSTRAINT CHECK_EmployeeDetails_Age CHECK (dbo.fn_CalculateAge([DateOfBirth]) BETWEEN 19 AND 60),
  PRIMARY KEY CLUSTERED 
  (
	[EmployeeDetailsID] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO
-- -----------------------------------------------------
-- 4. Table `dbo.Address`
-- -----------------------------------------------------

IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'dbo.Address') and 
OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
		DROP TABLE dbo.Address
END

CREATE TABLE dbo.Address (
  [AddressID] INT IDENTITY(1,1) NOT NULL,
  [Address1] VARCHAR(45) NULL,
  [Address2] VARCHAR(45) NULL,
  [City] VARCHAR(45) NULL,
  [State] VARCHAR(45) NULL,
  [Country] VARCHAR(10) NULL,
  [Zipcode] VARCHAR(45) NULL,
  [CreatedOn] DATETIME NULL,
  [ModifiedOn] DATETIME NULL,
  PRIMARY KEY CLUSTERED 
  (
	[AddressID] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
GO


-- -----------------------------------------------------
-- 5. Table `dbo.Department`
-- -----------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'dbo.Department') and 
OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
		DROP TABLE dbo.Department
END
CREATE TABLE dbo.Department (
  [DepartmentID] INT IDENTITY(1,1) NOT NULL,
  [DepartmentName] VARCHAR(45) NULL,
  PRIMARY KEY CLUSTERED 
  (
	[DepartmentID] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
GO


-- -----------------------------------------------------
-- 6. Table `dbo.EmployeeDepartment`
-- -----------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'dbo.EmployeeDepartment') and 
OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
		DROP TABLE dbo.EmployeeDepartment
END
CREATE TABLE dbo.EmployeeDepartment (
  [EmployeeID] INT NOT NULL,
  [DepartmentID] INT NOT NULL,
  [IsActive] BIT NULL,
  PRIMARY KEY CLUSTERED 
  (
	[EmployeeID] ASC,
	[DepartmentID] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  
  GO

-- -----------------------------------------------------
-- 7. Table `dbo.Patient`
-- -----------------------------------------------------

IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'dbo.Patient') and 
OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
		DROP TABLE dbo.Patient
END

CREATE TABLE dbo.Patient (
  [PatientID] INT IDENTITY(1,1) NOT NULL,
  [PatientRegNo] AS ([dbo].[fn_GeneratePatientRegNo]([FirstName],[LastName],[DateOfBirth])),
  [FirstName] VARCHAR(45) NULL,
  [LastName] VARCHAR(45) NULL,
  [DateOfBirth] DATE NULL,
  [Gender] VARCHAR(45) NULL,
  [PhoneNumber] VARCHAR(45) NULL,
  [EmailID] VARCHAR(45) NULL,
  [Height] VARCHAR(45) NULL,
  [Weight] VARCHAR(45) NULL,
  [BloodGroup] VARCHAR(45) NULL,
  --[Disease] VARCHAR(45) NULL,
  [CreatedOn] DATETIME NULL,
  [ModifiedOn] DATETIME NULL,
  PRIMARY KEY CLUSTERED 
  (
	[PatientID] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
GO

-- -----------------------------------------------------
-- 8. Table `dbo.PatientInsurance`
-- -----------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'dbo.PatientInsurance') and 
OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
		DROP TABLE dbo.PatientInsurance
END

CREATE TABLE dbo.PatientInsurance (
  [PatientInsuranceID] INT IDENTITY(1,1) NOT NULL,
  [PatientID] INT NOT NULL,
  [ProviderName] VARCHAR(45) NULL,
  [GroupNumber] VARCHAR(45) NULL,
  [InsuranceNumber] VARCHAR(45) NULL,
  [InNetworkCoPay] INT NULL,
  [OutNetworkCoPay] INT NULL,
  [StartDate] DATETIME NULL,
  [EndDate] DATETIME NULL,
  [IsCurrent] BIT NULL,
  [CreatedON] DATETIME NULL,
  [ModifiedON] DATETIME NULL,
  PRIMARY KEY CLUSTERED 
  (
	[PatientInsuranceID] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
GO


-- -----------------------------------------------------
-- 9.Table `dbo.PatientRegister`
-- -----------------------------------------------------

IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'dbo.PatientRegister') and 
OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
		DROP TABLE dbo.PatientRegister
END

CREATE TABLE dbo.PatientRegister (
  [PatientRegisterID] INT IDENTITY(1,1) NOT NULL,
  [PatientID] INT NOT NULL,
  [AdmittedON] DATE NULL,
  [DischargeON] DATE NULL,
  [PatientInsuranceID] INT NULL,
  [CopayType] VARCHAR(30) NULL,
  [RoomNumber] VARCHAR(45) NULL,
  [CreatedBy] INT NULL,
  [CreatedON] DATETIME NULL,
  PRIMARY KEY CLUSTERED 
  (
	[PatientRegisterID] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
GO


-- -----------------------------------------------------
-- 10.Table `dbo.PatientAttendant`
-- -----------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'dbo.PatientAttendant') and 
OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
		DROP TABLE dbo.PatientAttendant
END

CREATE TABLE dbo.PatientAttendant (
  [PatientRegisterID] INT NOT NULL,
  [EmployeeID] INT NOT NULL,
  PRIMARY KEY CLUSTERED 
  (
	[PatientRegisterID] ASC,
	[EmployeeID] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
GO
-- -----------------------------------------------------
-- 11.Table `dbo.AddressType`
-- -----------------------------------------------------

IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'dbo.AddressType') and 
OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
		DROP TABLE dbo.AddressType
END

CREATE TABLE dbo.AddressType (
  [AddressTypeID] INT IDENTITY(1,1) NOT NULL,
  [Type] VARCHAR(45) NULL,
  PRIMARY KEY CLUSTERED 
  (
	[AddressTypeID] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
GO


-- -----------------------------------------------------
-- 12.Table `dbo.PatientAddressMapping`
-- -----------------------------------------------------

IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'dbo.PatientAddressMapping') and 
OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
		DROP TABLE dbo.PatientAddressMapping
END

CREATE TABLE dbo.PatientAddressMapping (
  [PatientAddressMappingID] INT IDENTITY(1,1) NOT NULL,
  [PatientID] INT NULL,
  [AddressTypeID] INT NULL,
  [AddressID] INT NULL,
  [IsActive] BIT NULL,
  [Index] INT NULL,
  [CreatedON] DATETIME NULL,
  [ModifiedON] DATETIME NULL,
  PRIMARY KEY CLUSTERED 
  (
	[PatientAddressMappingID] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
GO
-- -----------------------------------------------------
-- 13.Table `dbo.PatientBilling`
-- -----------------------------------------------------

IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'dbo.PatientBilling') and 
OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
		DROP TABLE dbo.PatientBilling
END

CREATE TABLE dbo.PatientBilling (
  [PatientBillingID] INT IDENTITY(1,1) NOT NULL,
  [PatientRegisterID] INT NOT NULL,
  [TransactionDesc] VARCHAR(45) NOT NULL,
  [Amount] DECIMAL(8,2) NULL,
  [GeneratedDate] DATETIME NULL,
  [Type]	VARCHAR(100) NULL,
  [PatientAddressID] INT NULL,
  [PaymentType] VARCHAR(100) NULL
  PRIMARY KEY CLUSTERED 
  (
	[PatientBillingID] ASC,
	[PatientRegisterID] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]

  GO
-- -----------------------------------------------------
-- 14.Table `dbo.LabTest`
-- -----------------------------------------------------

IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'dbo.LabTest') and 
OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
		DROP TABLE dbo.LabTest
END

	CREATE TABLE dbo.LabTest (
	  [LabTestID] INT IDENTITY(1,1) NOT NULL,
	  [TestName] VARCHAR(45) NULL,
	  [IsActive] BIT NULL,
	  [MinValue] VARCHAR(10) NULL,
	  [MaxValue] VARCHAR(10) NULL,
	  [CalUnit] VARCHAR(30) NULL,
	  PRIMARY KEY CLUSTERED 
	  (
		[LabTestID] ASC
	  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	  ) ON [PRIMARY]

GO 
-- -----------------------------------------------------
-- 15.Table `dbo.PatientLabReport`
-- -----------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'dbo.PatientLabReport') and 
OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
		DROP TABLE dbo.PatientLabReport
END

	CREATE TABLE dbo.PatientLabReport (
	  [PatientLabReportID] INT IDENTITY(1,1) NOT NULL,
	  [PatientRegisterID] INT NOT NULL,
	  [LabTestID] INT NOT NULL,
	  [TestValue] VARCHAR(45) NULL,
	  [Comment] AS (dbo.fn_GetCommentsForLabReport([LabTestID], [TestValue]))
	  PRIMARY KEY CLUSTERED 
	  (
		[PatientLabReportID] ASC
	  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	  ) ON [PRIMARY]

GO
-- -----------------------------------------------------
-- 16.Table `dbo.PatientAppointment`
-- -----------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'dbo.PatientAppointment') and 
OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
		DROP TABLE dbo.PatientAppointment
END

	CREATE TABLE dbo.PatientAppointment (
	  [PatientID] INT NOT NULL,
	  [EmployeeID] INT NOT NULL,
	  [AppoitmentDate] DATETIME NOT NULL,
	  [IsComplete] BIT NULL,
	  [IsCancelled] BIT NULL,
	  [IsNoShow] BIT NULL,
	  [CreatedBy] INT NULL,
	  [CreatedON] DATETIME NULL,
	  CONSTRAINT CHECK_PatientAppoitment_Doctor CHECK ([dbo].[fn_GetEmployeeRole]([EmployeeID]) = 'Doctor'),
	  PRIMARY KEY CLUSTERED 
	  (
		[PatientID] ASC,
		[EmployeeID] ASC,
		[AppoitmentDate] ASC
	  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	  ) ON [PRIMARY]

GO

-- -----------------------------------------------------
-- 17.Table `dbo.Feedback`
-- -----------------------------------------------------

IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'dbo.Feedback') and 
OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
		DROP TABLE dbo.Feedback
END

	CREATE TABLE dbo.Feedback (
	  [FeedbackID] INT IDENTITY(1,1) NOT NULL,
	  [FromPatientID] INT NULL,
	  [ToEmployeeID] INT NULL,
	  [Comment] VARCHAR(45) NULL,
	  [Rating] VARCHAR(45) NULL,
	  [CreatedON] DATETIME NULL,
	  PRIMARY KEY CLUSTERED 
	  (
		[FeedbackID] ASC
	  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	  ) ON [PRIMARY]

GO
-- -----------------------------------------------------
-- 18.Table `dbo.EmployeeAddressMapping`
-- -----------------------------------------------------

IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'dbo.EmployeeAddressMapping') and 
OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
		DROP TABLE dbo.EmployeeAddressMapping
END

	CREATE TABLE dbo.EmployeeAddressMapping (
	  [EmployeeAddressMappingID] INT IDENTITY(1,1) NOT NULL,
	  [EmployeeDetailsID] INT NULL,
	  [AddressTypeID] INT NULL,
	  [AddressID] INT NULL,
	  [IsActive] BIT NULL,
	  [Index] INT NULL,
	  [CreatedON] DATETIME NULL,
	  [ModifiedON] DATETIME NULL,
	  PRIMARY KEY CLUSTERED 
	  (
		[EmployeeAddressMappingID] ASC
	  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	  ) ON [PRIMARY]

GO
-- -----------------------------------------------------
-- 19.Table `dbo.Disease`
-- -----------------------------------------------------

IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'dbo.Disease') and 
OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
		DROP TABLE dbo.Disease
END

	CREATE TABLE dbo.Disease (
	  [DiseaseID] INT IDENTITY(1,1) NOT NULL,
	  [Name] VARCHAR(45) NULL,
	  PRIMARY KEY CLUSTERED 
	  (
		[DiseaseID] ASC
	  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	  ) ON [PRIMARY]
GO
-- -----------------------------------------------------
-- 20.Table `dbo.PatientDisease`
-- -----------------------------------------------------

IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'dbo.PatientDisease') and 
OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
		DROP TABLE dbo.PatientDisease
END

	CREATE TABLE dbo.PatientDisease (
	  [PatientRegisterID] INT NOT NULL,
	  [DiseaseID] INT NOT NULL,
  	  PRIMARY KEY CLUSTERED 
	  (
		[PatientRegisterID] ASC
		,[DiseaseID] ASC
	  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	  ) ON [PRIMARY]

GO

/***********************************************************************************
---	I. CREATE CONSTARINT ( FK , UNIQUE, DEFAULT )
***************************************************************************************/
ALTER TABLE dbo.Employee  WITH CHECK ADD  CONSTRAINT [FK_Employee_CreatedBy_IDX] FOREIGN KEY([CreatedBy])
REFERENCES dbo.Employee (EmployeeID)

ALTER TABLE dbo.PatientAppointment  WITH CHECK ADD  CONSTRAINT [FK_PatientAppointment_CreatedBy_IDX] FOREIGN KEY([CreatedBy])
REFERENCES dbo.Employee (EmployeeID)

ALTER TABLE dbo.PatientRegister  WITH CHECK ADD  CONSTRAINT [FK_PatientRegister_CreatedBy_IDX] FOREIGN KEY([CreatedBy])
REFERENCES dbo.Employee (EmployeeID)

ALTER TABLE dbo.EmployeeDetails  WITH CHECK ADD  CONSTRAINT [FK_EmployeeDetails_Employee_IDX] FOREIGN KEY([EmployeeID])
REFERENCES dbo.Employee (EmployeeID)
ALTER TABLE dbo.EmployeeDetails  WITH CHECK ADD  CONSTRAINT [FK_EmployeeDetails_Role_IDX] FOREIGN KEY([RoleID])
REFERENCES dbo.Role (RoleID)

ALTER TABLE dbo.EmployeeDepartment  WITH CHECK ADD  CONSTRAINT [FK_EmployeeDepartment_Employee_IDX] FOREIGN KEY([EmployeeID])
REFERENCES dbo.Employee (EmployeeID)
ALTER TABLE dbo.EmployeeDepartment  WITH CHECK ADD  CONSTRAINT [FK_EmployeeDepartment_Department_IDX] FOREIGN KEY([DepartmentID])
REFERENCES dbo.Department (DepartmentID)

ALTER TABLE dbo.PatientInsurance  WITH CHECK ADD  CONSTRAINT [FK_PatientInsurance_Patient_IDX] FOREIGN KEY([PatientID])
REFERENCES dbo.Patient (PatientID)

ALTER TABLE dbo.PatientRegister  WITH CHECK ADD  CONSTRAINT [FK_PatientRegister_Patient_IDX] FOREIGN KEY([PatientID])
REFERENCES dbo.Patient (PatientID)
ALTER TABLE dbo.PatientRegister  WITH CHECK ADD  CONSTRAINT [FK_PatientRegister_PatientInsurance_IDX] FOREIGN KEY([PatientInsuranceID])
REFERENCES dbo.PatientInsurance (PatientInsuranceID)

ALTER TABLE dbo.PatientBilling  WITH CHECK ADD  CONSTRAINT [FK_PatientBilling_PatientRegister_IDX] FOREIGN KEY([PatientRegisterID])
REFERENCES dbo.[PatientRegister] ([PatientRegisterID])
ALTER TABLE dbo.PatientBilling  WITH CHECK ADD  CONSTRAINT [FK_PatientBilling_PatientAddress_IDX] FOREIGN KEY([PatientAddressID])
REFERENCES dbo.[PatientAddressMapping] (PatientAddressMappingID)

ALTER TABLE dbo.PatientLabReport  WITH CHECK ADD  CONSTRAINT [FK_PatientLabReport_PatientRegister_IDX] FOREIGN KEY([PatientRegisterID])
REFERENCES dbo.[PatientRegister] ([PatientRegisterID])
ALTER TABLE dbo.PatientLabReport  WITH CHECK ADD  CONSTRAINT [FK_PatientLabReport_LabTest_IDX] FOREIGN KEY([LabTestID])
REFERENCES dbo.LabTest ([LabTestID])

ALTER TABLE dbo.PatientDisease  WITH CHECK ADD  CONSTRAINT [FK_PatientDisease_PatientRegister_IDX] FOREIGN KEY([PatientRegisterID])
REFERENCES dbo.[PatientRegister] ([PatientRegisterID])
ALTER TABLE dbo.PatientDisease  WITH CHECK ADD  CONSTRAINT [FK_PatientDisease_Disease_IDX] FOREIGN KEY([DiseaseID])
REFERENCES dbo.Disease (DiseaseID)

ALTER TABLE dbo.PatientAppointment  WITH CHECK ADD  CONSTRAINT [FK_PatientAppoitment_Patient_IDX] FOREIGN KEY([PatientID])
REFERENCES dbo.[Patient] ([PatientID])
ALTER TABLE dbo.PatientAppointment  WITH CHECK ADD  CONSTRAINT [FK_PatientAppoitment_Employee_IDX] FOREIGN KEY([EmployeeID])
REFERENCES dbo.Employee (EmployeeID)

ALTER TABLE dbo.PatientAttendant  WITH CHECK ADD  CONSTRAINT [FK_PatientAttendant_PatientRegister_IDX] FOREIGN KEY([PatientRegisterID])
REFERENCES dbo.[PatientRegister] ([PatientRegisterID])
ALTER TABLE dbo.PatientAttendant  WITH CHECK ADD  CONSTRAINT [FK_PatientAttendant_Employee_IDX] FOREIGN KEY([EmployeeID])
REFERENCES dbo.Employee (EmployeeID)


ALTER TABLE dbo.EmployeeAddressMapping  WITH CHECK ADD  CONSTRAINT [FK_EmployeeAddressMapping_EmployeeDetails_IDX] FOREIGN KEY([EmployeeDetailsID])
REFERENCES dbo.EmployeeDetails ([EmployeeDetailsID])
ALTER TABLE dbo.EmployeeAddressMapping  WITH CHECK ADD  CONSTRAINT [FK_EmployeeAddressMapping_AddressType_IDX] FOREIGN KEY([AddressTypeID])
REFERENCES dbo.AddressType (AddressTypeID)
ALTER TABLE dbo.EmployeeAddressMapping  WITH CHECK ADD  CONSTRAINT [FK_EmployeeAddressMapping_Address_IDX] FOREIGN KEY([AddressID])
REFERENCES dbo.Address (AddressID)

ALTER TABLE dbo.PatientAddressMapping  WITH CHECK ADD  CONSTRAINT [FK_PatientAddressMapping_Patient_IDX] FOREIGN KEY([PatientID])
REFERENCES dbo.Patient ([PatientID])
ALTER TABLE dbo.PatientAddressMapping  WITH CHECK ADD  CONSTRAINT [FK_PatientAddressMapping_AddressType_IDX] FOREIGN KEY([AddressTypeID])
REFERENCES dbo.AddressType (AddressTypeID)
ALTER TABLE dbo.PatientAddressMapping  WITH CHECK ADD  CONSTRAINT [FK_PatientAddressMapping_Address_IDX] FOREIGN KEY([AddressID])
REFERENCES dbo.Address (AddressID)

ALTER TABLE dbo.Feedback  WITH CHECK ADD  CONSTRAINT [FK_Feedback_Patient_IDX] FOREIGN KEY([FromPatientID])
REFERENCES dbo.Patient ([PatientID])
ALTER TABLE dbo.Feedback  WITH CHECK ADD  CONSTRAINT [FK_Feedback_Employee_IDX] FOREIGN KEY(ToEmployeeID)
REFERENCES dbo.Employee (EmployeeID)

----- Unique Constraint
ALTER TABLE dbo.EmployeeDetails ADD CONSTRAINT UQ_EmployeeDetails_EmployeeID UNIQUE NONCLUSTERED (EmployeeID)
ALTER TABLE dbo.Address ADD CONSTRAINT UQ_Address UNIQUE NONCLUSTERED([Address1],[Address2],[City],[State],[Country],[Zipcode])
--ALTER TABLE dbo.Patient ADD CONSTRAINT UQ_Patient_PatientRegNo UNIQUE NONCLUSTERED(PatientRegNo)
ALTER TABLE dbo.PatientInsurance ADD CONSTRAINT UQ_Patient_PatientRegNo UNIQUE NONCLUSTERED([PatientID],[StartDate],[EndDate],[IsCurrent])
ALTER TABLE dbo.PatientRegister ADD CONSTRAINT UQ_PatientRegister_PatientID_AdmittedON UNIQUE NONCLUSTERED(PatientID,AdmittedON)
ALTER TABLE dbo.PatientAddressMapping ADD CONSTRAINT UQ_PatientAddressMapping UNIQUE NONCLUSTERED([PatientID],[AddressTypeID],[IsActive])
ALTER TABLE dbo.PatientLabReport ADD CONSTRAINT UQ_PatientLabReport UNIQUE NONCLUSTERED([PatientRegisterID],[LabTestID])
ALTER TABLE dbo.EmployeeAddressMapping ADD CONSTRAINT UQ_EmployeeAddressMapping UNIQUE NONCLUSTERED([EmployeeDetailsID],[AddressTypeID],[IsActive])

---- Default Constraint
ALTER TABLE dbo.Feedback ADD CONSTRAINT DF_Feedback_CreatedON DEFAULT getdate() for [CreatedON]
ALTER TABLE dbo.Employee ADD CONSTRAINT DF_Employee_CreatedON DEFAULT getdate() for [CreatedON]
ALTER TABLE dbo.PatientAppointment ADD CONSTRAINT DF_PatientAppointment_CreatedON DEFAULT getdate() for [CreatedON]
ALTER TABLE dbo.PatientRegister ADD CONSTRAINT DF_PatientRegister_CreatedON DEFAULT getdate() for [CreatedON]


GO

/************************************************************************************
--- 	J. CREATE USER DEFINE TABLE TYPE ( UDT )
**************************************************************************************/


CREATE TYPE [dbo].[UDT_HospitalEmployee] AS TABLE(
	-- [EmployeeNumber] VARCHAR(45) NOT NULL,
	 [EmailID] VARCHAR(45) NOT NULL,
	 [Password] VARCHAR(45) NOT NULL,
	 [FirstName] VARCHAR(45) NOT NULL,
	 [LastName] VARCHAR(45) NOT NULL,
	 [DateOfBirth] DATE NOT NULL,
	 [Gender] VARCHAR(45) NOT NULL,
	 [PhoneNumber] VARCHAR(45) NOT NULL,
	 [Role] VARCHAR(100) NULL,
	 [DepartmentName] VARCHAR(100) NULL,
	 [CreatedBy] INT
)


CREATE TYPE [dbo].[UDT_AddressInput] AS TABLE(
	[Address1] VARCHAR(45) NOT NULL,
	[Address2] VARCHAR(45) NULL,
	[City] VARCHAR(45) NOT NULL,
	[State] VARCHAR(45) NOT NULL,
	[Zipcode] VARCHAR(45) NOT NULL,
	[Country] VARCHAR(10) NOT NULL,
	[AddressType] VARCHAR(100) NOT NULL
)

CREATE TYPE [dbo].[UDT_Patient] AS TABLE(
	[FirstName] VARCHAR(45) NULL,
	[LastName] VARCHAR(45) NULL,
	[DateOfBirth] DATE NULL,
	[Gender] VARCHAR(45) NULL,
	[PhoneNumber] VARCHAR(45) NULL,
	[EmailID] VARCHAR(45) NULL,
	[Height] VARCHAR(45) NULL,
	[Weight] VARCHAR(45) NULL,
	[BloodGroup] VARCHAR(45) NULL,
	[Disease] VARCHAR(45) NULL
)
GO
CREATE TYPE [dbo].[UDT_Attendant] AS TABLE(
	[EmployeeID] VARCHAR(45) NULL
)
GO
CREATE TYPE [dbo].[UDT_LabTestDetails] AS TABLE(
	[LabTestID] VARCHAR(45) NULL,
	[Result] VARCHAR(10) NULL
)
GO
/********************************************************************************
--- K. CREATE STORE PROCEDURE
***********************************************************************************/

CREATE PROCEDURE [dbo].[OpenKeys]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        OPEN SYMMETRIC KEY HospitalManagementSymmetricKey
        DECRYPTION BY CERTIFICATE HospitalManagementCertificate
    END TRY
    BEGIN CATCH
		SELECT ERROR_MESSAGE()
    END CATCH
END

GO
CREATE PROCEDURE dbo.usp_InsertEmployeeDetails(
	@EmployeeInfo [dbo].[UDT_HospitalEmployee] READONLY
)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION T1
		EXEC OpenKeys
		DECLARE @RoleID INT
				,@DepartmentID INT
				,@EmployeeID INT
				,@Today DATETIME = GETDATE()
				,@EmployeeNumber VARCHAR(45),@EmailID VARCHAR(45),@Password VARCHAR(45)
				,@FirstName VARCHAR(45),@LastName VARCHAR(45),@DateOfBirth DATE,@Gender VARCHAR(45)
				,@PhoneNumber VARCHAR(45),@Role VARCHAR(100),@DepartmentName VARCHAR(100), @CreatedBy INT

		SELECT [EmailID],[Password],[FirstName],[LastName],[DateOfBirth],[Gender],[PhoneNumber],[Role],[DepartmentName], [CreatedBy]
		INTO #EmployeeInfo
		FROM @EmployeeInfo

		---- Cursor to insert multiple Employee Details.
		DECLARE @EmployeeCursor as CURSOR;

		SET @EmployeeCursor = CURSOR FOR
		SELECT EmailID,[Password],FirstName,LastName,DateOfBirth, Gender,PhoneNumber,[Role] , [DepartmentName],[CreatedBy]
		FROM #EmployeeInfo

		OPEN @EmployeeCursor;
		FETCH NEXT FROM @EmployeeCursor INTO @EmailID,@Password,@FirstName,@LastName,@DateOfBirth, @Gender,@PhoneNumber,@Role,@DepartmentName,@CreatedBy

		WHILE @@FETCH_STATUS = 0
		BEGIN
				SET @EmployeeID = null
				SET @RoleID = (SELECT RoleID FROM dbo.[Role] WHERE RoleDesc = @Role )
				SET @DepartmentID = (SELECT DepartmentID FROM dbo.Department WHERE DepartmentName = @DepartmentName )

				SET @EmployeeID = ( SELECT EmployeeID FROM dbo.Employee WHERE EmailID = @EmailID )
				
				IF(@EmployeeID IS NULL)
				BEGIN
						INSERT INTO dbo.Employee ( EmailID,[Password], CreatedBy)
						VALUES (@EmailID , EncryptByKey(Key_GUID(N'HospitalManagementSymmetricKey'), @Password) , @CreatedBy ) 
				
						SET @EmployeeID = @@IDENTITY 

						INSERT INTO dbo.EmployeeDetails (EmployeeID,FirstName,LastName,DateOfBirth, Gender,PhoneNumber,RoleID, CreatedOn)
						VALUES( @EmployeeID,@FirstName,@LastName,@DateOfBirth, @Gender,dbo.fn_FormatPhone(@PhoneNumber),@RoleID, @Today)
				END
				IF(@DepartmentID IS NOT NULL)
				BEGIN
					INSERT INTO dbo.EmployeeDepartment(EmployeeID, DepartmentID , IsActive)
					VALUES ( @EmployeeID , @DepartmentID , 1 )
				END
				FETCH NEXT FROM @EmployeeCursor INTO @EmailID,@Password,@FirstName,@LastName,@DateOfBirth, @Gender,@PhoneNumber,@Role,@DepartmentName,@CreatedBy
		END
 
		CLOSE @EmployeeCursor;
		DEALLOCATE @EmployeeCursor;
		SELECT 'SUCCESS'
		COMMIT TRANSACTION T1

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION T1
		SELECT ERROR_MESSAGE()
	END CATCH

END

GO
CREATE PROCEDURE dbo.usp_UpdateEmployeeAddress(
	@EmployeeAddress [dbo].[UDT_AddressInput] READONLY,
	@EmployeeNumber VARCHAR(100)
)
AS
BEGIN
		BEGIN TRY
			BEGIN TRANSACTION
				DECLARE @AddressTypeID INT
						,@AddressID INT
						,@EmployeeDetailsID INT
						,@Today DATETIME = GETDATE()
						,@Address1 VARCHAR(45),@Address2 VARCHAR(45),@City VARCHAR(45)
						,@State VARCHAR(45),@Zipcode VARCHAR(45),@AddressType VARCHAR(100), @Country VARCHAR(10)
						,@LastIndex INT

				SET @EmployeeDetailsID = ( SELECT EmployeeDetailsID 
							FROM dbo.EmployeeDetails a 
							JOIN dbo.Employee B 
								ON A.EmployeeID = B.EmployeeID
							WHERE B.EmployeeNumber = @EmployeeNumber
							)
				SELECT 
				[Address1],[Address2],[City],[State],[Zipcode],[Country],[AddressType]
				INTO #TEMP_Address
				FROM @EmployeeAddress

				DECLARE @AddressCursor as CURSOR;

				SET @AddressCursor = CURSOR FOR
				SELECT [Address1],[Address2],[City],[State],[Zipcode],[Country],[AddressType]
				FROM #TEMP_Address

				OPEN @AddressCursor;
				FETCH NEXT FROM @AddressCursor INTO @Address1,@Address2,@City,@State,@Zipcode,@Country,@AddressType

				WHILE @@FETCH_STATUS = 0
				BEGIN
						SET @AddressID = null
						SET @AddressTypeID = ( SELECT AddressTypeID FROM dbo.AddressType WHERE Type = @AddressType)

						SELECT @AddressID = AddressID
						FROM dbo.Address 
						WHERE Address1 = @Address1 AND Address2 = @Address2 AND City = @City AND STATE = @State AND ZipCode = @ZipCode AND Country = @Country

						IF(@AddressID IS NULL)
						BEGIN
								INSERT INTO dbo.Address(Address1,Address2,City,State,Zipcode,Country,CreatedOn)
								VALUES
								( @Address1,@Address2,@City,@State,@Zipcode,@Country,@Today)

								SET @AddressID = @@IDENTITY 
						END

						IF NOT EXISTS ( SELECT * FROM dbo.EmployeeAddressMapping WHERE EmployeeDetailsID = @EmployeeDetailsID 
							AND AddressTypeID = @AddressTypeID AND AddressID = @AddressID
							)
						BEGIN
								SET @LastIndex = ISNULL(( SELECT MAX([INDEX]) FROM dbo.EmployeeAddressMapping
													WHERE EmployeeDetailsID = @EmployeeDetailsID 
													AND AddressTypeID = @AddressTypeID),0)

								UPDATE A 
								SET A.IsActive = 0 
									,A.ModifiedON = @Today
								FROM dbo.EmployeeAddressMapping A
								WHERE A.EmployeeDetailsID = @EmployeeDetailsID 
									AND A.AddressTypeID = @AddressTypeID

								INSERT INTO dbo.EmployeeAddressMapping
								(
									EmployeeDetailsID,
									AddressTypeID,
									AddressID,
									IsActive,
									[Index],
									CreatedON
								)
								VALUES
								(   @EmployeeDetailsID,@AddressTypeID,@AddressID,1,(ISNULL(@LastIndex,0)+1),@Today
									)
						END
						ELSE
						BEGIN
								PRINT 'Address Mapping is present for EmployeeID : '+ CAST(@EmployeeNumber AS VARCHAR(100)) + ' AND Address Tye : '+@AddressType
						END
					FETCH NEXT FROM @AddressCursor INTO @Address1,@Address2,@City,@State,@Zipcode,@Country,@AddressType
			END
 
			CLOSE @AddressCursor;
			DEALLOCATE @AddressCursor;

			SELECT 'SUCCESS'
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			SELECT ERROR_MESSAGE()
		END CATCH


END
GO
CREATE PROCEDURE dbo.usp_UpdatePatientAddress(
	@PatientAddress [dbo].[UDT_AddressInput] READONLY,
	@PatientNumber VARCHAR(100)
)
AS
BEGIN
		BEGIN TRY
			BEGIN TRANSACTION
				DECLARE @AddressTypeID INT
						,@AddressID INT
						,@PatientID INT
						,@Today DATETIME = GETDATE()
						,@Address1 VARCHAR(45),@Address2 VARCHAR(45),@City VARCHAR(45)
						,@State VARCHAR(45),@Zipcode VARCHAR(45),@AddressType VARCHAR(100), @Country VARCHAR(10)
						,@LastIndex INT

				SET @PatientID = ( SELECT PatientID FROM dbo.Patient WHERE PatientRegNo = @PatientNumber)

				SELECT 
				[Address1],[Address2],[City],[State],[Zipcode],[Country],[AddressType]
				INTO #TEMP_Address
				FROM @PatientAddress

				DECLARE @AddressCursor as CURSOR;

				SET @AddressCursor = CURSOR FOR
				SELECT [Address1],[Address2],[City],[State],[Zipcode],[Country],[AddressType]
				FROM #TEMP_Address

				OPEN @AddressCursor;
				FETCH NEXT FROM @AddressCursor INTO @Address1,@Address2,@City,@State,@Zipcode,@Country,@AddressType

				WHILE @@FETCH_STATUS = 0
				BEGIN
						SET @AddressTypeID = ( SELECT AddressTypeID FROM dbo.AddressType WHERE Type = @AddressType)

						
						SELECT @AddressID = AddressID
						FROM dbo.Address 
						WHERE Address1 = @Address1 AND Address2 = @Address2 AND City = @City AND STATE = @State AND ZipCode = @ZipCode AND Country = @Country

						IF(@AddressID IS NULL)
						BEGIN
								INSERT INTO dbo.Address(Address1,Address2,City,State,Zipcode,country,CreatedOn)
								VALUES
								( @Address1,@Address2,@City,@State,@Zipcode,@Country,@Today)

								SET @AddressID = @@IDENTITY 
						end

						IF NOT EXISTS ( SELECT * FROM dbo.PatientAddressMapping WHERE PatientID = @PatientID 
							AND AddressTypeID = @AddressTypeID AND AddressID = @AddressID
							)
								BEGIN
								SET @LastIndex = ISNULL(( SELECT MAX([INDEX]) FROM dbo.PatientAddressMapping
													WHERE PatientID = @PatientID 
													AND AddressTypeID = @AddressTypeID),0)

								UPDATE A 
								SET A.IsActive = 0 
									,A.ModifiedON = @Today
								FROM dbo.PatientAddressMapping A
								WHERE A.PatientID = @PatientID 
									AND A.AddressTypeID = @AddressTypeID

								INSERT INTO dbo.PatientAddressMapping
								(
									PatientID,
									AddressTypeID,
									AddressID,
									IsActive,
									[Index],
									CreatedON
								)
								VALUES
								(   @PatientID,@AddressTypeID,@AddressID,1,(ISNULL(@LastIndex,0)+1),@Today
									)
						END
						ELSE
						BEGIN
								PRINT 'Address Mapping is present for PatientID : '+ CAST(@PatientID AS VARCHAR(100)) + ' AND Address Tye : '+@AddressType
						END
					FETCH NEXT FROM @AddressCursor INTO @Address1,@Address2,@City,@State,@Zipcode,@Country,@AddressType
			END
 
			CLOSE @AddressCursor;
			DEALLOCATE @AddressCursor;

			SELECT 'SUCCESS'
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			SELECT ERROR_MESSAGE()
		END CATCH


END

GO

CREATE PROCEDURE dbo.usp_AddNewPatient(
		 @FirstName VARCHAR(45)
		,@LastName VARCHAR(45)
		,@DateOfBirth DATE
		,@Gender VARCHAR(45)
		,@PhoneNumber VARCHAR(45)
		,@EmailID VARCHAR(45)
		,@Height VARCHAR(45)
		,@Weight VARCHAR(45)
		,@BloodGroup VARCHAR(45)
		--,@Disease VARCHAR(45)
		,@OutputResult VARCHAR(1000) OUTPUT
)
AS
BEGIN
		
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @Today DATETIME = GETDATE()
					
			INSERT INTO dbo.Patient
			(FirstName,LastName,DateOfBirth,Gender,PhoneNumber,EmailID,Height,Weight,BloodGroup,CreatedOn)
			VALUES
			(   @FirstName,@LastName,@DateOfBirth,@Gender,dbo.fn_FormatPhone(@PhoneNumber),@EmailID,@Height,@Weight,@BloodGroup , @Today)
			    
		COMMIT TRANSACTION
		SET @OutputResult = 'SUCCESS'
		RETURN
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @OutputResult = ERROR_MESSAGE()
	END CATCH
END

GO 
CREATE PROCEDURE dbo.usp_RegisterNewAppoitment(
	@EmployeeNumber VARCHAR(30)
	,@PatientNumber VARCHAR(30)
	,@AppoitmentDate DATE
	,@CreatedBy INT
)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @EmployeeID INT	
					,@PatientID INT

			SET @EmployeeID = ( SELECT EmployeeID FROM dbo.Employee WHERE EmployeeNumber = @EmployeeNumber)
			SET @PatientID = ( SELECT PatientID FROM dbo.Patient WHERE PatientRegNo = @PatientNumber)

			INSERT INTO dbo.PatientAppointment
			(
			    PatientID,EmployeeID,AppoitmentDate,IsComplete,IsCancelled,IsNoShow, CreatedBy)
			VALUES
			(  @PatientID,@EmployeeID,@AppoitmentDate , 0 , 0 , 0 , @CreatedBy )

			SELECT 'Appoitment Register succesfully'
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT ERROR_MESSAGE()
	END CATCH

END
GO
CREATE PROCEDURE dbo.usp_PatientCheckin(
	@PatientID INT,
	@RoomNumber INT,
	@CoPayType VARCHAR(30),
	@AttendantID [dbo].[UDT_Attendant] READONLY,
	@CheckinDate DATE,
	@CreatedBy	INT
)
AS
BEGIN
	BEGIN TRY
		--BEGIN TRANSACTION

			DECLARE @AdmitON	DATETIME = null
					,@PatientInsuranceID INT
					,@DoctorID INT
					,@PatientRegID INT
					,@Billing DECIMAL(8,2) = 0.00
					
			 SELECT @AdmitON = AppoitmentDate , @DoctorID = EmployeeID
			 FROM dbo.PatientAppointment 
			 WHERE PatientID = @PatientID
			 AND AppoitmentDate = @CheckinDate
			 IF(@AdmitON IS NULL)
			 BEGIN
					SELECT 'There is no Appoitment for Employee ID : '+ CAST(@PatientID AS VARCHAR(100))+ ' On Date : '+ CONVERT(VARCHAR(10),@CheckinDate)
					RETURN
			 END
			 SELECT @PatientInsuranceID = PatientInsuranceID
					,@Billing = (CASE WHEN @CoPayType = 'IN' THEN InNetworkCoPay ELSE OutNetworkCoPay END)
			 FROM dbo.PatientInsurance
			 WHERE PatientID = @PatientID
			 AND IsCurrent = 1

			INSERT INTO dbo.PatientRegister
			(PatientID,AdmittedON,DischargeON,PatientInsuranceID,RoomNumber,CoPayType, CreatedBy)
			VALUES
			(@PatientID,@AdmitON,NULL,@PatientInsuranceID,@RoomNumber,@CoPayType, @CreatedBy)

			SET @PatientRegID = @@IDENTITY 

			INSERT INTO dbo.PatientBilling(PatientRegisterID,TransactionDesc,Amount,GeneratedDate,[Type])
			VALUES (@PatientRegID, 'Insurance CoPay', @Billing, GETDATE(), 'Charge');

			------ Insert Into Patient Attendant.( Start ) 

			SELECT * INTO #TEMP_Attendants FROM @AttendantID

			INSERT INTO dbo.PatientAttendant
			(
			    PatientRegisterID,EmployeeID
			)
			VALUES( @PatientRegID , @DoctorID)
		
			INSERT INTO dbo.PatientAttendant
			(
			    PatientRegisterID,EmployeeID
			)
			SELECT @PatientRegID , [EmployeeID]
			FROM #TEMP_Attendants
			------ Insert Into Patient Attendant.( ENd ) 
			SELECT 'SUCCESSFULLY CHECK IN'

		--COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		--ROLLBACK TRANSACTION
		SELECT ERROR_MESSAGE()
	END CATCH
END

GO
CREATE PROCEDURE dbo.usp_AddPatientLabReport(
	@PatientID INT,
	@LabTestDetails [dbo].[UDT_LabTestDetails] READONLY,
	@AdmitOn DATE
)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @PatientRegisterID INT

			SELECT @PatientRegisterID = PatientRegisterID FROM dbo.PatientRegister WHERE PatientID = @PatientID AND AdmittedON = @AdmitOn

			SELECT * INTO #LabTestDetails FROM @LabTestDetails

			INSERT INTO dbo.PatientLabReport
			(
			    PatientRegisterID,
			    LabTestID,
			    TestValue
			)
			SELECT
				@PatientRegisterID,
			    LabTestID,
			    Result
			FROM #LabTestDetails
		SELECT 'SUCCESS'
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT ERROR_MESSAGE()
	END CATCH

END
GO
CREATE PROCEDURE dbo.usp_RegisterFeedback(
	   @FromPatientID INT
	  ,@ToEmployeeID INT
	  ,@Comment VARCHAR(45)
	  ,@Rating VARCHAR(45)
)
AS 
BEGIN 
	BEGIN TRY
		BEGIN TRANSACTION
		INSERT INTO dbo.Feedback
		(
		    FromPatientID,
		    ToEmployeeID,
		    Comment,
		    Rating
		)
		VALUES
		(   @FromPatientID,@ToEmployeeID,@Comment,@Rating )

		SELECT 'SUCCESS'
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT ERROR_MESSAGE()
	END CATCH

END

GO

CREATE PROCEDURE dbo.usp_PatientPayment(
	   @PatientRegisterID INT
	  ,@Amount DECIMAL(8,2)
	  ,@PaymentType VARCHAR(100)
)
AS 
BEGIN 
	BEGIN TRY
		BEGIN TRANSACTION
		
		DECLARE @AlreadyPaied DECIMAL(8,2) = ( SELECT SUM(Amount) FROM dbo.PatientBilling WHERE PatientRegisterID = @PatientRegisterID AND TransactionDesc = 'Payment')

		DECLARE @RemainingAmount DECIMAL(8,2)

		SET @RemainingAmount = ISNULL(( SELECT SUM(Amount) FROM dbo.PatientBilling WHERE PatientRegisterID = @PatientRegisterID AND Type = 'Charge'),0.00) 
								- ISNULL(@AlreadyPaied,0.00)

		IF(@Amount >  @RemainingAmount)
		BEGIN
			PRINT 'Payment Amount can not be more than the remaining Balance'
		END
		ELSE
		BEGIN
			INSERT INTO dbo.PatientBilling
			(
			    PatientRegisterID,
			    TransactionDesc,
			    Amount,
			    GeneratedDate,
				[Type],
			    PatientAddressID,
				[PaymentType]
			)
			VALUES
			(   @PatientRegisterID ,'Payment' , @Amount , GETDATE(), 'Credit' ,  NULL , @PaymentType )     -- TransactionType - varchar(45)
		
		END



		SELECT 'SUCCESS'
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT ERROR_MESSAGE()
	END CATCH

END

GO


/*********************************************************************************
---	L. CREATE TRIGGER
**********************************************************************************/

CREATE TRIGGER tr_UpdateAttendantBilling on dbo.PatientAttendant
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
   SET NOCOUNT ON;
		
		 DECLARE @Today DATETIME = GETDATE()
		 SELECT A.PatientRegisterID, A.EmployeeID , 0 AS Billing INTO #temp
		 FROM
		   (
		   SELECT PatientRegisterID, EmployeeID FROM Inserted
		   UNION
		   SELECT PatientRegisterID , EmployeeID FROM Deleted
		   ) A

		UPDATE A 
		SET A.Billing = (CASE WHEN dbo.fn_GetEmployeeRole(A.EmployeeID) = 'Doctor' THEN 900.00
						WHEN dbo.fn_GetEmployeeRole(A.EmployeeID) = 'Nurse' THEN 700.00
						WHEN dbo.fn_GetEmployeeRole(A.EmployeeID) = 'Lab Attendant' THEN 500.00
						ELSE 200.50 END)
		FROM #temp A

		SELECT PatientRegisterID , SUM(Billing) AS TotalBilling
		INTO #TEMP_TotalBilling
		FROM #temp
		GROUP BY PatientRegisterID

		MERGE dbo.PatientBilling T
		USING #TEMP_TotalBilling S
		ON (S.PatientRegisterID = T.PatientRegisterID AND T.TransactionDesc = 'Attendant Billing')
		WHEN MATCHED 
			 THEN UPDATE
			 SET    T.Amount = T.Amount + ISNULL(S.TotalBilling,0.00)
					,T.GeneratedDate = @Today
		WHEN NOT MATCHED BY TARGET
		THEN INSERT (PatientRegisterID,TransactionDesc,Amount,GeneratedDate,[Type])
			 VALUES (S.PatientRegisterID, 'Attendant Billing', S.TotalBilling, @Today , 'Charge');
		
		DROP TABLE #temp
END
ALTER TABLE [dbo].PatientAttendant ENABLE TRIGGER tr_UpdateAttendantBilling
GO
CREATE TRIGGER tr_UpdateLabReportBilling on dbo.PatientLabReport
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE @Today DATETIME = GETDATE()
		 SELECT A.PatientRegisterID, A.LabTestID , 0 AS Billing INTO #temp
		 FROM
		   (
		   SELECT PatientRegisterID, LabTestID FROM Inserted
		   UNION
		   SELECT PatientRegisterID , LabTestID FROM Deleted
		   ) A

		UPDATE A 
		SET A.Billing = dbo.fn_GetLabTestCost(A.LabTestID)
		FROM #temp A

		SELECT PatientRegisterID , SUM(Billing) AS TotalBilling
		INTO #TEMP_TotalBilling
		FROM #temp
		GROUP BY PatientRegisterID

		MERGE dbo.PatientBilling T
		USING #TEMP_TotalBilling S
		ON (S.PatientRegisterID = T.PatientRegisterID AND T.TransactionDesc = 'Lab Billing')
		WHEN MATCHED 
			 THEN UPDATE
			 SET    T.Amount = T.Amount + ISNULL(S.TotalBilling,0.00)
					,T.GeneratedDate = @Today
		WHEN NOT MATCHED BY TARGET
		THEN INSERT (PatientRegisterID,TransactionDesc,Amount,GeneratedDate,[Type])
			 VALUES (S.PatientRegisterID, 'Lab Cost', S.TotalBilling, @Today, 'Charge');
		
		DROP TABLE #temp
END
GO
ALTER TABLE dbo.PatientLabReport ENABLE TRIGGER tr_UpdateLabReportBilling

GO
/*CREATE TRIGGER tr_UpdateInsuranceBilling on dbo.PatientRegister
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE @Today DATETIME = GETDATE()
		 SELECT A.PatientRegisterID, A.PatientInsuranceID, A.CopayType, 0 AS Billing INTO #temp
		 FROM
		   (
		   SELECT PatientRegisterID, PatientInsuranceID , CopayType FROM Inserted
		   UNION
		   SELECT PatientRegisterID , PatientInsuranceID , CopayType FROM Deleted
		   ) A

		UPDATE A 
		SET A.Billing = CASE WHEN A.CopayType = 'IN' THEN B.InNetworkCoPay ELSE B.OutNetworkCoPay END
		FROM #temp A
		JOIN dbo.PatientInsurance B 
			ON A.PatientInsuranceID = B.PatientInsuranceID

		ALTER TABLE dbo.PatientBilling NOCHECK CONSTRAINT FK_PatientBilling_PatientRegister_IDX

		MERGE dbo.PatientBilling T
		USING #temp S
		ON (S.PatientRegisterID = T.PatientRegisterID AND T.TransactionDesc = 'Insurance CoPay')
		WHEN MATCHED 
			 THEN UPDATE
			 SET    T.Amount = T.Amount + ISNULL(S.Billing,0.00)
					,T.GeneratedDate = @Today
		WHEN NOT MATCHED BY TARGET
		THEN INSERT (PatientRegisterID,TransactionDesc,Amount,GeneratedDate,[Type])
			 VALUES (S.PatientRegisterID, 'Insurance CoPay', S.Billing, @Today, 'Charge');
		
		ALTER TABLE dbo.PatientBilling WITH CHECK CHECK CONSTRAINT FK_PatientBilling_PatientRegister_IDX

		DROP TABLE #temp
END
GO
ALTER TABLE dbo.PatientRegister DISABLE TRIGGER tr_UpdateInsuranceBilling*/


GO
/********************************************************************************
--- M. DATA INSERT
**********************************************************************************/
--*****Config OR Setup TABLES
-----1. dbo.Department  ---- Data load through SSMS Import wizard
SELECT COUNT(1) FROM dbo.Department --- 15
GO
-----2. dbo.Role		 ---- Data Load through SSMS Import wizard
SELECT COUNT(1) FROM dbo.ROle --- 10
GO
-----3. dbo.Disease	----Data load through SSMS Import wizard
SELECT COUNT(1) FROM dbo.Disease  --- 12
GO
-----4. dbo.LabTest
INSERT INTO dbo.LabTest ( TestName,IsActive,MINVALUE,MAXVALUE, [CalUnit]) VALUES
('Insulin',1,'75' , '95' , 'mg/dL')
,('Immunoglobulin M',1 , '231' ,'1411', 'mg/dL')
,('AFB Blood Culture',1, '1000', '9000','Count')
,('Blood Pressure',1,'85','120','mm HG')
,('Hepatitis A IgG',1,'200','500','mg/dL')
,('Snake Bite Venom Detection',1,'15','20','WBCT')
,('GALA Gene Test',1 , '150' , '300' , 'Count')
,('EJ antibodies',1,'30','60','%')
,('Cancer Gene 1',1,'10','30','%')
,('Zika virus PCR',1,'5','10','count')
,('R0-52 antibodies',0,'40','50','%')

SELECT COUNT(1) FROM dbo.LabTest --- 11
GO
-----5. [AddressType]
INSERT INTO dbo.[AddressType] ( [Type] ) 
VALUES ( 'Home Address') , ('Mail Address') , 
('Office Address') , ('Permanent Address'), 
('Temporary Address'),('Domestic Address'),
('Overseas Address'),('Other Address1'),
('Other Address2'),('Other Address3')

SELECT COUNT(1) FROM dbo.[AddressType] -- 10
GO
--***** Transaction Data
----6. Insert into dbo.Employee ,  7.dbo.employeeDetails , 8.dbo.employeeDepartment

DECLARE @Employee [dbo].[UDT_HospitalEmployee]

INSERT INTO @Employee(EmailID,Password,FirstName,LastName,DateOfBirth,Gender,PhoneNumber
,Role,DepartmentName, CreatedBy) VALUES
('Admin@HospitalManagement.com','admin@1','Admin','Admin','1990-01-09','M','407-978-2222','Admin', NULL, null)
,('rami.ghrewati@HospitalManagement.com','abc@1','Rami','Ghrewati','1990-01-09','F','407-978-1111','Doctor','Emergency Unit',1)
,('roma.studzienski@HospitalManagement.com','abc@2','Roma','Studzienski','1980-11-09','F','407-978-1111','Doctor','Pediatric Unit',1)
,('sean.keenan@HospitalManagement.com','abc@3','Sean','Keenan','1989-10-01','M','407-978-1111','Doctor','Emergency Unit',1)
,('carolyn.lucas@HospitalManagement.com','abc@4','Carolyn','Lucas','1987-09-02','M','407-978-1111','Doctor','Cardiology Unit',1)
,('patricia.chaparro@HospitalManagement.com','abc@5','Patricia','Chaparro','1990-01-09','M','407-978-1111','Doctor','Neurology Unit',1)
,('brent.lawrence@HospitalManagement.com','abc@6','Brent','Lawrence','1990-01-09','M','407-978-1111','Doctor','Psychiatric Unit',1)
,('carlos.mogollon@HospitalManagement.com','abc@7','Carlos','Mogollon','1990-01-09','M','407-978-1111','Nurse','Emergency Unit',1)
,('katie.shapiro@HospitalManagement.com','abc@8','Catherine','Shapiro','1990-01-09','M','407-978-1111','Nurse','Pediatric Unit',1)
,('michael.reilly@HospitalManagement.com','abc@9','Michael','Reilly','1990-01-09','M','407-978-1111','Lab Attendant','Cardiology Unit',1)
,('edgarl.velez@HospitalManagement.com','abc@10','Edgar','Velez','1990-01-09','M','407-978-1111','Doctor','Maternity Unit',1)
,('flavio.aragao@HospitalManagement.com','abc@11','Flavio','Aragao','1990-01-09','M','407-978-1111','Lab Attendant','Pediatric Unit',1)
,('dominic.tringali@HospitalManagement.com','abc@12','Dominic','Tringali','1989-01-09','M','407-978-1111','Nurse','Gastroenterology',1)
,('nancy.hutchings@HospitalManagement.com','abc@13','Nancy','Hutchings','1990-01-09','M','407-978-1111','Doctor','Medicine Unit',1)
,('oswaldo.alejo@HospitalManagement.com','abc@14','Oswaldo','Alejo','1990-01-09','M','407-978-1111','Doctor','Maternity Unit',1)
,('joseph.navarro@HospitalManagement.com','abc@15','Joseph','Navarro','1990-01-09','M','407-978-1111','Nurse','Cardiology Unit',1)
,('mauricio.velez@HospitalManagement.com','abc@16','Mauricio','Velez','1989-01-09','M','407-978-1111','Lab Attendant','Emergency Unit',1)
,('charles.connolly@HospitalManagement.com','abc@17','Charles','Connolly','1990-01-09','M','407-978-1111','Doctor','Neurology Unit',1)
,('lory.collins@HospitalManagement.com','abc@18','Lory','Collins','1990-01-09','M','407-978-1111','Doctor','Medicine Unit',1)
,('susankay.dahlen@HospitalManagement.com','abc@19','Susan','Dahlen','1989-01-09','M','407-978-1111','Nurse','Psychiatric Unit',1)
,('gil.bochicchio@HospitalManagement.com','abc@20','Gilbert','Bochicchio','1990-01-09','M','407-978-1111','Doctor','Gastroenterology',1)
,('Gill.barbara@HospitalManagement.com','ab23@20','Gill','Barbara','1990-02-23','M','407-908-0094','Receptionist','Gastroenterology',1)

EXEC dbo.usp_InsertEmployeeDetails @EmployeeInfo = @Employee -- UDT_HospitalEmployee
GO

INSERT INTO dbo.EmployeeDepartment
(
    EmployeeID,
    DepartmentID,
    IsActive
)
VALUES
(   22,   -- EmployeeID - int
    1,   -- DepartmentID - int
    1 -- IsActive - bit
    ),
(   22,   -- EmployeeID - int
    2,   -- DepartmentID - int
    1 -- IsActive - bit
    ),
(   22,   -- EmployeeID - int
    3,   -- DepartmentID - int
    1 -- IsActive - bit
    ),
(   22,   -- EmployeeID - int
    4,   -- DepartmentID - int
    1 -- IsActive - bit
    ),
(   22,   -- EmployeeID - int
    5,   -- DepartmentID - int
    1 -- IsActive - bit
    ),
(   22,   -- EmployeeID - int
    6,   -- DepartmentID - int
    1 -- IsActive - bit
    ),
(   22,   -- EmployeeID - int
    7,   -- DepartmentID - int
    1 -- IsActive - bit
    )

----- CHeck Constaraint in Table ( age )
DECLARE @Employee [dbo].[UDT_HospitalEmployee]
INSERT INTO @Employee(EmailID,Password,FirstName,LastName,DateOfBirth,Gender,PhoneNumber
,Role,DepartmentName) VALUES
('a.ghrei@HospitalManagement.com','ab34c@1','a','Ghrewati','2018-01-09','M','407-978-2222','Doctor','Emergency Unit')

EXEC dbo.usp_InsertEmployeeDetails @EmployeeInfo = @Employee -- UDT_HospitalEmployee
GO
SELECT COUNT(1) FROM dbo.Employee -- -20 Rows
SELECT COUNT(1) FROM dbo.EmployeeDepartment --- 20 Rows
SELECT COUNT(1) FROM dbo.EmployeeDetails  --- -20 Rows

GO
---- Insert Into 9.dbo.employeeAddressMapping, 10.dbo.Address

DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Country, Zipcode , AddressType) VALUES
('2538 SE 23RD PL','','CAPE CORAL','FL','US','33904','Home Address'),
('452 NATURE VIEW CT','','WEST SAINT PAUL','MN','US','55118','Mail Address'),
('29 CANTERBURY LN','','SOUTHINGTON','CT','US','06489','Office Address')

EXEC dbo.usp_UpdateEmployeeAddress @EmployeeAddress = @Address, -- UDT_AddressInput
                                   @EmployeeNumber = 'EMP2019007'     -- varchar(100)
GO
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Country, Zipcode , AddressType) VALUES
('2599 SE 23RD PL','','CAPE CORAL','FL','US','33904','Home Address')

EXEC dbo.usp_UpdateEmployeeAddress @EmployeeAddress = @Address, -- UDT_AddressInput
                                   @EmployeeNumber = 'EMP2019007'     -- varchar(100)

GO
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Country, Zipcode , AddressType) VALUES
('920 S LAKE SHORE DR','','LAKE GENEVA','WI','US','53147','Home Address'),
('WOODVILLE','4-12-19 NISHIAZABU','MINATO-KU','TKY','US','53147','Overseas Address'),
('2213 RED EDGE HTS','','Orlando','FL','US','50047','Office Address')
EXEC dbo.usp_UpdateEmployeeAddress @EmployeeAddress = @Address, -- UDT_AddressInput
                                   @EmployeeNumber = 'EMP2019004'     -- varchar(100)

GO
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Country, Zipcode , AddressType) VALUES
('5263 DAYBREAK LN.','','WOODBRIDGE','NJ','US','00456','Home Address'),
('13854 9TH LINE','','GEORGETOWN','ON','US','099876','Office Address'),
('1438 BORGHESE LN UNIT 301','','Orlando','FL','US','50147','Mail Address')
EXEC dbo.usp_UpdateEmployeeAddress @EmployeeAddress = @Address, -- UDT_AddressInput
                                   @EmployeeNumber = 'EMP2019003'     -- varchar(100)
GO
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Country, Zipcode , AddressType) VALUES
('202 SOHO street','','WOODBRIDGE','NJ','US','00123','Home Address')
EXEC dbo.usp_UpdateEmployeeAddress @EmployeeAddress = @Address, -- UDT_AddressInput
                                   @EmployeeNumber = 'EMP2019002'     -- varchar(100)

------- New
GO
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Country, Zipcode , AddressType) VALUES
('139 ORYAN CT','','HOUSTON','TX','US','00123','Home Address')
EXEC dbo.usp_UpdateEmployeeAddress @EmployeeAddress = @Address, -- UDT_AddressInput
                                   @EmployeeNumber = 'EMP2019001'     -- varchar(100)

GO
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Country, Zipcode , AddressType) VALUES
('7925 RAMBLE VW','','CINCINNATI','OH','US','00567','Home Address'),
('502 TANOAK DR','','SANTA CLARA','CA','US','33904','Mail Address')
EXEC dbo.usp_UpdateEmployeeAddress @EmployeeAddress = @Address, -- UDT_AddressInput
                                   @EmployeeNumber = 'EMP2019002'     -- varchar(100)
GO
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Country, Zipcode , AddressType) VALUES
('24 OYSTER PT','','WARREN','RI','US','990798','Home Address')
EXEC dbo.usp_UpdateEmployeeAddress @EmployeeAddress = @Address, -- UDT_AddressInput
                                   @EmployeeNumber = 'EMP2019003'     -- varchar(100)
GO
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Country, Zipcode , AddressType) VALUES
('3300 STOCKTON DR','','FLORENCE','SC','US','998087','Home Address'),
('3568 W FAIRVIEW ST','','MIAMI','FL','US','00998','Mail Address')
EXEC dbo.usp_UpdateEmployeeAddress @EmployeeAddress = @Address, -- UDT_AddressInput
                                   @EmployeeNumber = 'EMP2019004'     -- varchar(100)
GO
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Country, Zipcode , AddressType) VALUES
('406 HARVEST TRL','','MIDLOTHIAN','TX','US','998087','Home Address')
EXEC dbo.usp_UpdateEmployeeAddress @EmployeeAddress = @Address, -- UDT_AddressInput
                                   @EmployeeNumber = 'EMP2019005'     -- varchar(100)
GO
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Country, Zipcode , AddressType) VALUES
('1277 KAAHUMANU ST','','MIDLOTHIAN','TX','US','998087','Home Address'),
('22526 ARBOR STREAM DR','','MIAMI','FL','US','00998','Mail Address')
EXEC dbo.usp_UpdateEmployeeAddress @EmployeeAddress = @Address, -- UDT_AddressInput
                                   @EmployeeNumber = 'EMP2019005'     -- varchar(100)
GO
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Country, Zipcode , AddressType) VALUES
('6127 SUNSET RDG','','DULUTH','MN','US','998087','Home Address')
EXEC dbo.usp_UpdateEmployeeAddress @EmployeeAddress = @Address, -- UDT_AddressInput
                                   @EmployeeNumber = 'EMP2019006'     -- varchar(100)
GO
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Country, Zipcode , AddressType) VALUES
('3313 OLD SAYBROOK CT','','MIAMI','FL','US','00998','Home Address')
EXEC dbo.usp_UpdateEmployeeAddress @EmployeeAddress = @Address, -- UDT_AddressInput
                                   @EmployeeNumber = 'EMP2019007'     -- varchar(100)
GO
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Country, Zipcode , AddressType) VALUES
('3568 W FAIRVIEW ST','','MIAMI','FL','US','00998','Mail Address')
EXEC dbo.usp_UpdateEmployeeAddress @EmployeeAddress = @Address, -- UDT_AddressInput
                                   @EmployeeNumber = 'EMP2019008'     -- varchar(100)
GO
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Country, Zipcode , AddressType) VALUES
('3568 W FAIRVIEW ST','','MIAMI','FL','US','00998','Home Address')
EXEC dbo.usp_UpdateEmployeeAddress @EmployeeAddress = @Address, -- UDT_AddressInput
                                   @EmployeeNumber = 'EMP2019009'     -- varchar(100)
GO
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Country, Zipcode , AddressType) VALUES
('6401 OLD OAKS BLVD','','PEARLAND','TX','US','00998','Home Address')
EXEC dbo.usp_UpdateEmployeeAddress @EmployeeAddress = @Address, -- UDT_AddressInput
                                   @EmployeeNumber = 'EMP2019010'     -- varchar(100)							   
GO
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Country, Zipcode , AddressType) VALUES
('2538 SE 23RD PL','','CAPE CORAL','FL','US','33904','Mail Address')
EXEC dbo.usp_UpdateEmployeeAddress @EmployeeAddress = @Address, -- UDT_AddressInput
                                   @EmployeeNumber = 'EMP2019011'     -- varchar(100)							   
								   								   


SELECT COUNT(1) FROM dbo.EmployeeAddressMapping  --- 11 
SELECT COUNT(1) FROM dbo.Address -- 14


GO

------- 11. dbo.Patient
DECLARE @OutputResult VARCHAR(1000) = ''
EXEC dbo.usp_AddNewPatient
		 @FirstName = 'Pratyusha',@LastName ='Kar',@DateOfBirth = '1990-07-15',@Gender = 'F'
		,@PhoneNumber = '407-308-4153',@EmailID = 'pratyusha23kar@gmail.com',@Height = '5 11'
		,@Weight = '160',@BloodGroup = 'O+'
		,@OutputResult  = @OutputResult OUTPUT
SELECT @OutputResult

GO
DECLARE @OutputResult VARCHAR(1000) = ''
EXEC dbo.usp_AddNewPatient
		 @FirstName = 'RENITA',@LastName ='MC NEESE',@DateOfBirth = '1980-01-15',@Gender = 'M'
		,@PhoneNumber = '409-888-4453',@EmailID = 'test2@gmail.com',@Height = '5 8'
		,@Weight = '140',@BloodGroup = 'O-'
		,@OutputResult  = @OutputResult OUTPUT
SELECT @OutputResult
GO
DECLARE @OutputResult VARCHAR(1000) = ''
EXEC dbo.usp_AddNewPatient
		 @FirstName = 'KEENAN',@LastName ='HAYNES',@DateOfBirth = '1892-02-12',@Gender = 'F'
		,@PhoneNumber = '903-308-1234',@EmailID = 'test3@gmail.com',@Height = '5 7'
		,@Weight = '134',@BloodGroup = 'AB-'
		,@OutputResult  = @OutputResult OUTPUT
SELECT @OutputResult
GO
DECLARE @OutputResult VARCHAR(1000) = ''
EXEC dbo.usp_AddNewPatient
		 @FirstName = 'JENNY',@LastName ='PATRICK',@DateOfBirth = '1992-03-15',@Gender = 'F'
		,@PhoneNumber = '407-308-4153',@EmailID = 'test4@gmail.com',@Height = '5 11'
		,@Weight = '160',@BloodGroup = 'B+'
		,@OutputResult  = @OutputResult OUTPUT
SELECT @OutputResult
GO
DECLARE @OutputResult VARCHAR(1000) = ''
EXEC dbo.usp_AddNewPatient
		 @FirstName = 'MELINDA',@LastName ='Kar',@DateOfBirth = '1990-07-15',@Gender = 'F'
		,@PhoneNumber = '407-308-4153',@EmailID = 'test10@gmail.com',@Height = '5 11'
		,@Weight = '160',@BloodGroup = 'O+'
		,@OutputResult  = @OutputResult OUTPUT
SELECT @OutputResult
GO
DECLARE @OutputResult VARCHAR(1000) = ''
EXEC dbo.usp_AddNewPatient
		 @FirstName = 'ROBERTO',@LastName ='CORDOVA',@DateOfBirth = '1988-08-08',@Gender = 'M'
		,@PhoneNumber = '407-308-9878',@EmailID = 'test5@gmail.com',@Height = '5 11'
		,@Weight = '140',@BloodGroup = 'O+'
		,@OutputResult  = @OutputResult OUTPUT
SELECT @OutputResult
GO
DECLARE @OutputResult VARCHAR(1000) = ''
EXEC dbo.usp_AddNewPatient
		 @FirstName = 'CHIAKI',@LastName ='EGAWA',@DateOfBirth = '1997-08-05',@Gender = 'M'
		,@PhoneNumber = '305-803-9900',@EmailID = 'test6@gmail.com',@Height = '5 11'
		,@Weight = '160',@BloodGroup = 'O+'
		,@OutputResult  = @OutputResult OUTPUT
SELECT @OutputResult
GO
DECLARE @OutputResult VARCHAR(1000) = ''
EXEC dbo.usp_AddNewPatient
		 @FirstName = 'ROSANNA',@LastName ='PICCOLO',@DateOfBirth = '1978-07-15',@Gender = 'F'
		,@PhoneNumber = '409-678-5693',@EmailID = 'test12@gmail.com',@Height = '5 8'
		,@Weight = '230',@BloodGroup = 'O-'
		,@OutputResult  = @OutputResult OUTPUT
SELECT @OutputResult
GO
DECLARE @OutputResult VARCHAR(1000) = ''
EXEC dbo.usp_AddNewPatient
		 @FirstName = 'SUMIKO',@LastName ='MATSUNO',@DateOfBirth = '1998-01-01',@Gender = 'M'
		,@PhoneNumber = '705-908-5678',@EmailID = 'test14@gmail.com',@Height = '5 10'
		,@Weight = '180',@BloodGroup = 'AB+'
		,@OutputResult  = @OutputResult OUTPUT
SELECT @OutputResult
GO
DECLARE @OutputResult VARCHAR(1000) = ''
EXEC dbo.usp_AddNewPatient
		 @FirstName = 'WYNONA',@LastName ='DELGADILLO',@DateOfBirth = '1990-08-29',@Gender = 'M'
		,@PhoneNumber = '407-987-5467',@EmailID = 'test123@gmail.com',@Height = '5 11'
		,@Weight = '260',@BloodGroup = 'O+'
		,@OutputResult  = @OutputResult OUTPUT
SELECT @OutputResult
GO
DECLARE @OutputResult VARCHAR(1000) = ''
EXEC dbo.usp_AddNewPatient
		 @FirstName = 'MARIO',@LastName ='DELGADILLO',@DateOfBirth = '1980-09-15',@Gender = 'F'
		,@PhoneNumber = '409-908-0980',@EmailID = 'ptest23@gmail.com',@Height = '5 1'
		,@Weight = '140',@BloodGroup = 'O+'
		,@OutputResult  = @OutputResult OUTPUT
SELECT @OutputResult
GO
DECLARE @OutputResult VARCHAR(1000) = ''
EXEC dbo.usp_AddNewPatient
		 @FirstName = 'DANIN',@LastName ='DEEANN',@DateOfBirth = '1985-08-05',@Gender = 'F'
		,@PhoneNumber = '407-978-1111',@EmailID = 'test12@gmail.com',@Height = '5 9'
		,@Weight = '170',@BloodGroup = 'O+'
		,@OutputResult  = @OutputResult OUTPUT
SELECT @OutputResult
GO
DECLARE @OutputResult VARCHAR(1000) = ''
EXEC dbo.usp_AddNewPatient
		 @FirstName = 'MARTIN',@LastName ='DONNA',@DateOfBirth = '1987-04-19',@Gender = 'M'
		,@PhoneNumber = '408-987-0098',@EmailID = 'test345@gmail.com',@Height = '6 2'
		,@Weight = '140',@BloodGroup = 'AB-'
		,@OutputResult  = @OutputResult OUTPUT
SELECT @OutputResult
GO
DECLARE @OutputResult VARCHAR(1000) = ''
EXEC dbo.usp_AddNewPatient
		 @FirstName = 'JOHN',@LastName ='FRASER',@DateOfBirth = '1987-04-19',@Gender = 'M'
		,@PhoneNumber = '4089880019',@EmailID = 'test345@gmail.com',@Height = '6 2'
		,@Weight = '140',@BloodGroup = 'O+'
		,@OutputResult  = @OutputResult OUTPUT
SELECT @OutputResult
GO
DECLARE @OutputResult VARCHAR(1000) = ''
EXEC dbo.usp_AddNewPatient
		 @FirstName = 'HEVEY',@LastName ='W.',@DateOfBirth = '1980-05-20',@Gender = 'F'
		,@PhoneNumber = '408-908.7897',@EmailID = 'test655@gmail.com',@Height = '5 2'
		,@Weight = '140',@BloodGroup = 'O+'
		,@OutputResult  = @OutputResult OUTPUT
SELECT @OutputResult
GO
DECLARE @OutputResult VARCHAR(1000) = ''
EXEC dbo.usp_AddNewPatient
		 @FirstName = 'ALEXANDER',@LastName ='SCOTT',@DateOfBirth = '1990-01-19',@Gender = 'M'
		,@PhoneNumber = '4990897865',@EmailID = 'test115@gmail.com',@Height = '6 2'
		,@Weight = '140',@BloodGroup = 'AB+'
		,@OutputResult  = @OutputResult OUTPUT
SELECT @OutputResult
SELECT COUNT(1) FROM dbo.Patient  --- 16

GO
------ 12.dbo.PatientAddess and dbo.Address
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Zipcode , Country, AddressType) VALUES
('10741 PALOS WEST DR','','PALOS PARK','IL','30098','US','Home Address')
,('1122 W. OAKVILLE ROAD','','SPRINGFIELD','MO','456999','US','Mail Address')

EXEC dbo.usp_UpdatePatientAddress @PatientAddress = @Address, -- UDT_AddressInput
                                  @PatientNumber = 'PraKar715'      -- varchar(100)
GO
------ dbo.PatientAddess and dbo.Address
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Zipcode , Country, AddressType) VALUES
('388 CHATHAM RD N','CHATHAM GATE','CINCINNATI','OH','32456','US','Office Address')

EXEC dbo.usp_UpdatePatientAddress @PatientAddress = @Address, -- UDT_AddressInput
                                  @PatientNumber = 'RENESE115'      -- varchar(100)
GO
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Zipcode , Country, AddressType) VALUES
('2586 Robert Trent Jones Dr','APT 1111','Orlando','FL','32835','US','Home Address')
EXEC dbo.usp_UpdatePatientAddress @PatientAddress = @Address, -- UDT_AddressInput
                                  @PatientNumber = 'KEENES212'      -- varchar(100)
GO

DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Zipcode , Country, AddressType) VALUES
('2538 SE 23RD PL','','Cape Coral','FL','09878','US','Mail Address'),
('7925 RAMBLE VW','','Cape Coral','FL','09888','US','Temporary Address')
EXEC dbo.usp_UpdatePatientAddress @PatientAddress = @Address, -- UDT_AddressInput
                                  @PatientNumber = 'JENICK315'      -- varchar(100)
GO
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Zipcode , Country, AddressType) VALUES
('502 TANOAK DR','','SANTA CLARA','CA','00987','US','Permanent Address'),
('24 OYSTER PT','','WARREN','CO','89789','US','Office Address')
EXEC dbo.usp_UpdatePatientAddress @PatientAddress = @Address, -- UDT_AddressInput
                                  @PatientNumber = 'MELKar715'      -- varchar(100)
GO
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Zipcode , Country, AddressType) VALUES
('311 SAN CARLOS RD','APT 1111','Orlando','MA','32835','US','Home Address'),
('22526 ARBOR STREAM DR','APT 34','Miami','MA','30098','US','Office Address'),
('7955 DUNAWAY LN','','WESTERVILLE','OH','32835','US','Permanent Address')
EXEC dbo.usp_UpdatePatientAddress @PatientAddress = @Address, -- UDT_AddressInput
                                  @PatientNumber = 'ROBOVA88'      -- varchar(100)
GO
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Zipcode , Country, AddressType) VALUES
('33065 Biltmore Park Dr','APT 303','Orlando','FL','32835','US','Home Address')
EXEC dbo.usp_UpdatePatientAddress @PatientAddress = @Address, -- UDT_AddressInput
                                  @PatientNumber = 'CHIAWA85'      -- varchar(100)
GO
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Zipcode , Country, AddressType) VALUES
('1720 NW 195TH ST','','MIAMI GARDENS','FL','32835','US','Home Address')
EXEC dbo.usp_UpdatePatientAddress @PatientAddress = @Address, -- UDT_AddressInput
                                  @PatientNumber = 'ROSOLO715'      -- varchar(100)
GO
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Zipcode , Country, AddressType) VALUES
('30 CH DUFFERIN','','HAMPSTEAD','NJ','99876','US','Mail Address')
EXEC dbo.usp_UpdatePatientAddress @PatientAddress = @Address, -- UDT_AddressInput
                                  @PatientNumber = 'SUMUNO11'      -- varchar(100)
GO
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Zipcode , Country, AddressType) VALUES
('8208 FOREST CIR','','SEMINOL','FL','99876','US','Mail Address')
EXEC dbo.usp_UpdatePatientAddress @PatientAddress = @Address, -- UDT_AddressInput
                                  @PatientNumber = 'WYNLLO829'      -- varchar(100)
GO
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Zipcode , Country, AddressType) VALUES
('368 ELMWOOD AVE','','LAKE','IL','11123','US','Home Address')
EXEC dbo.usp_UpdatePatientAddress @PatientAddress = @Address, -- UDT_AddressInput
                                  @PatientNumber = 'MARLLO915'      -- varchar(100)
GO
DECLARE @Address [dbo].UDT_AddressInput
INSERT INTO @Address(Address1, Address2 , City , State , Zipcode , Country, AddressType) VALUES
('5 DRESSLER CRT','','Alberta','CA','99878','US','Office Address')
EXEC dbo.usp_UpdatePatientAddress @PatientAddress = @Address, -- UDT_AddressInput
                                  @PatientNumber = 'DANANN85'      -- varchar(100)

SELECT COUNT(1) FROM dbo.PatientAddressMapping  ----12
SELECT COUNT(1) FROM dbo.Address  --- 23

----13. dbo.PatientAppointment

EXEC dbo.usp_RegisterNewAppoitment 'EMP2019002','WYNLLO829','2019-08-5',22
EXEC dbo.usp_RegisterNewAppoitment 'EMP2019003','MARLLO915','2019-08-5',22
EXEC dbo.usp_RegisterNewAppoitment 'EMP2019004','DANANN85','2019-08-5',22
EXEC dbo.usp_RegisterNewAppoitment 'EMP2019005','MARNNA419','2019-08-5',22

EXEC dbo.usp_RegisterNewAppoitment 'EMP2019006','PraKar715','2019-08-10',22
EXEC dbo.usp_RegisterNewAppoitment 'EMP2019007','RENESE115','2019-08-10',22
EXEC dbo.usp_RegisterNewAppoitment 'EMP2019011','KEENES212','2019-08-10',22
EXEC dbo.usp_RegisterNewAppoitment 'EMP2019014','JENICK315','2019-08-10',22
EXEC dbo.usp_RegisterNewAppoitment 'EMP2019015','MELKar715','2019-08-10',22
EXEC dbo.usp_RegisterNewAppoitment 'EMP2019018','ROBOVA88','2019-08-10',22
EXEC dbo.usp_RegisterNewAppoitment 'EMP2019019','CHIAWA85','2019-08-10',22
EXEC dbo.usp_RegisterNewAppoitment 'EMP2019021','ROSOLO715','2019-08-10',22
EXEC dbo.usp_RegisterNewAppoitment 'EMP2019019','SUMUNO11','2019-08-10',22
EXEC dbo.usp_RegisterNewAppoitment 'EMP2019018','WYNLLO829','2019-08-10',22
EXEC dbo.usp_RegisterNewAppoitment 'EMP2019015','MARLLO915','2019-08-10',22
EXEC dbo.usp_RegisterNewAppoitment 'EMP2019007','DANANN85','2019-08-10',22
EXEC dbo.usp_RegisterNewAppoitment 'EMP2019006','MARNNA419','2019-08-10',22
EXEC dbo.usp_RegisterNewAppoitment 'EMP2019018','JOHSER419','2019-08-10',22
EXEC dbo.usp_RegisterNewAppoitment 'EMP2019015','HEVW.520','2019-08-10',22
EXEC dbo.usp_RegisterNewAppoitment 'EMP2019021','ALEOTT119','2019-08-10',22


EXEC dbo.usp_RegisterNewAppoitment 'EMP2019003','PraKar715','2019-08-11',22
EXEC dbo.usp_RegisterNewAppoitment 'EMP2019002','RENESE115','2019-08-11',22
EXEC dbo.usp_RegisterNewAppoitment 'EMP2019007','KEENES212','2019-08-11',22
EXEC dbo.usp_RegisterNewAppoitment 'EMP2019018','JENICK315','2019-08-11',22



UPDATE A 
SET A.IsCancelled = 1
FROM dbo.PatientAppointment A 
WHERE A.PatientID IN (10,11) AND AppoitmentDate = '2019-08-05'


UPDATE A 
SET A.IsNoShow = 1
FROM dbo.PatientAppointment A 
WHERE A.PatientID IN ( 12,13)  AND AppoitmentDate = '2019-08-05'

SELECT COUNT(1) FROM dbo.PatientAppointment  --- 13


EXEC dbo.usp_RegisterNewAppoitment 'EMP2019008','JENICK315','2019-08-12',22


----14. Patient Insurance
INSERT INTO dbo.PatientInsurance
(
    PatientID,ProviderName,GroupNumber,InsuranceNumber,InNetworkCoPay,OutNetworkCoPay,StartDate,EndDate,IsCurrent,CreatedON
)
VALUES
(  1, 'Cigna' , 3341189, 'U6899897','30','70','2019-01-01','2020-01-01',1,GETDATE()),
(  1, 'Cigna' , 4456790, 'U889763A','40','80','2018-01-01','2019-01-01',0,GETDATE()),
(  2, 'Unitedhealth' , 9999999, 'U88947937','30','70','2019-01-01','2020-01-01',1,GETDATE()),
(  3, 'Aetna' , 8889999, 'UJ8378AA','30','70','2018-01-01','2020-01-01',1,GETDATE()),
(  4, 'Cigna' , 1112234, 'U9908787','30','70','2019-01-01','2020-01-01',1,GETDATE()),
(  4, 'Cigna' , 0098769, 'U8893748A','50','100','2018-01-01','2019-01-01',0,GETDATE()),
(  5, 'Unitedhealth' , 8495903, 'UAC7490','40','120','2018-01-01','2020-01-01',1,GETDATE()),
(  6, 'Cigna' , 9489039, 'U984989','40','150','2019-01-01','2020-01-01',1,GETDATE()),
(  7, 'Aetna' , 4875390, 'U9048993','30','70','2018-01-01','2020-01-01',1,GETDATE()),
(  8, 'Aetna' , 0499379, 'A3400389','30','70','2019-01-01','2020-01-01',1,GETDATE()),
(  8, 'Cigna' , 4937042, 'A8479903','30','50','2018-01-01','2019-01-01',0,GETDATE()),
(  9, 'Unitedhealth' , 3339890, 'A3940380','50','70','2019-01-01','2020-01-01',1,GETDATE()),
(  10, 'Cigna' , 9843843, 'U2222980','30','70','2017-01-01','2018-01-01',1,GETDATE()),
(  11, 'Cigna' , 9843843, 'U3333980','30','70','2017-01-01','2020-01-01',1,GETDATE()),
(  12, 'Unitedhealth' , 9843843, 'U4444980','30','70','2017-01-01','2020-01-01',1,GETDATE()),
(  13, 'Cigna' , 9843843, 'U5555980','30','70','2017-01-01','2020-01-01',1,GETDATE()),
(  14, 'Unitedhealth' , 9843843, 'U5555980','30','70','2018-01-01','2020-01-01',1,GETDATE()),
(  14, 'Cigna' , 9843843, 'U8975038 2','30','70','2017-01-01','2018-01-01',0,GETDATE()),
(  15, 'Aetna' , 9843843, 'X99084j6','30','70','2017-01-01','2020-01-01',1,GETDATE()),
(  16, 'HCSC' , 9843843, 'U99903894 3','30','70','2015-01-01','2020-01-01',1,GETDATE()),
(  16, 'Cigna' , 9843843, 'U99903894 2','30','70','2010-01-01','2015-01-01',0,GETDATE())
SELECT COUNT(1) FROM dbo.PatientInsurance -- 16

----15. dbo.PatientRegister ,16. dbo.PatientAttendant
----- tr_UpdateAttendantBilling trigger update 17. dbo.PatientBilling

DECLARE @AttendantID [dbo].[UDT_Attendant]
INSERT INTO @AttendantID ( EmployeeID ) VALUES ( 5 ) , ( 8 ) 

EXEC dbo.usp_PatientCheckin @PatientID = 1,     -- int
                            @RoomNumber = 124,    -- int
							@CoPayType = 'IN',
                            @AttendantID = @AttendantID, -- UDT_Attendant
							@CheckinDate = '2019-08-10',
							@CreatedBy = 22
GO

DECLARE @AttendantID [dbo].[UDT_Attendant]
INSERT INTO @AttendantID ( EmployeeID ) VALUES ( 9 ) , ( 12 ) 

EXEC dbo.usp_PatientCheckin @PatientID = 2,     -- int
                            @RoomNumber = 123,    -- int
							@CoPayType = 'IN',
                            @AttendantID = @AttendantID, -- UDT_Attendant
							@CheckinDate = '2019-08-10',
							@CreatedBy = 22
GO
DECLARE @AttendantID [dbo].[UDT_Attendant]
INSERT INTO @AttendantID ( EmployeeID ) VALUES ( 10 ) , ( 20 ) , (7)

EXEC dbo.usp_PatientCheckin @PatientID = 3,     -- int
                            @RoomNumber = 130,    -- int
							@CoPayType = 'IN',
                            @AttendantID = @AttendantID, -- UDT_Attendant
							@CheckinDate = '2019-08-10',
							@CreatedBy = 22
GO

DECLARE @AttendantID [dbo].[UDT_Attendant]
INSERT INTO @AttendantID ( EmployeeID ) VALUES ( 11 ) , ( 17 )

EXEC dbo.usp_PatientCheckin @PatientID = 4,     -- int
                            @RoomNumber = 120,    -- int
							@CoPayType = 'IN',
                            @AttendantID = @AttendantID, -- UDT_Attendant
							@CheckinDate = '2019-08-10',
							@CreatedBy = 22
GO

DECLARE @AttendantID [dbo].[UDT_Attendant]
INSERT INTO @AttendantID ( EmployeeID ) VALUES ( 13 )

EXEC dbo.usp_PatientCheckin @PatientID = 6,     -- int
                            @RoomNumber = 140,    -- int
							@CoPayType = 'OUT',
                            @AttendantID = @AttendantID, -- UDT_Attendant
							@CheckinDate = '2019-08-10',
							@CreatedBy = 22
GO

DECLARE @AttendantID [dbo].[UDT_Attendant]
INSERT INTO @AttendantID ( EmployeeID ) VALUES ( 2) , ( 8 ) , ( 12) 

EXEC dbo.usp_PatientCheckin @PatientID = 7,     -- int
                            @RoomNumber = 120,    -- int
							@CoPayType = 'OUT',
                            @AttendantID = @AttendantID, -- UDT_Attendant
							@CheckinDate = '2019-08-10',
							@CreatedBy = 22
GO

DECLARE @AttendantID [dbo].[UDT_Attendant]
INSERT INTO @AttendantID ( EmployeeID ) VALUES ( 13 ) , ( 20 ) , ( 10) 

EXEC dbo.usp_PatientCheckin @PatientID = 8,     -- int
                            @RoomNumber = 141,    -- int
							@CoPayType = 'IN',
                            @AttendantID = @AttendantID, -- UDT_Attendant
							@CheckinDate = '2019-08-10',
							@CreatedBy = 22
GO
DECLARE @AttendantID [dbo].[UDT_Attendant]
INSERT INTO @AttendantID ( EmployeeID ) VALUES ( 5 ) , ( 9 ) 

EXEC dbo.usp_PatientCheckin @PatientID = 9,     -- int
                            @RoomNumber = 142,    -- int
							@CoPayType = 'IN',
                            @AttendantID = @AttendantID, -- UDT_Attendant
							@CheckinDate = '2019-08-10',
							@CreatedBy = 22
GO

DECLARE @AttendantID [dbo].[UDT_Attendant]
INSERT INTO @AttendantID ( EmployeeID ) VALUES ( 16 ) , ( 9 )

EXEC dbo.usp_PatientCheckin @PatientID = 10,     -- int
                            @RoomNumber = 143,    -- int
							@CoPayType = 'OUT',
                            @AttendantID = @AttendantID ,-- UDT_Attendant
							@CheckinDate = '2019-08-10',
							@CreatedBy = 22
GO

DECLARE @AttendantID [dbo].[UDT_Attendant]
INSERT INTO @AttendantID ( EmployeeID ) VALUES ( 12 ) , ( 13 ) 

EXEC dbo.usp_PatientCheckin @PatientID = 11,     -- int
                            @RoomNumber = 144,    -- int
							@CoPayType = 'IN',
                            @AttendantID = @AttendantID, -- UDT_Attendant
							@CheckinDate = '2019-08-10',
							@CreatedBy = 22
GO

DECLARE @AttendantID [dbo].[UDT_Attendant]
INSERT INTO @AttendantID ( EmployeeID ) VALUES ( 4 ) , ( 20 ) , ( 17) 

EXEC dbo.usp_PatientCheckin @PatientID = 12,     -- int
                            @RoomNumber = 145,    -- int
							@CoPayType = 'IN',
                            @AttendantID = @AttendantID ,-- UDT_Attendant
							@CheckinDate = '2019-08-10',
							@CreatedBy = 22
GO

DECLARE @AttendantID [dbo].[UDT_Attendant]
INSERT INTO @AttendantID ( EmployeeID ) VALUES ( 9 ) , (13 ) 

EXEC dbo.usp_PatientCheckin @PatientID = 13,     -- int
                            @RoomNumber = 146,    -- int
							@CoPayType = 'OUT',
                            @AttendantID = @AttendantID, -- UDT_Attendant
							@CheckinDate = '2019-08-10',
							@CreatedBy = 22
GO

DECLARE @AttendantID [dbo].[UDT_Attendant]
INSERT INTO @AttendantID ( EmployeeID ) VALUES ( 10 ) , (11 ) 

EXEC dbo.usp_PatientCheckin @PatientID = 14,     -- int
                            @RoomNumber = 232,    -- int
							@CoPayType = 'OUT',
                            @AttendantID = @AttendantID ,-- UDT_Attendant
							@CheckinDate = '2019-08-10',
							@CreatedBy = 22
GO

DECLARE @AttendantID [dbo].[UDT_Attendant]
INSERT INTO @AttendantID ( EmployeeID ) VALUES ( 8 ) , (12 ) , ( 10) , (13)

EXEC dbo.usp_PatientCheckin @PatientID = 15,     -- int
                            @RoomNumber = 230,    -- int
							@CoPayType = 'IN',
                            @AttendantID = @AttendantID, -- UDT_Attendant
							@CheckinDate = '2019-08-10',
							@CreatedBy = 22
GO

DECLARE @AttendantID [dbo].[UDT_Attendant]
INSERT INTO @AttendantID ( EmployeeID ) VALUES ( 14 ) , (9 ) , ( 12) , (16)

EXEC dbo.usp_PatientCheckin @PatientID = 16,     -- int
                            @RoomNumber = 235,    -- int
							@CoPayType = 'IN',
                            @AttendantID = @AttendantID ,-- UDT_Attendant
							@CheckinDate = '2019-08-10',
							@CreatedBy = 22


SELECT COUNT(1) FROM dbo.PatientRegister  --- 12
SELECT COUNT(1) FROM dbo.PatientAttendant  --- 45
SELECT COUNT(1) FROM dbo.PatientBilling  --- 12


GO
----18. PatientLabReport 
----- tr_UpdateLabReportBilling trigger update dbo.PatientBilling
DECLARE @TESTRESULT [dbo].[UDT_LabTestDetails]
INSERT INTO @TESTRESULT(LabTestID,Result) VALUES ( 1,'100' ) , ( 2, '400')

EXEC dbo.usp_AddPatientLabReport @PatientID = 1,        -- int
                                 @LabTestDetails = @TESTRESULT, -- UDT_LabTestDetails
								 @AdmitOn = '2019-08-10'
GO
DECLARE @TESTRESULT [dbo].[UDT_LabTestDetails]
INSERT INTO @TESTRESULT(LabTestID,Result) VALUES ( 3,'2000' ) , ( 4, '60')

EXEC dbo.usp_AddPatientLabReport @PatientID = 2,        -- int
                                 @LabTestDetails = @TESTRESULT, -- UDT_LabTestDetails
								 @AdmitOn = '2019-08-10'
GO
DECLARE @TESTRESULT [dbo].[UDT_LabTestDetails]
INSERT INTO @TESTRESULT(LabTestID,Result) VALUES ( 5,'300' ) , ( 6, '10'), ( 7,'200' ) , ( 8, '50')

EXEC dbo.usp_AddPatientLabReport @PatientID = 3,        -- int
                                 @LabTestDetails = @TESTRESULT, -- UDT_LabTestDetails
								 @AdmitOn = '2019-08-10'
GO
DECLARE @TESTRESULT [dbo].[UDT_LabTestDetails]
INSERT INTO @TESTRESULT(LabTestID,Result) VALUES ( 1,'80' ) , ( 10, '7')

EXEC dbo.usp_AddPatientLabReport @PatientID = 4,        -- int
                                 @LabTestDetails = @TESTRESULT, -- UDT_LabTestDetails
								 @AdmitOn = '2019-08-10'
GO
DECLARE @TESTRESULT [dbo].[UDT_LabTestDetails]
INSERT INTO @TESTRESULT(LabTestID,Result) VALUES ( 8,'40' ) , ( 9, '50')

EXEC dbo.usp_AddPatientLabReport @PatientID = 6,        -- int
                                 @LabTestDetails = @TESTRESULT, -- UDT_LabTestDetails
								 @AdmitOn = '2019-08-10'
GO
DECLARE @TESTRESULT [dbo].[UDT_LabTestDetails]
INSERT INTO @TESTRESULT(LabTestID,Result) VALUES ( 6,'10' ) , ( 4, '130')

EXEC dbo.usp_AddPatientLabReport @PatientID = 7,        -- int
                                 @LabTestDetails = @TESTRESULT, -- UDT_LabTestDetails
								 @AdmitOn = '2019-08-10'
GO
DECLARE @TESTRESULT [dbo].[UDT_LabTestDetails]
INSERT INTO @TESTRESULT(LabTestID,Result) VALUES ( 3,'1000' ) , ( 1, '100')

EXEC dbo.usp_AddPatientLabReport @PatientID = 8,        -- int
                                 @LabTestDetails = @TESTRESULT, -- UDT_LabTestDetails
								 @AdmitOn = '2019-08-10'
GO
DECLARE @TESTRESULT [dbo].[UDT_LabTestDetails]
INSERT INTO @TESTRESULT(LabTestID,Result) VALUES ( 5,'280' ) , ( 7, '400')

EXEC dbo.usp_AddPatientLabReport @PatientID = 9,        -- int
                                 @LabTestDetails = @TESTRESULT, -- UDT_LabTestDetails
								 @AdmitOn = '2019-08-10'
GO
DECLARE @TESTRESULT [dbo].[UDT_LabTestDetails]
INSERT INTO @TESTRESULT(LabTestID,Result) VALUES ( 1,'200' ) , ( 2, '200')

EXEC dbo.usp_AddPatientLabReport @PatientID = 10,        -- int
                                 @LabTestDetails = @TESTRESULT, -- UDT_LabTestDetails
								 @AdmitOn = '2019-08-10'
GO
DECLARE @TESTRESULT [dbo].[UDT_LabTestDetails]
INSERT INTO @TESTRESULT(LabTestID,Result) VALUES ( 7,'400' ) , (9, '25')

EXEC dbo.usp_AddPatientLabReport @PatientID = 11,        -- int
                                 @LabTestDetails = @TESTRESULT, -- UDT_LabTestDetails
								 @AdmitOn = '2019-08-10'
GO
DECLARE @TESTRESULT [dbo].[UDT_LabTestDetails]
INSERT INTO @TESTRESULT(LabTestID,Result) VALUES ( 1,'100' ) , ( 2, '400')

EXEC dbo.usp_AddPatientLabReport @PatientID = 12,        -- int
                                 @LabTestDetails = @TESTRESULT, -- UDT_LabTestDetails
								 @AdmitOn = '2019-08-10'
GO
DECLARE @TESTRESULT [dbo].[UDT_LabTestDetails]
INSERT INTO @TESTRESULT(LabTestID,Result) VALUES ( 8,'40' ) , ( 9, '40')

EXEC dbo.usp_AddPatientLabReport @PatientID = 13,        -- int
                                 @LabTestDetails = @TESTRESULT, -- UDT_LabTestDetails
								 @AdmitOn = '2019-08-10'
GO
DECLARE @TESTRESULT [dbo].[UDT_LabTestDetails]
INSERT INTO @TESTRESULT(LabTestID,Result) VALUES ( 11,'45' ) , ( 7, '140'), ( 2,'200')

EXEC dbo.usp_AddPatientLabReport @PatientID = 14,        -- int
                                 @LabTestDetails = @TESTRESULT, -- UDT_LabTestDetails
								 @AdmitOn = '2019-08-10'
GO
DECLARE @TESTRESULT [dbo].[UDT_LabTestDetails]
INSERT INTO @TESTRESULT(LabTestID,Result) VALUES ( 8,'35' )

EXEC dbo.usp_AddPatientLabReport @PatientID = 15,        -- int
                                 @LabTestDetails = @TESTRESULT, -- UDT_LabTestDetails
								 @AdmitOn = '2019-08-10'
GO
DECLARE @TESTRESULT [dbo].[UDT_LabTestDetails]
INSERT INTO @TESTRESULT(LabTestID,Result) VALUES ( 4,'90' ), (3,'900') , (2,'134'), (1,'94')

EXEC dbo.usp_AddPatientLabReport @PatientID = 16,        -- int
                                 @LabTestDetails = @TESTRESULT, -- UDT_LabTestDetails
								 @AdmitOn = '2019-08-10'


SELECT COUNT(1) FROM dbo.PatientLabReport  -- 24
SELECT COUNT(1) FROM dbo.PatientBilling  --- 23



----19. dbo.PatientDisease

INSERT INTO dbo.PatientDisease
(
	PatientRegisterID
    ,DiseaseID
)
VALUES
( 1,1 ), ( 2,3) , 
( 3,5)  , ( 4, 2) , 
( 5, 1) , ( 6, 5) , 
( 7 , 3 ) , ( 8 , 3) , 
( 9, 5) , ( 10, 1) , 
( 11, 12) , ( 12, 8 ) ,
( 13, 12) , ( 14, 1 )

SELECT COUNT(1) FROM dbo.PatientDisease  ---12 
GO
----20. dbo.Feedback

EXEC dbo.usp_RegisterFeedback @FromPatientID = 1, -- int
                              @ToEmployeeID = 2,  -- int
                              @Comment = 'Good Service',      -- varchar(45)
                              @Rating = '9'        -- varchar(45)
GO
EXEC dbo.usp_RegisterFeedback @FromPatientID = 1, -- int
                              @ToEmployeeID = 9,  -- int
                              @Comment = 'Good Behaviour',      -- varchar(45)
                              @Rating = '6'        -- varchar(45)
GO
EXEC dbo.usp_RegisterFeedback @FromPatientID = 1, -- int
                              @ToEmployeeID = 10,  -- int
                              @Comment = 'Bad',      -- varchar(45)
                              @Rating = '1'        -- varchar(45)
GO
EXEC dbo.usp_RegisterFeedback @FromPatientID = 2, -- int
                              @ToEmployeeID = 2,  -- int
                              @Comment = 'Good Service',      -- varchar(45)
                              @Rating = '8'        -- varchar(45)
GO
EXEC dbo.usp_RegisterFeedback @FromPatientID = 3, -- int
                              @ToEmployeeID = 12,  -- int
                              @Comment = 'Good Service',      -- varchar(45)
                              @Rating = '6.5'        -- varchar(45)
GO
EXEC dbo.usp_RegisterFeedback @FromPatientID = 3, -- int
                              @ToEmployeeID = 19,  -- int
                              @Comment = 'Rude Behaviour',      -- varchar(45)
                              @Rating = '5'        -- varchar(45)
GO
EXEC dbo.usp_RegisterFeedback @FromPatientID = 5, -- int
                              @ToEmployeeID = 3,  -- int
                              @Comment = 'Good Service',      -- varchar(45)
                              @Rating = '9'        -- varchar(45)
GO
EXEC dbo.usp_RegisterFeedback @FromPatientID = 5, -- int
                              @ToEmployeeID = 10,  -- int
                              @Comment = 'Good Service',      -- varchar(45)
                              @Rating = '10'        -- varchar(45)
GO
EXEC dbo.usp_RegisterFeedback @FromPatientID = 7, -- int
                              @ToEmployeeID = 5,  -- int
                              @Comment = 'Bad Service',      -- varchar(45)
                              @Rating = '0'        -- varchar(45)
GO
EXEC dbo.usp_RegisterFeedback @FromPatientID = 8, -- int
                              @ToEmployeeID = 6,  -- int
                              @Comment = 'Not good in Communication',      -- varchar(45)
                              @Rating = '4'        -- varchar(45)
GO
EXEC dbo.usp_RegisterFeedback @FromPatientID = 13, -- int
                              @ToEmployeeID = 19,  -- int
                              @Comment = 'Not good',      -- varchar(45)
                              @Rating = '4'        -- varchar(45)
GO
EXEC dbo.usp_RegisterFeedback @FromPatientID = 12, -- int
                              @ToEmployeeID = 20,  -- int
                              @Comment = 'good in Communication',      -- varchar(45)
                              @Rating = '8'        -- varchar(45)
GO
EXEC dbo.usp_RegisterFeedback @FromPatientID = 13, -- int
                              @ToEmployeeID = 15,  -- int
                              @Comment = 'Good Service',      -- varchar(45)
                              @Rating = '7.5'        -- varchar(45)
SELECT COUNT(1) FROM dbo.Feedback  --- 13

--- Patient Payment

EXEC dbo.usp_PatientPayment @PatientRegisterID = 1
							,@Amount = 2910
							,@PaymentType = 'CASH'
GO
EXEC dbo.usp_PatientPayment @PatientRegisterID = 2
							,@Amount = 250
							,@PaymentType = 'CASH'
GO
EXEC dbo.usp_PatientPayment @PatientRegisterID = 3
							,@Amount = 300
							,@PaymentType = 'CreditCard'
GO
EXEC dbo.usp_PatientPayment @PatientRegisterID = 4
							,@Amount = 350
							,@PaymentType = 'CreditCard'
GO
EXEC dbo.usp_PatientPayment @PatientRegisterID = 5
							,@Amount = 2150
							,@PaymentType = 'CreditCard'
GO
EXEC dbo.usp_PatientPayment @PatientRegisterID = 6
							,@Amount = 50
							,@PaymentType = 'CreditCard'
GO
EXEC dbo.usp_PatientPayment @PatientRegisterID = 7
							,@Amount = 250
							,@PaymentType = 'CASH'
GO
EXEC dbo.usp_PatientPayment @PatientRegisterID = 8
							,@Amount = 350
							,@PaymentType = 'CASH'
GO
EXEC dbo.usp_PatientPayment @PatientRegisterID = 9
							,@Amount = 130
							,@PaymentType = 'CHECK'
GO
EXEC dbo.usp_PatientPayment @PatientRegisterID = 10
							,@Amount = 500
							,@PaymentType = 'CHECK'
GO
EXEC dbo.usp_PatientPayment @PatientRegisterID = 11
							,@Amount = 100
							,@PaymentType = 'CHECK'
GO
EXEC dbo.usp_PatientPayment @PatientRegisterID = 12
							,@Amount = 300
							,@PaymentType = 'CHECK'
GO
EXEC dbo.usp_PatientPayment @PatientRegisterID = 13
							,@Amount = 200
							,@PaymentType = 'CreditCard'
GO
EXEC dbo.usp_PatientPayment @PatientRegisterID = 14
							,@Amount = 400
							,@PaymentType = 'CASH'

---- Update Discharge in PatientRegister

UPDATE A 
SET A.DischargeON = 'Aug 11 2019 12:00AM'
FROM dbo.PatientRegister A

SELECT * FROM dbo.PatientAppointment

UPDATE A 
SET A.IsComplete = 1
FROM dbo.PatientAppointment A
WHERE A.AppoitmentDate = '2019-08-10'
AND A.PatientID <> 5

UPDATE A 
SET A.IsNoShow = 1
FROM dbo.PatientAppointment A
WHERE A.AppoitmentDate = '2019-08-10'
AND A.PatientID = 5




GO
/*********************************************************************************************/
-----N. CREATE VIEW
/*********************************************************************************************/
--VIEW 1 : - Get details of Employee , Role , Attended Patient and Address ( Home, Mail and Office ) 

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_GetEmployeeDetails' AND type = 'V')
BEGIN
	 DROP VIEW [dbo].[vw_GetEmployeeDetails]
END
GO
CREATE VIEW [dbo].[vw_GetEmployeeDetails]
AS
	SELECT DISTINCT emp.EmployeeNumber , emp.EmailID , empd.FirstName , empd.LastName , empd.DateOfBirth , empd.PhoneNumber , empd.Gender
			,(
				STUFF(
						( SELECT ','+ T3.DepartmentName
						  FROM dbo.EmployeeDepartment T1
						  JOIN dbo.Employee T2
							ON T1.EmployeeID = T2.EmployeeID
						  JOIN dbo.Department T3
							ON T3.DepartmentID = T1.DepartmentID
						  WHERE T2.EmployeeID = emp.EmployeeID
						  FOR XML PATH ('')), 1, 1, ''
						)


			) AS DepartmentName
			,R.RoleDesc,Temp.totalPatient AS [AttendedPatient],
			ADD_TEMP_1.new_address_1  AS 'Home Address',
			ADD_TEMP_2.new_address_2 AS 'Mail Address'
			--ADD_TEMP_3.new_address_3 AS 'Office Address'
	FROM dbo.Employee emp
	JOIN dbo.EmployeeDetails empd
		ON empd.EmployeeID = emp.EmployeeID
	LEFT JOIN dbo.[Role] R
		ON R.RoleID = empd.RoleID
	LEFT JOIN dbo.EmployeeDepartment dep
		ON Dep.EmployeeID = emp.EmployeeID
	LEFT JOIN dbo.Department D
		ON D.DepartmentID = dep.DepartmentID
	LEFT JOIN ( 
		SELECT EmployeeID,COUNT(1) AS totalPatient 
		FROM dbo.PatientAttendant
		GROUP BY EmployeeID
	) TEMP
		ON TEMP.EmployeeID = emp.EmployeeID
	LEFT JOIN (
		SELECT EmployeeDetailsID , 
				A.AddressTypeID,
				CONCAT(ISNULL(ad.Address1,''),' , ',ISNULL(ad.Address2,''),' , ',ISNULL(ad.City,''),' , ',
						ISNULL(ad.State,''),' , ',ISNULL(ad.Zipcode,'')
					) as new_address_1
		 FROM dbo.EmployeeAddressMapping A 
		 JOIN dbo.ADDRESS ad
			ON Ad.AddressID = A.AddressID
		WHERE A.AddressTypeID IN ( 1) AND  A.IsActive = 1
	) ADD_TEMP_1
		ON Empd.EmployeeDetailsID = ADD_TEMP_1.EmployeeDetailsID
	LEFT JOIN (
		SELECT EmployeeDetailsID , 
				A.AddressTypeID,
				CONCAT(ISNULL(ad.Address1,''),' , ',ISNULL(ad.Address2,''),' , ',ISNULL(ad.City,''),' , ',
						ISNULL(ad.State,''),' , ',ISNULL(ad.Zipcode,'')
					) as new_address_2
		 FROM dbo.EmployeeAddressMapping A 
		 JOIN dbo.ADDRESS ad
			ON Ad.AddressID = A.AddressID
		WHERE A.AddressTypeID IN (2) AND A.IsActive = 1
	) ADD_TEMP_2
		ON empd.EmployeeDetailsID = ADD_TEMP_2.EmployeeDetailsID
	
GO
SELECT * FROM [dbo].[vw_GetEmployeeDetails]


--VIEW 2 : - Get details of Patient , Address and Disease Identified

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_GetPatientDetails' AND type = 'V')
BEGIN
	 DROP VIEW [dbo].[vw_GetPatientDetails]
END
GO
CREATE VIEW [dbo].[vw_GetPatientDetails]
AS
	SELECT P.PatientRegNo , P.FirstName , P.LastName , P.DateOfBirth , P.Gender , P.PhoneNumber , P.EmailID
			,P.Height , P.Weight , P.BloodGroup , T.TotalNumber AS 'TotalHospitalVisit',
			ADD_TEMP_1.new_address_1  AS 'Home Address',
			ADD_TEMP_2.new_address_2 AS 'Mail Address',
			ADD_TEMP_3.new_address_3 AS 'Office Address'
	FROM dbo.Patient P
	LEFT JOIN (
		SELECT PatientID , COUNT(1) AS 'TotalNumber' 
		FROM dbo.PatientRegister
		GROUP BY PatientID
	) T
		ON T.PatientID = P.PatientID
	LEFT JOIN (
		SELECT PatientID , 
				A.AddressTypeID,
				CONCAT(ISNULL(ad.Address1,''),' , ',ISNULL(ad.Address2,''),' , ',ISNULL(ad.City,''),' , ',
						ISNULL(ad.State,''),' , ',ISNULL(ad.Zipcode,'')
					) as new_address_1
		 FROM dbo.PatientAddressMapping A 
		 JOIN dbo.ADDRESS ad
			ON Ad.AddressID = A.AddressID
		WHERE A.AddressTypeID IN ( 1) AND  A.IsActive = 1
	) ADD_TEMP_1
		ON P.PatientID = ADD_TEMP_1.PatientID
	LEFT JOIN (
		SELECT PatientID , 
				A.AddressTypeID,
				CONCAT(ISNULL(ad.Address1,''),' , ',ISNULL(ad.Address2,''),' , ',ISNULL(ad.City,''),' , ',
						ISNULL(ad.State,''),' , ',ISNULL(ad.Zipcode,'')
					) as new_address_2
		 FROM dbo.PatientAddressMapping A 
		 JOIN dbo.ADDRESS ad
			ON Ad.AddressID = A.AddressID
		WHERE A.AddressTypeID IN (2) AND A.IsActive = 1
	) ADD_TEMP_2
		ON P.PatientID = ADD_TEMP_2.PatientID
	LEFT JOIN (
		SELECT PatientID , 
				A.AddressTypeID,
				CONCAT(ISNULL(ad.Address1,''),' , ',ISNULL(ad.Address2,''),' , ',ISNULL(ad.City,''),' , ',
						ISNULL(ad.State,''),' , ',ISNULL(ad.Zipcode,'')
					) as new_address_3
		 FROM dbo.PatientAddressMapping A 
		 JOIN dbo.ADDRESS ad
			ON Ad.AddressID = A.AddressID
		WHERE A.AddressTypeID IN (3) AND A.IsActive = 1
	) ADD_TEMP_3
		ON P.PatientID = ADD_TEMP_3.PatientID

GO
SELECT * FROM [dbo].[vw_GetPatientDetails]
----- --VIEW 3 : - Get Disease and Number of patient

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_GetDiseaseCount' AND type = 'V')
BEGIN
	 DROP VIEW [dbo].[vw_GetDiseaseCount]
END
GO
CREATE VIEW [dbo].[vw_GetDiseaseCount]
AS
	SELECT D.Name AS DiseaseName , COUNT(PD.PatientRegisterID) AS 'TotalPatientCount'
	FROM dbo.Disease D 
	LEFT JOIN dbo.PatientDisease PD
		ON D.DiseaseID = PD.DiseaseID
	GROUP BY D.Name
GO
SELECT * FROM [dbo].[vw_GetDiseaseCount]

------ VIEW 4: - Get Patient Address Details. 

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_GetPatientAddressDetails' AND type = 'V')
BEGIN
	 DROP VIEW [dbo].[vw_GetPatientAddressDetails]
END
GO
CREATE VIEW [dbo].[vw_GetPatientAddressDetails]
AS
	SELECT D.PatientRegNo , D.FirstName , D.LastName , Address1, Address2, City , State  , Country , ZipCode , C.Type AS AddressType
	FROM dbo.Address A 
	JOIN dbo.PatientAddressMapping B
		ON A.AddressID = B.AddressID
	JOIN dbo.AddressType C 
		ON C.AddressTypeID = B.AddressTypeID
	JOIN dbo.Patient D
		ON D.PatientID = B.PatientID

GO
SELECT * FROM [dbo].[vw_GetPatientAddressDetails]

