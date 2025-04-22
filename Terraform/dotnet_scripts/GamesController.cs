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
        private readonly UserDbContext _userContext;

        public GamesController(GameDbContext gameContext, UserDbContext userContext)
        {
            _gameContext = gameContext;
            _userContext = userContext;
        }

        // 특정 사용자의 게임 정보 조회
        [HttpGet("mygames")]
        public async Task<ActionResult<IEnumerable<GameInfo>>> GetGamesByUser()
        {
            try
            {
                string userId = User.Claims.FirstOrDefault(c => c.Type == "cognito:username")?.Value;

                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { message = "토큰에서 사용자 ID를 찾을 수 없습니다." });
                }

                var games = await _gameContext.GameInfos
                                            .Where(g => g.Id == userId)
                                            .OrderByDescending(g => g.GameDate)
                                            .ToListAsync();

                if (games == null || games.Count == 0)
                {
                    return NotFound(new { message = $"{userId}의 게임 기록이 없습니다." });
                }

                return Ok(games);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "게임 정보를 조회하는 중 오류가 발생했습니다.", error = ex.Message });
            }
        }

        // 새로운 게임 정보 추가
        [HttpPost("bet")]
        public async Task<ActionResult<GameInfo>> PostGame([FromBody] GameInfo newGame)
        {
            if (newGame == null)
            {
                Console.WriteLine("[오류] 전달된 게임 정보가 null입니다.");
                return BadRequest("유효하지 않은 게임 정보입니다.");
            }

            try
            {
                string userId = User.Claims.FirstOrDefault(c => c.Type == "cognito:username")?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    Console.WriteLine("[오류] JWT 토큰에 cognito:username 클레임이 없습니다.");
                    return Unauthorized(new { message = "사용자 ID를 확인할 수 없습니다." });
                }

                newGame.Id = userId;

                bool exists = await _gameContext.GameInfos
                    .AnyAsync(g => g.Id == newGame.Id && g.MatchId == newGame.MatchId);

                if (exists)
                {
                    Console.WriteLine($"[중복] 동일한 경기 ({newGame.Id}, {newGame.MatchId}) 가 이미 존재합니다.");
                    return Conflict(new
                    {
                        code = "GAME_ALREADY_EXISTS",
                        message = "이미 존재하는 게임입니다."
                    });
                }

                _gameContext.GameInfos.Add(newGame);
                await _gameContext.SaveChangesAsync();

                Console.WriteLine("[성공] 게임 정보 저장 완료.");
                return Ok(new
                {
                    message = "게임 정보가 성공적으로 저장되었습니다.",
                    data = newGame
                });
            }
            catch (DbUpdateException dbEx)
            {
                Console.WriteLine("[DB 오류] 게임 저장 중 DB 예외 발생: " + dbEx.Message);
                Console.WriteLine(dbEx.InnerException?.Message ?? "");
                return StatusCode(500, new { message = "DB 저장 중 오류가 발생했습니다.", error = dbEx.Message });
            }
            catch (Exception ex)
            {
                Console.WriteLine("[오류] 게임 정보 저장 중 예외 발생: " + ex.Message);
                Console.WriteLine(ex.StackTrace);
                return StatusCode(500, new { message = "게임 정보 저장 중 서버 오류가 발생했습니다.", error = ex.Message });
            }
        }

        [HttpPost("update")]
        public async Task<IActionResult> UpdateGame([FromBody] GameInfo game)
        {
            if (game == null)
            {
                return BadRequest("유효하지 않은 게임 정보입니다.");
            }

            try
            {
                string userId = User.Claims.FirstOrDefault(c => c.Type == "cognito:username")?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { message = "사용자 ID를 확인할 수 없습니다." });
                }

                game.Id = userId;

                var existingGame = await _gameContext.GameInfos
                    .FirstOrDefaultAsync(g => g.Id == game.Id && g.MatchId == game.MatchId);

                if (existingGame == null)
                {
                    return NotFound(new { message = "해당 경기 정보를 찾을 수 없습니다." });
                }

                // 경기 상태와 수정일 갱신
                existingGame.Status = game.Status;
                existingGame.ModifiedDate = DateTime.UtcNow;

                // 상태가 FINISHED일 경우 결과 저장 및 balance 지급
                if (game.Status == "FINISHED")
                {
                    using var transaction = await _gameContext.Database.BeginTransactionAsync();

                    try
                    {
                        bool resultExists = await _gameContext.GameResults
                            .AnyAsync(r => r.Id == game.Id && r.MatchId == game.MatchId);

                        if (!resultExists)
                        {
                            string resultStatus = game.Wdl == "HOME" ? "WIN" : "LOSE";
                            long resultPrice = resultStatus == "WIN" ? (long)(existingGame.Price * (double)existingGame.Odds) : 0;

                            var result = new GameResult
                            {
                                Id = existingGame.Id,
                                MatchId = existingGame.MatchId,
                                Type = existingGame.Type,
                                GameDate = existingGame.GameDate,
                                Home = existingGame.Home,
                                Away = existingGame.Away,
                                Odds = existingGame.Odds,
                                Price = existingGame.Price,
                                Result = resultStatus,
                                ResultPrice = resultPrice,
                                ModifiedDate = DateTime.UtcNow
                            };

                            _gameContext.GameResults.Add(result);

                            if (resultPrice > 0)
                            {
                                var user = await _userContext.Users.FirstOrDefaultAsync(u => u.Id == game.Id);
                                if (user != null)
                                {
                                    user.Balance += resultPrice;
                                    user.ModifiedDate = DateTime.UtcNow;
                                    await _userContext.SaveChangesAsync(); // 💡 UserDbContext는 별도로 저장
                                }
                            }

                            Console.WriteLine($"[처리] 결과 저장 및 포인트 지급 완료: {game.MatchId}");
                        }
                        else
                        {
                            Console.WriteLine($"[무시] 결과 이미 존재함: {game.MatchId}");
                        }

                        await _gameContext.SaveChangesAsync(); // 게임 결과 저장
                        await transaction.CommitAsync();
                    }
                    catch (Exception ex)
                    {
                        await transaction.RollbackAsync();
                        Console.WriteLine("[트랜잭션 오류] " + ex.Message);
                        throw;
                    }
                }
                else
                {
                    await _gameContext.SaveChangesAsync(); // FINISHED가 아닐 때는 여기서만 저장
                }

                return Ok(new
                {
                    message = "경기 상태가 업데이트되었습니다.",
                    status = game.Status
                });
            }
            catch (DbUpdateException dbEx)
            {
                Console.WriteLine("[DB 오류] 게임 저장 중 DB 예외 발생: " + dbEx.Message);
                Console.WriteLine(dbEx.InnerException?.Message ?? "");
                return StatusCode(500, new { message = "DB 저장 중 오류가 발생했습니다.", error = dbEx.Message });
            }
            catch (Exception ex)
            {
                Console.WriteLine("[오류] 게임 정보 저장 중 예외 발생: " + ex.Message);
                Console.WriteLine(ex.StackTrace);
                return StatusCode(500, new { message = "게임 정보 저장 중 서버 오류가 발생했습니다.", error = ex.Message });
            }
        }

        [HttpPost("result")]
        public async Task<IActionResult> AddGameResult([FromBody] GameResult result)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                // 1. 해당 게임이 GameInfo에 존재하는지 확인
                var gameInfo = await _gameContext.GameInfos
                    .FirstOrDefaultAsync(g => g.Id == result.Id && g.MatchId == result.MatchId);

                if (gameInfo == null)
                {
                    return NotFound(new { message = "해당 경기를 gameinfoTBL에서 찾을 수 없습니다." });
                }

                // 2. GameResult에 추가
                _gameContext.GameResults.Add(result);

                // 3. GameInfo에서 해당 경기 삭제
                _gameContext.GameInfos.Remove(gameInfo);

                await _gameContext.SaveChangesAsync();

                return Ok(new { message = "경기 결과 저장 및 기존 게임 정보 삭제 완료", data = result });
            }
            catch (DbUpdateException dbEx)
            {
                return StatusCode(500, new { message = "DB 저장 중 오류 발생", error = dbEx.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "서버 내부 오류 발생", error = ex.Message });
            }
        }
    }
}
