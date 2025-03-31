using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyApi.Data;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MyApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class GamesController : ControllerBase
    {
        private readonly GameDbContext _gameContext;

        public GamesController(GameDbContext gameContext)
        {
            _gameContext = gameContext;
        }

        // 모든 게임 정보 조회
        [HttpGet]
        public async Task<ActionResult<IEnumerable<GameInfo>>> GetGames()
        {
            var games = await _gameContext.GameInfos.ToListAsync();
            return Ok(games);
        }

        // 특정 게임 정보 조회
        [HttpGet("{id}")]
        public async Task<ActionResult<GameInfo>> GetGame(string id)
        {
            var game = await _gameContext.GameInfos
                                          .Where(g => g.Id == id)
                                          .FirstOrDefaultAsync();

            if (game == null)
            {
                return NotFound(new { message = $"게임 {id}을(를) 찾을 수 없습니다." });
            }

            return Ok(game);
        }

        // 새로운 게임 정보 추가
        [HttpPost]
        public async Task<ActionResult<GameInfo>> PostGame([FromBody] GameInfo newGame)
        {
            if (newGame == null)
            {
                return BadRequest("유효하지 않은 게임 정보입니다.");
            }

            _gameContext.GameInfos.Add(newGame);
            await _gameContext.SaveChangesAsync();

            return CreatedAtAction(nameof(GetGame), new { id = newGame.Id }, newGame);
        }
    }
}
