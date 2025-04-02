using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using MyApi.Data;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Security.Claims;

namespace MyApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase
    {
        private readonly UserDbContext _userContext;
        private readonly IConfiguration _configuration;

        public UsersController(UserDbContext userContext, IConfiguration configuration)
        {
            _userContext = userContext;
            _configuration = configuration;
        }

        // 특정 사용자의 잔액 조회
        [HttpGet("{id}/balance")]
        public async Task<ActionResult<long>> GetBalance(string id)
        {
            // 명시적으로 타입 변경 (long? -> long)
            long? balance = await _userContext.Users
                                             .Where(u => u.Id == id)
                                             .Select(u => (long?)u.Balance)
                                             .SingleOrDefaultAsync();

            if (!balance.HasValue)
            {
                return NotFound(new { message = $"사용자 {id}의 잔액을 찾을 수 없습니다." });
            }

            return Ok(balance.Value);
        }

        [Authorize] // JWT 인증이 필요
        [HttpGet("profile")]
        public IActionResult GetUserProfile()
        {
            // 현재 사용자의 Cognito ID를 추출 (JWT 토큰에서 sub 값을 추출)
            string userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (userId == null)
            {
                return Unauthorized("사용자 인증 실패");
            }

            // DB에서 사용자 정보를 조회
            User user = _userContext.Users.SingleOrDefault(u => u.Uuid == userId);
        
            if (user == null)
            {
                return NotFound("사용자를 찾을 수 없습니다.");
            }

            return Ok(user);
        }        

        // 모든 사용자 조회
        [HttpGet]
        public async Task<ActionResult<IEnumerable<User>>> GetUsers()
        {
            // 명시적으로 타입 변경 (List<User> -> IEnumerable<User>)
            IEnumerable<User> users = await _userContext.Users.ToListAsync();
            return Ok(users);
        }

        [HttpGet("info")]
        public IActionResult GetUserInfo()
        {
            string userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            string appClientId = _configuration["Cognito:AppClientId"]; // 환경 변수에서 가져오기

            return Ok(new { userId, appClientId });
        }

        // 특정 사용자 조회
        [HttpGet("{id}")]
        public async Task<ActionResult<User>> GetUser(string id)
        {
            // 명시적으로 타입 변경 (User -> User)
            User user = await _userContext.Users
                                          .Where(u => u.Id == id)
                                          .FirstOrDefaultAsync();

            if (user == null)
            {
                return NotFound(new { message = $"사용자 {id}를 찾을 수 없습니다." });
            }

            return Ok(user);
        }

        // 새로운 사용자 추가
        [HttpPost]
        public async Task<ActionResult<User>> PostUser([FromBody] User newUser)
        {
            if (newUser == null)
            {
                return BadRequest("유효하지 않은 사용자 정보입니다.");
            }

            _userContext.Users.Add(newUser);
            await _userContext.SaveChangesAsync();

            return CreatedAtAction(nameof(GetUser), new { id = newUser.Id }, newUser);
        }

         // 기본적인 값을 반환하는 예시
        [HttpGet("test")]
        public ActionResult<IEnumerable<string>> Test()
        {
            // 명시적으로 타입 변경 (string[] -> IEnumerable<string>)
            IEnumerable<string> testValues = new string[] { "송현섭", "바보아니다", "일한다" };
            return Ok(testValues);
        }
    }
}
