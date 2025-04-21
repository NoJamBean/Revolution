using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyApi.Data;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace MyApi.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class GamesController : ControllerBase
    {
        private readonly GameDbContext _gameContext;

        public GamesController(GameDbContext gameContext)
        {
            _gameContext = gameContext;
        }

        // 특정 사용자의 게임 정보 조회
        [HttpGet("mygames")]
        public async Task<ActionResult<IEnumerable<GameInfo>>> GetGamesByUser()
        {
            try
            {
                string id = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

                if (string.IsNullOrEmpty(id))
                {
                    return Unauthorized(new { message = "토큰에서 사용자 ID를 찾을 수 없습니다." });
                }

                var games = await _gameContext.GameInfos
                                            .Where(g => g.Id == id)
                                            .OrderByDescending(g => g.GameDate)
                                            .ToListAsync();

                if (games == null || games.Count == 0)
                {
                    return NotFound(new { message = $"{id}의 게임 기록이 없습니다." });
                }

                return Ok(games);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "게임 정보를 조회하는 중 오류가 발생했습니다.", error = ex.Message });
            }
        }

        // 새로운 게임 정보 추가
        [HttpPost("update")]
        public async Task<ActionResult<GameInfo>> PostGame([FromBody] GameInfo newGame)
        {
            if (newGame == null)
            {
                return BadRequest("유효하지 않은 게임 정보입니다.");
            }

            try
            {
                _gameContext.GameInfos.Add(newGame);
                await _gameContext.SaveChangesAsync();

                return Ok(new { message = "게임 정보가 성공적으로 저장되었습니다.", data = newGame });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "게임 정보 저장 중 서버 오류가 발생했습니다.", error = ex.Message });
            }
        }
    }
}
