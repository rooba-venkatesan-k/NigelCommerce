using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using NigelCommerce.DAL;
using NigelCommerce.DAL.Models;
using System;
using System.Collections.Generic;

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
        public IActionResult GetAllProducts()
        {
            try
            {
                var products = repository.GetAllProducts();
                if (products == null)
                    return NotFound();
                return Ok(products);
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }


        [HttpGet]
        [Authorize(Policy = "CustomerPolicy")]
        public IActionResult GetProductById(string productId)
        {
            try
            {
                var product = repository.GetProductById(productId);
                if (product == null)
                    return NotFound();
                return Ok(product);
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }


        [HttpPost]
        [Authorize(Policy = "CustomerPolicy")]
        public IActionResult AddProductUsingParams(string productName, byte categoryId, decimal price, int quantityAvailable)
        {
            try
            {
                bool status = repository.AddProduct(productName, categoryId, price, quantityAvailable, out string productId);
                if (status)
                {
                    return CreatedAtAction(nameof(GetProductById), new { productId = productId }, new { ProductId = productId });
                }
                return BadRequest("Unsuccessful addition operation.");
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }


        [HttpPost]
        [Authorize(Policy = "CustomerPolicy")]
        public IActionResult AddProductByModels([FromBody] Product product)
        {
            if (product == null)
                return BadRequest("Product is required.");

            try
            {
                var status = repository.AddProduct(product);
                if (status)
                {
                    return CreatedAtAction(nameof(GetProductById), new { productId = product.ProductId }, product);
                }
                return BadRequest("Unsuccessful addition operation.");
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }


        [HttpPut]
        [Authorize(Policy = "ManagerPolicy")]
        public IActionResult UpdateProductByEFModels([FromBody] Product product)
        {
            if (product == null)
                return BadRequest("Product is required.");

            try
            {
                var status = repository.UpdateProduct(product);
                if (status)
                    return NoContent();
                return NotFound();
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }


        [HttpPut]
        [Authorize(Policy = "ManagerPolicy")]
        public IActionResult UpdateProductByAPIModels([FromBody] NigelCommerce.ServiceAPI.Models.Product product)
        {
            if (product == null)
                return BadRequest("Product is required.");

            try
            {
                if (!ModelState.IsValid)
                    return BadRequest(ModelState);

                Product prodObj = new Product
                {
                    ProductId = product.ProductId,
                    ProductName = product.ProductName,
                    CategoryId = product.CategoryId,
                    Price = product.Price,
                    QuantityAvailable = product.QuantityAvailable
                };

                var status = repository.UpdateProduct(prodObj);
                if (status)
                    return NoContent();
                return NotFound();
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }


        [HttpDelete]
        [Authorize(Policy = "OwnerPolicy")]
        public IActionResult DeleteProduct(string productId)
        {
            try
            {
                var status = repository.DeleteProduct(productId);
                if (status)
                    return NoContent();
                return NotFound();
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }
    }
}
