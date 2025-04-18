using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyApi.Data;
using MyApi.Services;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text.Json;
using System.Threading.Tasks;

namespace MyApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase
    {
        private readonly CognitoService _cognitoService;
        private readonly IConfiguration _configuration;
        private readonly IPasswordHasher _passwordHasher;
        private readonly UserDbContext _userContext;

        public UsersController(UserDbContext userContext, IConfiguration configuration, IPasswordHasher passwordHasher, CognitoService cognitoService)
        {
            _userContext = userContext;
            _configuration = configuration;
            _passwordHasher = passwordHasher;
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

        // [Authorize] // JWT 인증이 필요
        // [HttpGet("profile")]
        // public IActionResult GetUserProfile()
        // {
        //     // 현재 사용자의 Cognito ID를 추출 (JWT 토큰에서 sub 값을 추출)
        //     string userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        //     if (userId == null)
        //     {
        //         return Unauthorized("사용자 인증 실패");
        //     }

        //     // DB에서 사용자 정보를 조회
        //     User user = _userContext.Users.SingleOrDefault(u => u.Uuid == userId);
        
        //     if (user == null)
        //     {
        //         return NotFound("사용자를 찾을 수 없습니다.");
        //     }

        //     return Ok(user);
        // }        

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
            User user = await _userContext.Users
                                          .Where(u => u.Id == id)
                                          .FirstOrDefaultAsync();

            if (user == null)
            {
                return NotFound(new { message = $"사용자 {id}를 찾을 수 없습니다." });
            }

            return Ok(user);
        }

        [HttpGet("delete/{id}")]
        public async Task<IActionResult> DeleteUser(string id)
        {
            try
            {
                // 1. Cognito에서 삭제
                await _cognitoService.DeleteUserAsync(id);

                // 2. DB에서 사용자 삭제 (선택)
                var user = await _userContext.Users.SingleOrDefaultAsync(u => u.Id == id);
                if (user != null)
                {
                    _userContext.Users.Remove(user);
                    await _userContext.SaveChangesAsync();
                }

                return Ok(new { message = $"사용자 {id} 삭제 완료" });
            }
            catch (UserNotFoundException)
            {
                return NotFound(new { message = $"Cognito에서 사용자 {id}를 찾을 수 없습니다." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = $"사용자 삭제 실패", error = ex.Message });
            }
        }

         // 기본적인 값을 반환하는 예시
        [HttpGet("test")]
        public ActionResult<IEnumerable<string>> Test()
        {
            IEnumerable<string> testValues = new string[] { "송현섭", "바보아니다", "일한다" };
            return Ok(testValues);
        }

        //POST
        // 새로운 사용자 추가
        [HttpPost("register")]
        public async Task<IActionResult> RegisterUser([FromBody] User user)
        {
            if (user == null || string.IsNullOrEmpty(user.Id) || string.IsNullOrEmpty(user.Password) || string.IsNullOrEmpty(user.Email))
            {
                return BadRequest("아이디와 비밀번호와 이메일은 필수입니다.");
            }

            if (await _userContext.Users.AnyAsync(u => u.Id == user.Id))
            {
                return BadRequest(new { message = "이미 존재하는 아이디입니다." });
            }

            if (await _userContext.Users.AnyAsync(u => u.Email == user.Email))
            {
                return BadRequest(new { message = "이미 사용 중인 이메일입니다." });
            }

            try
            {
                Console.WriteLine("RegisterUser 호출됨");
                await _cognitoService.SignUpAsync(user.Id, user.Password, user.Email); // 이메일 인증 메일 발송

                return Ok(new { message = "회원가입 성공, 이메일 인증을 완료해주세요." });
            }
            catch (Exception ex)
            {
                Console.WriteLine("[에러] 사용자 등록 실패: " + ex.Message);
                return StatusCode(500, new { message = "회원가입 실패", error = ex.Message });
            }
        }

        //인증이메일 재전송
        [HttpPost("register/resend")]
        public async Task<IActionResult> ResendConfirmation([FromBody] ResendRequest request)
        {
            if (string.IsNullOrEmpty(request.Id))
            {
                return BadRequest(new { message = "ID는 필수입니다." });
            }

            try
            {
                await _cognitoService.ResendConfirmationEmailAsync(request.Id);
                return Ok(new { message = "인증 메일이 재발송되었습니다." });
            }
            catch (Exception ex)
            {
                Console.WriteLine("[에러] 인증 메일 재발송 실패: " + ex.Message);
                return StatusCode(500, new { message = "인증 메일 재발송 실패", error = ex.Message });
            }
        }
        
        [HttpPost("register/validate")]
        public async Task<IActionResult> ValidateConfirmationCode([FromBody] ConfirmRequest request)
        {
            if (string.IsNullOrEmpty(request.Id) || string.IsNullOrEmpty(request.Code))
            {
                return BadRequest(new { message = "아이디와 인증코드는 필수입니다." });
            }

            try
            {
                await _cognitoService.ConfirmCodeAsync(request.Id, request.Code);

                return Ok(new { message = "이메일 인증이 완료되었습니다." });
            }
            catch (Exception ex)
            {
                Console.WriteLine("[에러] 인증 확인 실패: " + ex.Message);
                return StatusCode(500, new { message = "이메일 인증 실패", error = ex.Message });
            }
        }

        [HttpPost("register/confirm")]
        public async Task<IActionResult> FinalizeRegistration([FromBody] User user)
        {
            if (string.IsNullOrEmpty(user.Id))
            {
                return BadRequest("아이디는 필수입니다.");
            }

            try
            {
                await _cognitoService.WaitForUserConfirmationAsync(user.Id);

                var hashedPassword = _passwordHasher.HashPassword(user.Password);
                DateTime koreaTime = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, TimeZoneInfo.FindSystemTimeZoneById("Asia/Seoul"));

                var newUser = new User
                {
                    Id = user.Id,
                    Nickname = user.Nickname,
                    Password = hashedPassword,
                    Email = user.Email,
                    PhoneNumber = user.PhoneNumber,
                    Balance = user.Balance,
                    ModifiedDate = koreaTime
                };

                _userContext.Users.Add(newUser);
                await _userContext.SaveChangesAsync();

                return Ok(new
                {
                    message = "사용자 등록 완료",
                    user = new
                    {
                        id = newUser.Id,
                        nickname = newUser.Nickname,
                        email = newUser.Email,
                        phoneNumber = newUser.PhoneNumber,
                        balance = newUser.Balance,
                        modifiedDate = newUser.ModifiedDate
                    }
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine("[에러] 사용자 등록 실패: " + ex.Message);
                return StatusCode(500, new { message = "사용자 등록 실패", error = ex.Message });
            }
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            if (string.IsNullOrEmpty(request.Id) || string.IsNullOrEmpty(request.Password))
            {
                return BadRequest(new { message = "아이디와 비밀번호는 필수입니다." });
            }

            try
            {
                // 1. DB에서 사용자 조회
                var user = await _userContext.Users.SingleOrDefaultAsync(u => u.Id == request.Id);

                if (user == null)
                {
                    return Unauthorized(new { message = "존재하지 않는 사용자입니다." });
                }

                // 2. 비밀번호 확인
                bool isPasswordValid = _passwordHasher.VerifyPassword(request.Password, user.Password);

                if (!isPasswordValid)
                {
                    return Unauthorized(new { message = "비밀번호가 올바르지 않습니다." });
                }

                // 3. Cognito 로그인 (토큰 발급)
                var (idToken, refreshToken) = await _cognitoService.LoginAsync(request.Id, request.Password);

                // 4. 성공 응답
                return Ok(new
                {
                    message = "로그인 성공",
                    tokens = new
                    {
                        idToken,
                        refreshToken
                    }
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine("[에러] 로그인 실패: " + ex.Message);
                return StatusCode(401, new { message = "로그인 실패", error = ex.Message });
            }
        }
    }
}
