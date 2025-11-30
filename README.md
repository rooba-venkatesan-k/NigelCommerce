# NigelCommerce

## Overview
NigelCommerce is an open-source contribution designed to help beginners/senior-developers learn key .NET Backend technologies. This repository serves as a practical example for implementing:

*   **SQL Server**: Sql Server Database to perform CRUD operations.
*   **EF Core**: Entity Framework Core for data access.
*   **ASP.NET Web API**: Building robust RESTful services.
*   **JWT Authentication**: Securing APIs using JSON Web Tokens.

It provides a comprehensive e-commerce solution with a Service API and a Data Access Layer (DAL).

## Installation & Setup

Follow these steps to set up the project locally.

### 1. Restore Dependencies
Navigate to the solution root and restore the NuGet packages for all projects:

```powershell
dotnet restore
```

### 2. Database Setup
Execute the SQL script to set up the database schema and initial data.
*   **Script File**: `Nigel Commerce DB Scripts.sql`
*   **Location**: Root directory of the repository.
*   **Action**: Open the script in SQL Server Management Studio (SSMS) or SQL Server Object Explorer in Visual Studio 2022 and execute it against your local SQL Server instance (`(localdb)\MSSQLLocalDB`).

### 3. User Secrets Configuration
The `NigelCommerce.ServiceAPI` project uses .NET User Secrets to store sensitive configuration data.

#### Initialize User Secrets
Navigate to the project directories and initialize user secrets for both the Service API and DAL projects.

**For NigelCommerce.ServiceAPI:** In terminal of Visual Studio or in Command Prompt

Navigate to this location
```powershell
cd NigelCommerce.ServiceAPI
```

Then, run this command
```powershell
dotnet user-secrets init
```

Running this command will generate a GUID. Add the GUID in `<UserSecretsId>your-guid-here</UserSecretsId>` and include this xml tag in the `<PropertyGroup>` of both `NigelCommerce.DAL.csproj` and `NigelCommerce.ServiceAPI.csproj`.

#### Set Secrets
Run the following commands one by one in same location to configure the necessary secrets:
```powershell
dotnet user-secrets set "ConnectionStrings:NigelCommerceDBConnectionString" "data source=(localdb)\\MSSQLLocalDB;initial catalog=NigelCommerceDB;Integrated security=True;"
dotnet user-secrets set "JWT:Key" "NigelCommerce_SuperSecretKey_For_JWT_Token_Generation_2025!"
dotnet user-secrets set "JWT:Issuer" "NigelCommerce.ServiceAPI"
dotnet user-secrets set "JWT:ExpiryInHours" "24"
dotnet user-secrets set "JWT:Audience" "NigelCommerceClients"
```

## Running the Application
Once the setup is complete, you can run the application using Visual Studio or the .NET CLI:

```powershell
dotnet run --project NigelCommerce.ServiceAPI
```
