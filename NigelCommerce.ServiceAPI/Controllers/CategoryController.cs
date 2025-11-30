using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using NigelCommerce.DAL;
using NigelCommerce.DAL.Models;
using System;
using System.Collections.Generic;

namespace NigelCommerce.ServiceAPI.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class CategoryController : Controller
    {
        NigelCommerceRepository repository;

        public CategoryController(NigelCommerceRepository repository)
        {
            this.repository = repository;
        }


        [HttpGet]
        [Authorize(Policy = "CustomerPolicy")]
        public IActionResult GetCategories()
        {
            try
            {
                var categories = repository.GetAllCategories();
                if (categories == null)
                    return NotFound();
                return Ok(categories);
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }


        [HttpGet]
        [Authorize(Policy = "CustomerPolicy")]
        public IActionResult GetCategoryById(byte categoryId)
        {
            try
            {
                var category = repository.GetCategoryById(categoryId);
                if (category == null)
                    return NotFound();
                return Ok(category);
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }


        [HttpPost]
        [Authorize(Policy = "CustomerPolicy")]
        public IActionResult AddCategoryUsingModels([FromBody] Category category)
        {
            if (category == null)
                return BadRequest("Category is required.");

            try
            {
                var status = repository.AddCategory(category);
                if (status)
                {
                    return CreatedAtAction(nameof(GetCategoryById), new { categoryId = category.CategoryId }, category);
                }
                else
                {
                    return BadRequest("Unsuccessful addition operation.");
                }
            }
            catch (Exception)
            {
                return StatusCode(500, "Internal server error");
            }
        }


        [HttpPut]
        [Authorize(Policy = "ManagerPolicy")]
        public IActionResult UpdateCategoryByByAPIModels([FromBody] NigelCommerce.ServiceAPI.Models.Categories category)
        {
            if (category == null)
                return BadRequest("Category is required.");

            try
            {
                Category catObj = new Category
                {
                    CategoryId = category.CategoryId,
                    CategoryName = category.CategoryName
                };

                var result = repository.UpdateCategory(catObj.CategoryId, catObj.CategoryName);
                if (result)
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
        public IActionResult DeleteCategoryById(byte categoryId)
        {
            try
            {
                var result = repository.DeleteCategory(categoryId);
                if (result)
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
