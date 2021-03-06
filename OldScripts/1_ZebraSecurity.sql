CREATE DATABASE [ZebraAccount];
GO

USE [ZebraAccount];
GO

CREATE TABLE [dbo].[User]
(
     [UserID]                 INT IDENTITY(1, 1) NOT NULL, 
     [RoleTypeID]             BIT NOT NULL DEFAULT(0), 
     [Email]                  NVARCHAR(256) NULL, 
     [IsEmailConfirmed]       BIT NOT NULL, 
     [PasswordHash]           NVARCHAR(256) NULL, 
     [PhoneNumber]            NVARCHAR(256) NULL, 
     [IsPhoneNumberConfirmed] BIT NOT NULL DEFAULT(0), 
     [IsTwoFactorEnabled]     BIT NOT NULL, 
     [AccessFailedCount]      INT NOT NULL DEFAULT(0), 
     [RegistrationDate]       DATETIME2(7) NOT NULL DEFAULT(GETDATE()), 
     [IsDeleted]              BIT NOT NULL DEFAULT 0, 
     CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED([UserID] ASC)
);
GO

CREATE TABLE [dbo].[Token]
(
     [TokenID]      BIGINT IDENTITY(1, 1) NOT NULL, 
     [UserID]       INT NOT NULL, 
     [ExpiresIn]    BIGINT NOT NULL, 
     [RefreshToken] NVARCHAR(500) NOT NULL, 
     CONSTRAINT [PK_Token] PRIMARY KEY CLUSTERED([TokenID] ASC)
);
GO

CREATE TABLE [dbo].[Social]
(
     [SocialID]      INT IDENTITY(1, 1) NOT NULL, 
     [SocialTypeID]  INT NOT NULL, 
     [InternalID]    INT NOT NULL, 
     [ExternalID]    BIGINT NOT NULL, 
     [Email]         NVARCHAR(256) NULL, 
     [PhoneNumber]   NVARCHAR(256) NULL, 
     [ExternalToken] NVARCHAR(256) NULL, 
     [ExpiresIn]     BIGINT NOT NULL, 
     [IsDeleted]     BIT NOT NULL DEFAULT 0, 
     CONSTRAINT [PK_Social] PRIMARY KEY CLUSTERED([SocialID] ASC)
);
GO

CREATE TABLE [dbo].[SocialType]
(
     [SocialTypeID] INT IDENTITY(1, 1) NOT NULL, 
     [EnglishName]  NVARCHAR(256) NOT NULL, 
     [RussianName]  NVARCHAR(256) NOT NULL
	CONSTRAINT [PK_SocialType] PRIMARY KEY CLUSTERED ([SocialTypeID] ASC)
);
GO

CREATE TABLE [dbo].[RoleType]
(
     [RoleTypeID]  INT IDENTITY(1, 1) NOT NULL, 
     [EnglishName] NVARCHAR(256) NOT NULL, 
     [RussianName] NVARCHAR(256) NOT NULL
	 CONSTRAINT [PK_RoleType] PRIMARY KEY CLUSTERED ([RoleTypeID] ASC)
);
GO

CREATE PROC [dbo].[uspAddUser] 
     @email                            NVARCHAR(256), 
     @isEmailConfirmed                 BIT, 
     @passwordHash                     NVARCHAR(256), 
     @phoneNumber                      NVARCHAR(256), 
     @isPhoneNumberConfirmed           BIT, 
     @isTwoFactorEnabled BIT, 
     @registrationDate                 DATETIME2, 
     @userID                           INT = NULL OUTPUT
AS
     BEGIN
         INSERT INTO [dbo].[User]
         VALUES
                (
                0, @email, @isEmailConfirmed, @passwordHash, @phoneNumber, @isPhoneNumberConfirmed, @isTwoFactorEnabled, @registrationDate, 0
                );
         SELECT @userID = @@IDENTITY;
     END;
         RETURN @userID;
GO

CREATE PROC [dbo].[uspAddUserWithID] 
     @userID                           INT, 
     @email                            NVARCHAR(256), 
     @isEmailConfirmed                 BIT, 
     @passwordHash                     NVARCHAR(256), 
     @phoneNumber                      NVARCHAR(256), 
     @isPhoneNumberConfirmed           BIT, 
     @isTwoFactorEnabled BIT, 
     @registrationDate                 DATETIME2
AS
     BEGIN
         SET IDENTITY_INSERT [dbo].[User] ON;
         INSERT INTO [dbo].[User]
         (UserID, 
          AccessFailedCount, 
          Email, 
          IsEmailConfirmed, 
          PasswordHash, 
          PhoneNumber, 
          IsPhoneNumberConfirmed, 
          IsTwoFactorEnabled, 
          RegistrationDate, 
          IsDeleted
         )
         VALUES
                (
                @userID, 0, @email, @isEmailConfirmed, @passwordHash, @phoneNumber, @isPhoneNumberConfirmed, @isTwoFactorEnabled, @registrationDate, 0
                );
         SET IDENTITY_INSERT [dbo].[User] OFF;
     END;
         RETURN @userID;
GO