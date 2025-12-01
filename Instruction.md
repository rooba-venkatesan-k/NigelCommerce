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
