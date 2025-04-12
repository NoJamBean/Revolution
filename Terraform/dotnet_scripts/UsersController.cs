using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyApi.Data;
using MyApi.Services;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace MyApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly UserDbContext _userContext;
        private readonly CognitoService _cognitoService;

        public UsersController(UserDbContext userContext, IConfiguration configuration, CognitoService cognitoService)
        {
            _userContext = userContext;
            _configuration = configuration;
            _cognitoService = cognitoService;
        }


        //GET
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

         // 기본적인 값을 반환하는 예시
        [HttpGet("test")]
        public ActionResult<IEnumerable<string>> Test()
        {
            // 명시적으로 타입 변경 (string[] -> IEnumerable<string>)
            IEnumerable<string> testValues = new string[] { "송현섭", "바보아니다", "일한다" };
            return Ok(testValues);
        }

        //POST
        // 새로운 사용자 추가
        [HttpPost("register")]
        public async Task<IActionResult> RegisterUser([FromBody] User user)
        {
            if (user == null || string.IsNullOrEmpty(user.Id) || string.IsNullOrEmpty(user.Password) || string.IsNullOrEmpty(user.Password))
            {
                return BadRequest("아이디와 비밀번호와 이메일은 필수입니다.");
            }

            try
            {
                var uuid = await _cognitoService.CreateUserAsync(user.Id, user.Password, user.Email);

                DateTime koreaTime = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, TimeZoneInfo.FindSystemTimeZoneById("Korea Standard Time"));

                // 2. DB에 저장
                var newUser = new User
                {
                    Id = user.Id,
                    Uuid = uuid,
                    Nickname = user.Nickname,
                    Password = user.Password,
                    Email = user.Email,
                    PhoneNumber = user.PhoneNumber,
                    Balance = user.Balance,
                    ModifiedDate = koreaTime
                };

                _userContext.Users.Add(newUser);
                await _userContext.SaveChangesAsync();

                return Ok(new { message = "사용자 등록 성공", user = newUser });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "사용자 등록 실패", error = ex.Message });
            }
        }
    }
}
