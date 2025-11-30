using Microsoft.EntityFrameworkCore;
using NigelCommerce.DAL.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NigelCommerce.DAL
{
    public class NigelCommerceRepository
    {
        private NigelCommerceDbContext dbContext;

        public NigelCommerceDbContext Context { get { return dbContext; } }

        public NigelCommerceRepository(NigelCommerceDbContext context)
        {
            dbContext = context;
        }

        #region Products table related EFCore methods

        #region - To get all product details
        public List<Product> GetAllProducts()
        {
            List<Product> lstProducts = new List<Product>();
            try
            {
                lstProducts = dbContext.Products
                                     .OrderBy(p => p.ProductId)
                                     .ToList();
            }
            catch (Exception)
            {
                lstProducts = new List<Product>();
            }
            return lstProducts;
        }
        #endregion


        #region - To get a product detail based on ProductId
        public Product GetProductById(string productId)
        {
            Product product;
            try
            {
                product = dbContext.Products
                                 .FirstOrDefault(p => p.ProductId.Equals(productId));
            }
            catch (Exception)
            {
                product = null;
            }
            return product;
        }
        #endregion


        #region- To generate new product id
        public string GenerateNewProductId()
        {
            string productId;
            try
            {
                productId = dbContext.Products
                                   .Select(p => NigelCommerceDbContext.GenerateProductID())
                                   .FirstOrDefault();
            }
            catch (Exception)
            {
                productId = null;
            }
            return productId;
        }
        #endregion


        #region- To add a new product using Params
        public bool AddProduct(string productName, byte categoryId, decimal price, int quantityAvailable, out string productId)
        {
            bool status = false;
            productId = null;
            try
            {
                Product prodObj = new Product();
                prodObj.ProductId = GenerateNewProductId();
                productId = prodObj.ProductId;
                prodObj.ProductName = productName;
                prodObj.CategoryId = categoryId;
                prodObj.Price = price;
                prodObj.QuantityAvailable = quantityAvailable;

                dbContext.Products.Add(prodObj);
                dbContext.SaveChanges();
                status = true;
            }
            catch (Exception)
            {
                productId = null;
                status = false;
            }
            return status;
        }
        #endregion


        #region- To add a new product Using Entity Models 
        public bool AddProduct(Product product)
        {
            bool status = false;
            try
            {
                product.ProductId = GenerateNewProductId();
                dbContext.Products.Add(product);
                dbContext.SaveChanges();
                status = true;
            }
            catch (Exception)
            {
                status = false;
            }
            return status;
        }
        #endregion


        #region- To update the existing product details using Entity Models
        public bool UpdateProduct(Product products)
        {
            bool status = false;
            try
            {
                var product = dbContext.Products
                                     .FirstOrDefault(p => p.ProductId == products.ProductId);

                if (product != null)
                {
                    product.ProductId = products.ProductId;
                    product.ProductName = products.ProductName;
                    product.Price = products.Price;
                    product.QuantityAvailable = products.QuantityAvailable;
                    product.CategoryId = products.CategoryId;

                    dbContext.SaveChanges();
                    status = true;
                }
            }
            catch (Exception)
            {
                status = false;
            }
            return status;
        }
        #endregion


        #region - To delete a existing product
        public bool DeleteProduct(string prodId)
        {
            bool status = false;
            try
            {
                var product = dbContext.Products
                                     .FirstOrDefault(p => p.ProductId == prodId);

                dbContext.Products.Remove(product);
                dbContext.SaveChanges();
                status = true;
            }
            catch (Exception)
            {
                status = false;
            }
            return status;
        }
        #endregion

        #endregion


        #region Category table related EFCore methods

        #region - To get all category details
        public List<Category> GetAllCategories()
        {
            List<Category> lstCategories = null;
            try
            {
                lstCategories = dbContext.Categories
                                       .OrderBy(c => c.CategoryId)
                                       .ToList();
            }
            catch (Exception)
            {
                lstCategories = null;
            }
            return lstCategories;
        }
        #endregion


        #region - To get a category detail by using CategoryId
        public Category GetCategoryById(byte categoryId)
        {
            Category categories = new Category();
            try
            {
                categories = dbContext.Categories
                                    .FirstOrDefault(c => c.CategoryId.Equals(categoryId));
            }
            catch (Exception)
            {
                categories = null;
            }
            return categories;
        }
        #endregion


        #region - To generate new category id
        public byte GenerateNewCategoryId()
        {
            byte categoryId;
            try
            {
                var newCategoryId = dbContext.Categories
                                           .Select(c => NigelCommerceDbContext.GenerateCategoryID())
                                           .FirstOrDefault();

                categoryId = Convert.ToByte(newCategoryId);
            }
            catch (Exception)
            {
                categoryId = 0;
            }
            return categoryId;
        }
        #endregion


        #region - To add a new category using Entity Models
        public bool AddCategory(Category category)
        {
            bool status = false;
            try
            {
                dbContext.Categories.Add(category);
                dbContext.SaveChanges();
                status = true;
            }
            catch (Exception)
            {
                status = false;
            }
            return status;
        }
        #endregion


        #region - To update the existing category details with categoryId
        public bool UpdateCategory(byte categoryId, string categoryName)
        {
            bool status = false;
            try
            {
                var category = dbContext.Categories.Find(categoryId);

                if (category != null)
                {
                    category.CategoryName = categoryName;
                    dbContext.SaveChanges();
                    status = true;
                }
            }
            catch (Exception)
            {
                status = false;
            }
            return status;
        }
        #endregion


        #region - To delete an existing category
        public bool DeleteCategory(byte catID)
        {
            bool status = false;
            try
            {
                var category = dbContext.Categories
                                      .FirstOrDefault(c => c.CategoryId == catID);

                dbContext.Categories.Remove(category);
                dbContext.SaveChanges();
                status = true;
            }
            catch (Exception)
            {
                status = false;
            }
            return status;
        }
        #endregion

        #endregion


        #region Admin granting access EFCore methods
        public bool ChangeUserRole(string userEmail, string role)
        {
            byte roleId;
            switch (role)
            {
                case "Owner":
                    roleId = 1;
                    break;
                case "Manager":
                    roleId = 2;
                    break;
                case "Customer":
                    roleId = 3;
                    break;
                default:
                    roleId = 3;
                    break;
            }

            bool status = false;
            try
            {
                var userDetail = dbContext.Users
                                        .FirstOrDefault(u => u.EmailId == userEmail);
                if (userDetail != null)
                {
                    userDetail.RoleId = roleId;
                    dbContext.SaveChanges();
                    status = true;
                }

            }
            catch (Exception)
            {

                status = false;
            }
            return status;
        }

        #endregion


        #region - To validate user credentials and return user with role
        public User ValidateUser(string email, string password)
        {
            User user = null;
            try
            {
                user = dbContext.Users
                              .Include(u => u.Role)
                              .FirstOrDefault(u => u.EmailId == email && u.UserPassword == password);
            }
            catch (Exception)
            {
                user = null;
            }
            return user;
        }
        #endregion


    }
}
