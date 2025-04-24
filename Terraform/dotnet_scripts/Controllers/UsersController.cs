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
        [Authorize]
        [HttpGet("me")]
        public async Task<IActionResult> GetTokenInfo()
        {
            try
            {
                string userId = User.Claims.FirstOrDefault(c => c.Type == "cognito:username")?.Value;

                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { message = "토큰에서 사용자 ID를 찾을 수 없습니다." });
                }

                var user = await _userContext.Users.FirstOrDefaultAsync(u => u.Id == userId);

                if (user == null)
                {
                    return NotFound(new { message = $"사용자 {userId}를 찾을 수 없습니다." });
                }

                return Ok(new
                {
                    user.Id,
                    user.Email,
                    user.Nickname,
                    user.PhoneNumber,
                    user.Balance
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    message = "사용자 정보를 조회하는 중 오류가 발생했습니다.",
                    error = ex.Message
                });
            }
        }

        [Authorize]
        [HttpGet("charge")]
        public async Task<IActionResult> ChargeBalanceIfNeeded()
        {
            try
            {
                // 1. 토큰에서 사용자 ID 추출
                string userId = User.Claims.FirstOrDefault(c => c.Type == "cognito:username")?.Value;

                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { message = "토큰에서 사용자 ID를 찾을 수 없습니다." });
                }

                // 2. 사용자 조회
                var user = await _userContext.Users.FirstOrDefaultAsync(u => u.Id == userId);

                if (user == null)
                {
                    return NotFound(new { message = $"사용자 {userId}를 찾을 수 없습니다." });
                }

                // 3. 현재 잔액 확인 후 충전
                if (user.Balance < 50000)
                {
                    user.Balance += 50000;
                    user.ModifiedDate = DateTime.UtcNow; // 수정일 갱신
                    await _userContext.SaveChangesAsync();

                    return Ok(new { message = "50000원이 충전되었습니다.", balance = user.Balance });
                }

                return Ok(new { message = "충전이 필요하지 않습니다.", balance = user.Balance });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "잔액 충전 중 오류 발생", error = ex.Message });
            }
        }

        [HttpGet("delete/{id}")]
        public async Task<IActionResult> DeleteUser(string id)
        {
            try
            {
                await _cognitoService.DeleteUserAsync(id);

                var user = await _userContext.Users.SingleOrDefaultAsync(u => u.Id == id);
                if (user != null)
                {
                    _userContext.Users.Remove(user);
                    await _userContext.SaveChangesAsync();
                }

                return Ok(new { message = $"사용자 {id} 삭제 완료" });
            }
            catch (Exception ex)
            {
                // Cognito에서 사용자를 못 찾은 경우에도 여기서 처리
                if (ex.Message.Contains("UserNotFoundException"))
                {
                    return NotFound(new { message = $"Cognito에서 사용자 {id}를 찾을 수 없습니다." });
                }

                return StatusCode(500, new { message = "사용자 삭제 실패", error = ex.Message });
            }
        }

        [HttpGet("register/idcheck/{id}")]
        public async Task<IActionResult> IdCheck(string id)
        {
            // id가 없는 경우
            if (string.IsNullOrEmpty(id))
            {
                return BadRequest(new { message = "id 파라미터가 필요합니다." });
            }

            // DB에 해당 id가 이미 존재하면
            bool exists = await _userContext.Users.AnyAsync(u => u.Id == id);
            if (exists)
            {
                return Conflict(new { message = "이미 존재하는 아이디입니다." });
            }

            // 사용 가능한 id
            return Ok(new { message = "사용 가능한 아이디입니다." });
        }

        [HttpGet("register/nicknamecheck/{nickname}")]
        public async Task<IActionResult> NicknameCheck(string nickname)
        {
            // 닉네임이 없는 경우
            if (string.IsNullOrEmpty(nickname))
            {
                return BadRequest(new { message = "nickname 파라미터가 필요합니다." });
            }

            // DB에 해당 닉네임이 이미 존재하면
            bool exists = await _userContext.Users.AnyAsync(u => u.Nickname == nickname);
            if (exists)
            {
                return Conflict(new { message = "이미 존재하는 닉네임입니다." });
            }

            // 사용 가능한 닉네임
            return Ok(new { message = "사용 가능한 닉네임입니다." });
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
                await _cognitoService.SignUpAsync(user.Id, user.Password, user.Email); // 이메일 인증 메일 발송

                return Ok(new { message = "회원가입 성공, 이메일 인증을 완료해주세요." });
            }
            catch (Exception ex)
            {
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
                // 1. DB에서 사용자 조회c
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
                return StatusCode(401, new { message = "로그인 실패", error = ex.Message });
            }
        }
    }
}
