# Start Playing with NigelCommerce Repository

This guide explains how to interact with the NigelCommerce API, focusing on user registration, authentication, and role-based permissions.

## Overview of Roles

*   **New User**: Can only **Register**
*   **Customer**: Can do **Get** and **Add** operations
*   **Manager**: Has all Customer permissions + can do **Update** operations.
*   **Owner**: Has all Manager permissions + can do **Delete** operations, **View All Users**, and **Change User Roles**.

## Prerequisites

*   **Postman** (or any API testing tool) to send HTTP requests.
*   The application should be running locally (e.g., `http://localhost:5141` or similar). You can find localhost url in NigelCommerce.ServiceAPI/Properties/launchSettings.json project.

---

## 1. Registration (New User)

A new user must first register. By default, a new user is assigned the **Customer** role.

*   **Endpoint**: `POST http://localhost:5141/api/User/NewUserRegistry`
*   **Body** (JSON):
    ```json
    {
      "EmailId": "newuser@example.com",
      "UserPassword": "Password123!",
      "Gender": "M",
      "DOB": "1990-01-01",
      "Address": "123 Main St"
    }
    ```
*   **Response**: Returns a success message and the registered email.

## 2. Authentication (Login)

To perform any operation (Get, Add, Update, Delete), you must login to generate a JWT token.

*   **Endpoint**: `POST http://localhost:5141/api/Auth/Login`
*   **Body** (JSON):
    ```json
    {
      "Email": "newuser@example.com",
      "Password": "Password123!"
    }
    ```
*   **Response**:
    ```json
    {
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "email": "newuser@example.com",
      "role": "Customer",
      "message": "Login successful"
    }
    ```
*   **Action**: Copy the `token` value. In Postman, go to the **Authorization** tab, select **OAuth 2.0**, and paste the token there for all subsequent requests.

---

## 3. Operations by Role

### Customer (Default Role)
*Permissions: Get Products, Add Products*

#### Get All Products
*   **Endpoint**: `GET http://localhost:5141/api/Product/GetAllProducts`
*   **Auth**: Bearer Token required.

#### Add Product
*   **Endpoint**: `POST /api/Product/AddProductByModels`
*   **Auth**: Token required.
*   **Body** (JSON):
    ```json
    {
      "ProductName": "New Item",
      "CategoryId": 1,
      "Price": 99.99,
      "QuantityAvailable": 50
    }
    ```

### Manager
*Permissions: All Customer actions + Update Products*
*Note: You must log in as a user with the 'Manager' role to perform these actions.*

#### Update Product
*   **Endpoint**: `PUT http://localhost:5141/api/Product/UpdateProductByEFModels`
*   **Auth**: Token (Manager/Owner) required.
*   **Body** (JSON):
    ```json
    {
      "ProductId": "PRODUCT_ID_HERE",
      "ProductName": "Updated Item Name",
      "CategoryId": 1,
      "Price": 120.00,
      "QuantityAvailable": 45
    }
    ```

### Owner
*Permissions: All Manager actions + Delete Products, View Users, Change Roles*
*Note: You must log in as a user with the 'Owner' role to perform these actions.*

#### Delete Product
*   **Endpoint**: `DELETE http://localhost:5141/api/Product/DeleteProduct?productId=PRODUCT_ID_HERE`
*   **Auth**: Token (Owner) required.

#### View All Users
*   **Endpoint**: `GET http://localhost:5141/api/User/DisplayAllUsers`
*   **Auth**: Token (Owner) required.

#### Change User Role
Only an Owner can promote or demote users.
*   **Endpoint**: `PUT http://localhost:5141/api/Admin/UpdateRoleForUsers`
*   **Auth**: Bearer Token (Owner) required.
*   **Body** (JSON):
    ```json
    {
      "EmailId": "user@example.com",
      "Role": "Manager" 
    }
    ```
    *(Valid Roles: "Customer", "Manager", "Owner")*

---

## 4. Sample User Details in SQL Script

After executing the SQL scripts during database setup, the following sample users are available for testing different roles. You can use these credentials to log in and test various API operations without creating new users.

### Users with Owner Permission

These users have full access to all operations including delete, view all users, and change user roles.

| Email | Password | Gender | Date of Birth |
|-------|----------|--------|---------------|
| Anzio_Don@org.com | don@123 | M | 1991-02-24 |
| MeetRoda@fifet.com | ChristaRocks | M | 1990-04-20 |

**Example Login:**
```json
{
  "Email": "Anzio_Don@org.com",
  "Password": "don@123"
}
```

### Users with Manager Permission

These users can perform GET, ADD, and UPDATE operations on products.

| Email | Password | Gender | Date of Birth |
|-------|----------|--------|---------------|
| AmyFlower@outbook.com | CH2PS+Ab@# | M | 1981-09-11 |
| Helenmeler@outbook.com | CO2SH+Ab@# | F | 1966-11-09 |
| Leonardos@outbook.com | CO2MI+Ab@# | M | 1990-07-20 |
| Mathew_Edmar@org.com | Divine@456 | M | 1989-09-12 |
| Rine_Jamwal@org.com | spacejet | F | 1991-07-20 |
| Ronden@outbook.com | BSB2V+Ab@# | F | 1979-08-26 |
| Sanio_Neeba@org.com | AllIsGood | F | 1990-06-13 |
| Sheldoy@outbook.com | CAC2U+Ab@# | F | 1981-09-14 |

**Example Login:**
```json
{
  "Email": "Mathew_Edmar@org.com",
  "Password": "Divine@456"
}
```

### Users with Customer Permission

These users can perform GET and ADD operations on products.

| Email | Password | Gender | Date of Birth |
|-------|----------|--------|---------------|
| Janine@outbook.com | RATTC+Ab@# | F | 1964-12-12 |
| Josephs@outbook.com | CONSH+Ab@# | F | 1963-11-09 |
| Karin@outbook.com | QUEEN+Ab@# | F | 1989-12-18 |
| Karla@outbook.com | QUEDE+Ab@# | M | 1968-04-28 |
| Karttunen@outbook.com | DRACD+Ab@# | M | 1963-06-27 |
| Koskitalo@outbook.com | DUMON+Ab@# | F | 1966-01-28 |
| Labrune@outbook.com | EASTC+Ab@# | F | 1980-02-09 |
| Larsson@outbook.com | ERNSH+Ab@# | M | 1988-04-08 |

**Example Login:**
```json
{
  "Email": "Karin@outbook.com",
  "Password": "QUEEN+Ab@#"
}
```

---

## Quick Start Guide

1. **Execute SQL Scripts**: Run `Nigel Commerce DB Scripts.sql` to set up the database with sample data
2. **Choose a User**: Select a user from the tables above based on the permissions you want to test
3. **Login**: Use the `/api/Auth/Login` endpoint with the chosen credentials
4. **Copy Token**: Save the JWT token from the login response
5. **Test Operations**: Use the token in Postman's Authorization tab (Bearer Token) to test different API endpoints based on the user's role
