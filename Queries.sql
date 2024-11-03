USE [master]
GO
/****** Object:  Database [HotelDB]    Script Date: 11/3/2024 8:49:49 AM ******/
CREATE DATABASE [HotelDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'HotelDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\HotelDB.mdf' , SIZE = 4096KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'HotelDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\HotelDB_log.ldf' , SIZE = 9216KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [HotelDB] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [HotelDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [HotelDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [HotelDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [HotelDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [HotelDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [HotelDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [HotelDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [HotelDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [HotelDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [HotelDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [HotelDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [HotelDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [HotelDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [HotelDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [HotelDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [HotelDB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [HotelDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [HotelDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [HotelDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [HotelDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [HotelDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [HotelDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [HotelDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [HotelDB] SET RECOVERY FULL 
GO
ALTER DATABASE [HotelDB] SET  MULTI_USER 
GO
ALTER DATABASE [HotelDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [HotelDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [HotelDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [HotelDB] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [HotelDB] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [HotelDB] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'HotelDB', N'ON'
GO
ALTER DATABASE [HotelDB] SET QUERY_STORE = OFF
GO
USE [HotelDB]
GO
/****** Object:  UserDefinedFunction [dbo].[UDFGetRoomOfCustomer]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Function [dbo].[UDFGetRoomOfCustomer](@CustomerPassportNumber decimal)
returns @RoomOfCustomer table
(
RoomID int,
ReserveDate datetime
)
as
begin
insert into @RoomOfCustomer
SELECT     tblReserve.RoomId, tblReserve.ReserveDate
FROM         tblReserve INNER JOIN
             tblCustomer ON tblReserve.CustomerId = tblCustomer.CustomerId
             where CustomerPassportNumber=@CustomerPassportNumber
GROUP BY tblReserve.RoomId, tblReserve.ReserveDate
return
end
GO
/****** Object:  UserDefinedFunction [dbo].[UdfGetTotalPriceWithTahvilID]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[UdfGetTotalPriceWithTahvilID]
(
	@TahvilID int
)
RETURNS decimal(18,0)
AS
BEGIN
	declare @m decimal(18,0)
	set @m = isnull((SELECT SUM(ServiceTotalPrice) AS TotalPriceSum FROM   dbo.tblOtherServices GROUP BY TahvilID HAVING      (TahvilID = @TahvilID)) , 0) 
	RETURN @m
END
GO
/****** Object:  UserDefinedFunction [dbo].[UdfGetTotalStayTimePriceWithTahvilID]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create FUNCTION [dbo].[UdfGetTotalStayTimePriceWithTahvilID]
(
	@TahvilID int
)
RETURNS decimal(18,0)
AS
BEGIN
	declare @m decimal(18,0)
	set @m = isnull((SELECT     dbo.tblTahvil.StayingTime * dbo.tblRoom.RoomPrice AS StayTimePrice
FROM         dbo.tblTahvil INNER JOIN
                      dbo.tblReserve ON dbo.tblTahvil.ReserveID = dbo.tblReserve.ReserveId INNER JOIN
                      dbo.tblRoom ON dbo.tblReserve.RoomId = dbo.tblRoom.RoomId GROUP BY dbo.tblTahvil.TahvilId, (dbo.tblTahvil.StayingTime * dbo.tblRoom.RoomPrice) HAVING      (dbo.tblTahvil.TahvilId = @TahvilID)) , 0) 
	RETURN @m
END
GO
/****** Object:  UserDefinedFunction [dbo].[UDFIsRoomReserved]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function [dbo].[UDFIsRoomReserved](@RoomID int)
returns nvarchar(20)

as
begin
declare @c int
declare @reserved nvarchar(20)
select @c=Count(*) from tblReserve
where RoomId=@RoomID and ReserveDate=GetDate()
if(@c=0)
set @reserved='false'
else 
set @reserved='true'
return @reserved
end
GO
/****** Object:  UserDefinedFunction [dbo].[UDFTotalIncomeOfRoom]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Function [dbo].[UDFTotalIncomeOfRoom](@RoomID int)
returns decimal
as
begin
declare @Income decimal
SELECT    @Income= sum(tblRoom.RoomPrice)
FROM         tblRoom INNER JOIN
             tblReserve ON tblRoom.RoomId = tblReserve.RoomId
group by  tblRoom.RoomID
return @Income
end
GO
/****** Object:  Table [dbo].[tblReserve]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblReserve](
	[ReserveId] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[CustomerId] [decimal](18, 0) NOT NULL,
	[OperatorId] [int] NOT NULL,
	[RoomId] [decimal](18, 0) NOT NULL,
	[ReserveDate] [datetime] NOT NULL,
 CONSTRAINT [PK_tblReserve] PRIMARY KEY CLUSTERED 
(
	[ReserveId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRoomTypes]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRoomTypes](
	[RoomTypeID] [int] NOT NULL,
	[RoomTypeDescription] [nvarchar](250) NOT NULL,
 CONSTRAINT [PK_tblRoomTypes] PRIMARY KEY CLUSTERED 
(
	[RoomTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRoom]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRoom](
	[RoomId] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[RoomTypeID] [int] NULL,
	[RoomNumberBeds] [int] NOT NULL,
	[RoomPrice] [money] NOT NULL,
 CONSTRAINT [PK_tblRoom] PRIMARY KEY CLUSTERED 
(
	[RoomId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTahvil]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTahvil](
	[TahvilId] [int] IDENTITY(1,1) NOT NULL,
	[ReserveID] [decimal](18, 0) NULL,
	[DateInPut] [datetime] NOT NULL,
	[DateOutPut] [datetime] NULL,
	[StayingTime]  AS (datediff(day,[DateInPut],[DateOutPut])),
 CONSTRAINT [PK_tblTahvil] PRIMARY KEY CLUSTERED 
(
	[TahvilId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[XtblFreeRooms]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[XtblFreeRooms]
AS
SELECT     dbo.tblRoom.RoomId, dbo.tblRoomTypes.RoomTypeDescription
FROM         dbo.tblRoom INNER JOIN
                      dbo.tblRoomTypes ON dbo.tblRoom.RoomTypeID = dbo.tblRoomTypes.RoomTypeID
WHERE     (dbo.tblRoom.RoomId NOT IN
                          (SELECT     tblRoom_1.RoomId
                             FROM         dbo.tblRoom AS tblRoom_1 INNER JOIN
                                                   dbo.tblReserve ON tblRoom_1.RoomId = dbo.tblReserve.RoomId INNER JOIN
                                                   dbo.tblTahvil ON dbo.tblReserve.ReserveId = dbo.tblTahvil.ReserveID
                             WHERE     (dbo.tblTahvil.DateOutPut IS NULL)))
GO
/****** Object:  View [dbo].[XtblNotFreeRooms]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[XtblNotFreeRooms]
AS
SELECT     dbo.tblRoom.RoomId, dbo.tblRoomTypes.RoomTypeDescription
FROM         dbo.tblRoom INNER JOIN
                      dbo.tblRoomTypes ON dbo.tblRoom.RoomTypeID = dbo.tblRoomTypes.RoomTypeID
WHERE     (dbo.tblRoom.RoomId IN
                          (SELECT     tblRoom_1.RoomId
                             FROM         dbo.tblRoom AS tblRoom_1 INNER JOIN
                                                   dbo.tblReserve ON tblRoom_1.RoomId = dbo.tblReserve.RoomId INNER JOIN
                                                   dbo.tblTahvil ON dbo.tblReserve.ReserveId = dbo.tblTahvil.ReserveID
                             WHERE     (dbo.tblTahvil.DateOutPut IS NULL)))
GO
/****** Object:  Table [dbo].[tblPayments]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPayments](
	[PaymentID] [int] IDENTITY(1,1) NOT NULL,
	[TahvilID] [int] NOT NULL,
	[StayInHotelPrice]  AS ([dbo].[UdfGetTotalStayTimePriceWithTahvilID]([TahvilID])),
	[OtherServiceTotalPrice]  AS ([dbo].[UdfGetTotalPriceWithTahvilID]([TahvilID])),
	[TotalDebt]  AS ([dbo].[UdfGetTotalStayTimePriceWithTahvilID]([TahvilID])+[dbo].[UdfGetTotalPriceWithTahvilID]([TahvilID])),
	[IsThantCustomerPayed] [bit] NOT NULL,
 CONSTRAINT [PK_tblPayments_1] PRIMARY KEY CLUSTERED 
(
	[TahvilID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[XtblPaymentPerRoom]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[XtblPaymentPerRoom]
AS
SELECT     dbo.tblRoom.RoomId, dbo.tblRoomTypes.RoomTypeDescription, SUM(dbo.tblPayments.TotalDebt) AS TotalGroupDept
FROM         dbo.tblRoom INNER JOIN
                      dbo.tblRoomTypes ON dbo.tblRoom.RoomTypeID = dbo.tblRoomTypes.RoomTypeID INNER JOIN
                      dbo.tblReserve ON dbo.tblRoom.RoomId = dbo.tblReserve.RoomId INNER JOIN
                      dbo.tblTahvil ON dbo.tblReserve.ReserveId = dbo.tblTahvil.ReserveID INNER JOIN
                      dbo.tblPayments ON dbo.tblTahvil.TahvilId = dbo.tblPayments.TahvilID
GROUP BY dbo.tblRoom.RoomId, dbo.tblRoomTypes.RoomTypeDescription
GO
/****** Object:  View [dbo].[XtblPaymentPerRoomType]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[XtblPaymentPerRoomType]
AS
SELECT     dbo.tblRoomTypes.RoomTypeDescription, SUM(dbo.tblPayments.TotalDebt) AS TotalGroupDept
FROM         dbo.tblRoom INNER JOIN
                      dbo.tblRoomTypes ON dbo.tblRoom.RoomTypeID = dbo.tblRoomTypes.RoomTypeID INNER JOIN
                      dbo.tblReserve ON dbo.tblRoom.RoomId = dbo.tblReserve.RoomId INNER JOIN
                      dbo.tblTahvil ON dbo.tblReserve.ReserveId = dbo.tblTahvil.ReserveID INNER JOIN
                      dbo.tblPayments ON dbo.tblTahvil.TahvilId = dbo.tblPayments.TahvilID
GROUP BY dbo.tblRoomTypes.RoomTypeDescription
GO
/****** Object:  Table [dbo].[tblServiceTypes]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblServiceTypes](
	[ServiceTypeID] [int] IDENTITY(1,1) NOT NULL,
	[ServiceTypeDescription] [nvarchar](250) NOT NULL,
 CONSTRAINT [PK_tblServiceTypes] PRIMARY KEY CLUSTERED 
(
	[ServiceTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblOtherServices]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblOtherServices](
	[ServiceID] [int] IDENTITY(1,1) NOT NULL,
	[TahvilID] [int] NOT NULL,
	[ServiceTypeID] [int] NOT NULL,
	[ServiceQuantity] [decimal](18, 0) NOT NULL,
	[ServiceUnitPrice] [decimal](18, 0) NOT NULL,
	[ServiceTotalPrice]  AS ([ServiceQuantity]*[ServiceUnitPrice]),
	[ServiceDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_tblOtherServices] PRIMARY KEY CLUSTERED 
(
	[TahvilID] ASC,
	[ServiceTypeID] ASC,
	[ServiceQuantity] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[XtblPaymentsService]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[XtblPaymentsService]
AS
SELECT     dbo.tblServiceTypes.ServiceTypeDescription, SUM(dbo.tblOtherServices.ServiceTotalPrice) AS PaymentOfPerService
FROM         dbo.tblOtherServices INNER JOIN
                      dbo.tblServiceTypes ON dbo.tblOtherServices.ServiceTypeID = dbo.tblServiceTypes.ServiceTypeID
GROUP BY dbo.tblServiceTypes.ServiceTypeDescription
GO
/****** Object:  View [dbo].[XtblNotSaledService]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[XtblNotSaledService]
AS
SELECT     ServiceTypeID, ServiceTypeDescription
FROM         dbo.tblServiceTypes
WHERE     (NOT (ServiceTypeID IN
                          (SELECT     dbo.tblOtherServices.ServiceTypeID
                             FROM         dbo.tblOtherServices INNER JOIN
                                                   dbo.tblServiceTypes AS tblServiceTypes_1 ON dbo.tblOtherServices.ServiceTypeID = tblServiceTypes_1.ServiceTypeID
                             GROUP BY dbo.tblOtherServices.ServiceTypeID)))
GO
/****** Object:  View [dbo].[Rezervnashode]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Rezervnashode]
AS
SELECT     dbo.tblRoom.RoomId, dbo.tblRoomTypes.RoomTypeDescription, dbo.tblRoom.RoomPrice
FROM         dbo.tblRoom INNER JOIN
                      dbo.tblRoomTypes ON dbo.tblRoom.RoomTypeID = dbo.tblRoomTypes.RoomTypeID
WHERE     (dbo.tblRoom.RoomId NOT IN
                          (SELECT     RoomId
                             FROM         dbo.tblReserve))
GO
/****** Object:  Table [dbo].[tblCustomer]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCustomer](
	[CustomerId] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[CustomerName] [nvarchar](150) NOT NULL,
	[CustomerLName] [nvarchar](150) NOT NULL,
	[CustomerPassportNumber] [decimal](18, 0) NOT NULL,
	[CustomerCountry] [nvarchar](150) NOT NULL,
	[CustomerCity] [nvarchar](150) NOT NULL,
 CONSTRAINT [PK_tblCustomer] PRIMARY KEY CLUSTERED 
(
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[MaxRezerveOtagh]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MaxRezerveOtagh]
AS
SELECT     TOP (2) dbo.tblCustomer.CustomerName, dbo.tblCustomer.CustomerLName, COUNT(dbo.tblRoom.RoomId) AS Expr1
FROM         dbo.tblCustomer INNER JOIN
                      dbo.tblReserve ON dbo.tblCustomer.CustomerId = dbo.tblReserve.CustomerId INNER JOIN
                      dbo.tblRoom ON dbo.tblReserve.RoomId = dbo.tblRoom.RoomId
GROUP BY dbo.tblCustomer.CustomerId, dbo.tblCustomer.CustomerName, dbo.tblCustomer.CustomerLName
ORDER BY Expr1 DESC
GO
/****** Object:  Table [dbo].[tblOperator]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblOperator](
	[OperatorId] [int] IDENTITY(1,1) NOT NULL,
	[OperatorName] [nvarchar](150) NOT NULL,
	[OperatorLName] [nvarchar](150) NOT NULL,
	[OperatorUser] [nvarchar](150) NOT NULL,
	[OperatorPass] [nvarchar](150) NOT NULL,
 CONSTRAINT [PK_tblOperator] PRIMARY KEY CLUSTERED 
(
	[OperatorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[OperatorReseveRoom]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OperatorReseveRoom]
AS
SELECT     dbo.tblOperator.OperatorName, dbo.tblReserve.RoomId, dbo.tblReserve.ReserveDate
FROM         dbo.tblOperator INNER JOIN
                      dbo.tblReserve ON dbo.tblOperator.OperatorId = dbo.tblReserve.OperatorId
GO
/****** Object:  View [dbo].[CusomerReserve]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CusomerReserve]
AS
SELECT     dbo.tblCustomer.CustomerId, dbo.tblCustomer.CustomerName, dbo.tblCustomer.CustomerLName, dbo.tblReserve.RoomId
FROM         dbo.tblCustomer INNER JOIN
                      dbo.tblReserve ON dbo.tblCustomer.CustomerId = dbo.tblReserve.CustomerId
GROUP BY dbo.tblCustomer.CustomerId, dbo.tblCustomer.CustomerName, dbo.tblCustomer.CustomerLName, dbo.tblReserve.RoomId
GO
/****** Object:  View [dbo].[RoomReserved]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[RoomReserved]
AS
SELECT     dbo.tblRoom.RoomId, dbo.tblRoom.RoomNumberBeds, dbo.tblRoom.RoomPrice, dbo.tblRoomTypes.RoomTypeDescription
FROM         dbo.tblReserve INNER JOIN
                      dbo.tblRoom ON dbo.tblReserve.RoomId = dbo.tblRoom.RoomId INNER JOIN
                      dbo.tblRoomTypes ON dbo.tblRoom.RoomTypeID = dbo.tblRoomTypes.RoomTypeID
GROUP BY dbo.tblRoom.RoomId, dbo.tblRoom.RoomNumberBeds, dbo.tblRoom.RoomPrice, dbo.tblRoomTypes.RoomTypeDescription
GO
/****** Object:  View [dbo].[XtblForM]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[XtblForM]
AS
SELECT     dbo.tblTahvil.TahvilId, dbo.tblTahvil.StayingTime * dbo.tblRoom.RoomPrice AS StayTimePrice
FROM         dbo.tblTahvil INNER JOIN
                      dbo.tblReserve ON dbo.tblTahvil.ReserveID = dbo.tblReserve.ReserveId INNER JOIN
                      dbo.tblRoom ON dbo.tblReserve.RoomId = dbo.tblRoom.RoomId
GROUP BY dbo.tblTahvil.TahvilId, dbo.tblTahvil.StayingTime * dbo.tblRoom.RoomPrice
GO
/****** Object:  Table [dbo].[tblPhoneNumbers]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPhoneNumbers](
	[PhoneNumbersID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [decimal](18, 0) NOT NULL,
	[PhoneNumberType] [smallint] NOT NULL,
	[PhoneNumber] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tblPhoneNumbers] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC,
	[PhoneNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblPhoneNumberTypes]    Script Date: 11/3/2024 8:49:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPhoneNumberTypes](
	[PhoneNumberTypeID] [smallint] IDENTITY(1,1) NOT NULL,
	[PhonenumberTypeDescription] [nvarchar](150) NOT NULL,
 CONSTRAINT [PK_tblPhoneNumberTypes] PRIMARY KEY CLUSTERED 
(
	[PhoneNumberTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblOtherServices]  WITH CHECK ADD  CONSTRAINT [FK_tblOtherServices_tblServiceTypes] FOREIGN KEY([ServiceTypeID])
REFERENCES [dbo].[tblServiceTypes] ([ServiceTypeID])
GO
ALTER TABLE [dbo].[tblOtherServices] CHECK CONSTRAINT [FK_tblOtherServices_tblServiceTypes]
GO
ALTER TABLE [dbo].[tblOtherServices]  WITH CHECK ADD  CONSTRAINT [FK_tblOtherServices_tblTahvil] FOREIGN KEY([TahvilID])
REFERENCES [dbo].[tblTahvil] ([TahvilId])
GO
ALTER TABLE [dbo].[tblOtherServices] CHECK CONSTRAINT [FK_tblOtherServices_tblTahvil]
GO
ALTER TABLE [dbo].[tblPayments]  WITH CHECK ADD  CONSTRAINT [FK_tblPayments_tblTahvil] FOREIGN KEY([TahvilID])
REFERENCES [dbo].[tblTahvil] ([TahvilId])
GO
ALTER TABLE [dbo].[tblPayments] CHECK CONSTRAINT [FK_tblPayments_tblTahvil]
GO
ALTER TABLE [dbo].[tblPhoneNumbers]  WITH CHECK ADD  CONSTRAINT [FK_tblPhoneNumbers_tblCustomer] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[tblCustomer] ([CustomerId])
GO
ALTER TABLE [dbo].[tblPhoneNumbers] CHECK CONSTRAINT [FK_tblPhoneNumbers_tblCustomer]
GO
ALTER TABLE [dbo].[tblPhoneNumbers]  WITH CHECK ADD  CONSTRAINT [FK_tblPhoneNumbers_tblPhoneNumberTypes] FOREIGN KEY([PhoneNumberType])
REFERENCES [dbo].[tblPhoneNumberTypes] ([PhoneNumberTypeID])
GO
ALTER TABLE [dbo].[tblPhoneNumbers] CHECK CONSTRAINT [FK_tblPhoneNumbers_tblPhoneNumberTypes]
GO
ALTER TABLE [dbo].[tblReserve]  WITH CHECK ADD  CONSTRAINT [FK_tblReserve_tblCustomer] FOREIGN KEY([CustomerId])
REFERENCES [dbo].[tblCustomer] ([CustomerId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblReserve] CHECK CONSTRAINT [FK_tblReserve_tblCustomer]
GO
ALTER TABLE [dbo].[tblReserve]  WITH CHECK ADD  CONSTRAINT [FK_tblReserve_tblOperator] FOREIGN KEY([OperatorId])
REFERENCES [dbo].[tblOperator] ([OperatorId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblReserve] CHECK CONSTRAINT [FK_tblReserve_tblOperator]
GO
ALTER TABLE [dbo].[tblReserve]  WITH CHECK ADD  CONSTRAINT [FK_tblReserve_tblRoom] FOREIGN KEY([RoomId])
REFERENCES [dbo].[tblRoom] ([RoomId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblReserve] CHECK CONSTRAINT [FK_tblReserve_tblRoom]
GO
ALTER TABLE [dbo].[tblRoom]  WITH CHECK ADD  CONSTRAINT [FK_tblRoom_tblRoomTypes] FOREIGN KEY([RoomTypeID])
REFERENCES [dbo].[tblRoomTypes] ([RoomTypeID])
GO
ALTER TABLE [dbo].[tblRoom] CHECK CONSTRAINT [FK_tblRoom_tblRoomTypes]
GO
ALTER TABLE [dbo].[tblTahvil]  WITH CHECK ADD  CONSTRAINT [FK_tblTahvil_tblReserve] FOREIGN KEY([ReserveID])
REFERENCES [dbo].[tblReserve] ([ReserveId])
GO
ALTER TABLE [dbo].[tblTahvil] CHECK CONSTRAINT [FK_tblTahvil_tblReserve]
GO
/****** Object:  StoredProcedure [dbo].[SPGetCustomer]    Script Date: 11/3/2024 8:49:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[SPGetCustomer] 
@CustomerPassportNumber decimal(18,0)
as
begin
SELECT * FROM tblCustomer
where CustomerPassportNumber=@CustomerPassportNumber
end
GO
/****** Object:  StoredProcedure [dbo].[SPInsertCustomer]    Script Date: 11/3/2024 8:49:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[SPInsertCustomer]
@CustomerName nvarchar(50),
@CustomerLName nvarchar(50),
@CustomerPassportNumber decimal(18,0),
@CustomerCountry nvarchar(50),
@CustomerCity nvarchar(50),
@CustomerTell decimal(18,0)
as
begin
insert into tblCustomer 
values(@CustomerName,@CustomerLName,@CustomerPassportNumber,
@CustomerCountry ,@CustomerCity,@CustomerTell
)
end
GO
/****** Object:  StoredProcedure [dbo].[SPOperatorTotalSell]    Script Date: 11/3/2024 8:49:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[SPOperatorTotalSell]
as
begin
SELECT     tblOperator.OperatorName, tblOperator.OperatorLName, tblReserve.RoomId, SUM(tblRoom.RoomPrice) AS Expr1
FROM         tblOperator INNER JOIN
                      tblReserve ON tblOperator.OperatorId = tblReserve.OperatorId INNER JOIN
                      tblRoom ON tblReserve.RoomId = tblRoom.RoomId
GROUP BY tblOperator.OperatorName, tblOperator.OperatorLName, tblReserve.RoomId
end
GO
/****** Object:  DdlTrigger [NoEventOnSecificTable]    Script Date: 11/3/2024 8:49:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create TRIGGER [NoEventOnSecificTable] ON DATABASE   
FOR 
DROP_TABLE , ALTER_TABLE
AS
DECLARE @eventData XML,
        @uname NVARCHAR(50),
        @oname NVARCHAR(100),
        @otext VARCHAR(MAX),
        @etype NVARCHAR(100),
        @edate DATETIME
SET @eventData = eventdata()
SELECT
        @edate=GETDATE(),
        @uname=@eventData.value('data(/EVENT_INSTANCE/UserName)[1]', 'SYSNAME'),
        @oname=@eventData.value('data(/EVENT_INSTANCE/ObjectName)[1]', 'SYSNAME'),
        @otext=@eventData.value('data(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 
                'VARCHAR(MAX)'),
        @etype=@eventData.value('data(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(100)')
IF @oname IN ('tblReserve')
  BEGIN
    DECLARE @err varchar(100)
    SET @err = 'Table ' + @oname  + ' is super duper protected and cannot be dropped.'
    RAISERROR (@err, 16, 1) ;
    ROLLBACK;
END
GO
DISABLE TRIGGER [NoEventOnSecificTable] ON DATABASE
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tblCustomer"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 252
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblReserve"
            Begin Extent = 
               Top = 6
               Left = 290
               Bottom = 125
               Right = 450
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CusomerReserve'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CusomerReserve'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[20] 2[14] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tblCustomer"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 152
               Right = 252
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblReserve"
            Begin Extent = 
               Top = 6
               Left = 290
               Bottom = 160
               Right = 450
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblRoom"
            Begin Extent = 
               Top = 6
               Left = 488
               Bottom = 170
               Right = 664
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MaxRezerveOtagh'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MaxRezerveOtagh'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tblOperator"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 203
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblReserve"
            Begin Extent = 
               Top = 6
               Left = 241
               Bottom = 125
               Right = 401
            End
            DisplayFlags = 280
            TopColumn = 2
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'OperatorReseveRoom'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'OperatorReseveRoom'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tblRoom"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 174
               Right = 214
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblRoomTypes"
            Begin Extent = 
               Top = 6
               Left = 252
               Bottom = 96
               Right = 445
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 2565
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Rezervnashode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Rezervnashode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[20] 2[14] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tblReserve"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 166
               Right = 198
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblRoom"
            Begin Extent = 
               Top = 6
               Left = 236
               Bottom = 128
               Right = 412
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblRoomTypes"
            Begin Extent = 
               Top = 6
               Left = 450
               Bottom = 96
               Right = 659
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 3360
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'RoomReserved'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'RoomReserved'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[16] 2[15] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tblTahvil"
            Begin Extent = 
               Top = 23
               Left = 74
               Bottom = 175
               Right = 234
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblRoom"
            Begin Extent = 
               Top = 36
               Left = 757
               Bottom = 164
               Right = 933
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblReserve"
            Begin Extent = 
               Top = 6
               Left = 450
               Bottom = 161
               Right = 610
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 4845
         Alias = 2385
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'XtblForM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'XtblForM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[33] 4[28] 2[15] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tblRoom"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 126
               Right = 214
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblRoomTypes"
            Begin Extent = 
               Top = 13
               Left = 299
               Bottom = 103
               Right = 492
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'XtblFreeRooms'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'XtblFreeRooms'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tblRoom"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 126
               Right = 214
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblRoomTypes"
            Begin Extent = 
               Top = 6
               Left = 252
               Bottom = 96
               Right = 445
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'XtblNotFreeRooms'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'XtblNotFreeRooms'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[20] 2[16] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tblServiceTypes"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 96
               Right = 239
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'XtblNotSaledService'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'XtblNotSaledService'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tblRoom"
            Begin Extent = 
               Top = 22
               Left = 321
               Bottom = 142
               Right = 497
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblRoomTypes"
            Begin Extent = 
               Top = 33
               Left = 21
               Bottom = 123
               Right = 214
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblPayments"
            Begin Extent = 
               Top = 8
               Left = 1044
               Bottom = 187
               Right = 1246
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblReserve"
            Begin Extent = 
               Top = 8
               Left = 594
               Bottom = 128
               Right = 754
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblTahvil"
            Begin Extent = 
               Top = 2
               Left = 778
               Bottom = 122
               Right = 938
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 3105
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 2055
         Alias = ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'XtblPaymentPerRoom'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'XtblPaymentPerRoom'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'XtblPaymentPerRoom'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[31] 4[18] 2[33] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tblRoom"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 126
               Right = 230
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblRoomTypes"
            Begin Extent = 
               Top = 6
               Left = 268
               Bottom = 96
               Right = 477
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblReserve"
            Begin Extent = 
               Top = 6
               Left = 515
               Bottom = 126
               Right = 691
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblTahvil"
            Begin Extent = 
               Top = 6
               Left = 729
               Bottom = 126
               Right = 905
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblPayments"
            Begin Extent = 
               Top = 6
               Left = 943
               Bottom = 126
               Right = 1161
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 2310
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1455
         Alias = 900' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'XtblPaymentPerRoomType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'XtblPaymentPerRoomType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'XtblPaymentPerRoomType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[20] 2[12] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tblServiceTypes"
            Begin Extent = 
               Top = 96
               Left = 865
               Bottom = 186
               Right = 1066
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblOtherServices"
            Begin Extent = 
               Top = 2
               Left = 444
               Bottom = 172
               Right = 709
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 3060
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'XtblPaymentsService'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'XtblPaymentsService'
GO
USE [master]
GO
ALTER DATABASE [HotelDB] SET  READ_WRITE 
GO
