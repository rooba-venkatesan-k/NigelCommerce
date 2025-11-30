using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using NigelCommerce.DAL;
using NigelCommerce.DAL.Models;

namespace NigelCommerce.ServiceAPI.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class ProductController : Controller
    {
        NigelCommerceRepository repository;

        public ProductController(NigelCommerceRepository repository)
        {
            this.repository = repository;
        }

        [HttpGet]
        [Authorize(Policy = "CustomerPolicy")]
        public JsonResult GetAllProducts()
        {
            List<Product> products = new List<Product>();
            try
            {
                products = repository.GetAllProducts();
            }
            catch (Exception ex)
            {
                products = null;
            }
            return Json(products);
        }


        [HttpGet]
        [Authorize(Policy = "CustomerPolicy")]
        public JsonResult GetProductById(string productId)
        {
            Product product;
            try
            {
                product = repository.GetProductById(productId);
            }
            catch (Exception)
            {
                product = null;
            }
            return Json(product);
        }


        [HttpPost]
        [Authorize(Policy = "CustomerPolicy")]
        public JsonResult AddProductUsingParams(string productName, byte categoryId, decimal price, int quantityAvailable)
        {
            bool status = false;
            string productId;
            string message;
            try
            {
                status = repository.AddProduct(productName, categoryId, price, quantityAvailable, out productId);
                if (status)
                {
                    message = "Successful addition operation, ProductId = " + productId;
                }
                else
                {
                    message = "Unsuccessful addition operation!";
                }
            }
            catch (Exception)
            {
                message = "Some error occured, please try again!";
            }
            return Json(message);
        }


        [HttpPost]
        [Authorize(Policy = "CustomerPolicy")]
        public JsonResult AddProductByModels(Product product)
        {
            bool status = false;
            string message;

            try
            {
                status = repository.AddProduct(product);
                if (status)
                {
                    message = "Successful addition operation, ProductId = " + product.ProductId;
                }
                else
                {
                    message = "Unsuccessful addition operation!";
                }
            }
            catch (Exception)
            {
                message = "Some error occured, please try again!";
            }
            return Json(message);
        }


        [HttpPut]
        [Authorize(Policy = "ManagerPolicy")]
        public bool UpdateProductByEFModels(Product product)
        {
            bool status = false;

            try
            {
                status = repository.UpdateProduct(product);
            }
            catch (Exception)
            {
                status = false;
            }
            return status;
        }


        [HttpPut]
        [Authorize(Policy = "ManagerPolicy")]
        public bool UpdateProductByAPIModels(NigelCommerce.ServiceAPI.Models.Product product)
        {
            bool status = false;

            try
            {
                if (ModelState.IsValid)
                {
                    Product prodObj = new Product();
                    prodObj.ProductId = product.ProductId;
                    prodObj.ProductName = product.ProductName;
                    prodObj.CategoryId = product.CategoryId;
                    prodObj.Price = product.Price;
                    prodObj.QuantityAvailable = product.QuantityAvailable;
                    status = repository.UpdateProduct(prodObj);
                }
                else
                {
                    status = false;
                }
            }
            catch (Exception)
            {
                status = false;
            }
            return status;
        }


        [HttpDelete]
        [Authorize(Policy = "OwnerPolicy")]
        public JsonResult DeleteProduct(string productId)
        {
            bool status = false;
            try
            {
                status = repository.DeleteProduct(productId);
            }
            catch (Exception)
            {
                status = false;
            }
            return Json(status);
        }
    }
}
