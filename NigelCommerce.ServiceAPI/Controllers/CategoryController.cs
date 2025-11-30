using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using NigelCommerce.DAL;
using NigelCommerce.DAL.Models;

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
        public JsonResult GetCategories()
        {
            List<Category> category = new List<Category>();
            try
            {
                category = repository.GetAllCategories();
            }
            catch (Exception ex)
            {
                category = null;
            }
            return Json(category);
        }


        [HttpGet]
        [Authorize(Policy = "CustomerPolicy")]
        public JsonResult GetCategoryById(byte categoryId)
        {
            Category category;
            try
            {
                category = repository.GetCategoryById(categoryId);
            }
            catch (Exception)
            {
                category = null;
            }
            return Json(category);
        }


        [HttpPost]
        [Authorize(Policy = "CustomerPolicy")]
        public JsonResult AddCategoryUsingModels(Category category)
        {
            bool status = false;
            string message;

            try
            {
                status = repository.AddCategory(category);
                if (status)
                {
                    message = "Successful addition operation, CategoryId = " + category.CategoryId;
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
        public bool UpdateCategoryByByAPIModels(NigelCommerce.ServiceAPI.Models.Categories category)
        {
            bool result = false;
            try
            {
                Category catObj = new Category();
                catObj.CategoryId = category.CategoryId;
                catObj.CategoryName = category.CategoryName;

                result = repository.UpdateCategory(catObj.CategoryId, catObj.CategoryName);
            }
            catch (Exception)
            {

                result = false;
            }
            return result;
        }


        [HttpDelete]
        [Authorize(Policy = "OwnerPolicy")]
        public bool DeleteCategoryById(byte categoryId)
        {
            bool result = false;
            try
            {
                result = repository.DeleteCategory(categoryId);
            }
            catch (Exception)
            {
                result = false;
            }

            return result;
        }


    }
}
