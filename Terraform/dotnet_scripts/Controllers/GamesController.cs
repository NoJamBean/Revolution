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
        private readonly GameReadDbContext _gameReadContext;
        private readonly UserDbContext _userContext;
        private readonly UserReadDbContext _userReadContext;

        public GamesController(GameDbContext gameContext, GameReadDbContext gameReadContext, UserDbContext userContext, UserReadDbContext userReadContext)
        {
            _gameContext = gameContext;
            _gameReadContext = gameReadContext;
            _userContext = _userContext;
            _userReadContext = userReadContext;
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

                var games = await _gameReadContext.GameInfos
                                            .Where(g => g.Id == userId)
                                            .OrderByDescending(g => g.GameDate)
                                            .ToListAsync();

                // 등록된 게임이 없어도 200 OK + 빈 배열 반환
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
                return BadRequest("유효하지 않은 게임 정보입니다.");
            }

            try
            {
                string userId = User.Claims.FirstOrDefault(c => c.Type == "cognito:username")?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { message = "사용자 ID를 확인할 수 없습니다." });
                }

                newGame.Id = userId;

                var user = await _userReadContext.Users.FirstOrDefaultAsync(u => u.Id == userId);
                if (user == null)
                {
                    return NotFound(new { message = "사용자를 찾을 수 없습니다." });
                }

                // 베팅 금액이 소지금액보다 큰지 확인
                if (newGame.Price > user.Balance)
                {
                    return Conflict(new
                    {
                        code = "INSUFFICIENT_FUNDS",
                        message = "소지금액보다 더 큰 금액을 베팅할 수 없습니다."
                    });
                }

                bool exists = await _gameReadContext.GameInfos
                    .AnyAsync(g => g.Id == newGame.Id && g.MatchId == newGame.MatchId);

                if (exists)
                {
                    return Conflict(new
                    {
                        code = "GAME_ALREADY_EXISTS",
                        message = "이미 존재하는 게임입니다."
                    });
                }

                // 베팅 금액만큼 소지금액 차감
                user.Balance -= newGame.Price;

                // 변경된 소지금액을 DB에 저장
                _userDbContext.Users.Update(user);
                await _userDbContext.SaveChangesAsync();

                _gameContext.GameInfos.Add(newGame);
                await _gameContext.SaveChangesAsync();

                return Ok(new
                {
                    message = "게임 정보가 성공적으로 저장되었습니다.",
                    data = newGame
                });
            }
            catch (DbUpdateException dbEx)
            {
                return StatusCode(500, new { message = "DB 저장 중 오류가 발생했습니다.", error = dbEx.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "게임 정보 저장 중 서버 오류가 발생했습니다.", error = ex.Message });
            }
        }

        [HttpPost("update")]
        public async Task<IActionResult> UpdateGame([FromBody] Dictionary<string, object> body)
        {
            try
            {
                if (body == null)
                    return BadRequest("요청 본문이 비어 있습니다.");

                if (!body.TryGetValue("matchid", out var matchIdObj) || string.IsNullOrEmpty(matchIdObj?.ToString()))
                    return BadRequest("matchid가 필요합니다.");
                string matchId = matchIdObj.ToString();

                if (!body.TryGetValue("status", out var statusObj) || string.IsNullOrEmpty(statusObj?.ToString()))
                    return BadRequest("status가 필요합니다.");
                string status = statusObj.ToString();

                string userId = User.Claims.FirstOrDefault(c => c.Type == "cognito:username")?.Value;
                if (string.IsNullOrEmpty(userId))
                    return Unauthorized(new { message = "사용자 ID를 확인할 수 없습니다." });

                var existingGame = await _gameReadContext.GameInfos
                    .FirstOrDefaultAsync(g => g.Id == userId && g.MatchId == matchId);

                if (existingGame == null)
                    return NotFound(new { message = "해당 경기 정보를 찾을 수 없습니다." });

                DateTime koreaTime = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, TimeZoneInfo.FindSystemTimeZoneById("Asia/Seoul"));
                existingGame.Status = status;
                existingGame.ModifiedDate = koreaTime;

                // FINISHED 상태시 결과처리
                if (status == "FINISHED")
                {
                    // ExecutionStrategy을 통한 재시도 패턴
                    var strategy = _gameContext.Database.CreateExecutionStrategy();
                    await strategy.ExecuteAsync(async () =>
                    {
                        using var transaction = await _gameContext.Database.BeginTransactionAsync();
                        try
                        {
                            bool resultExists = await _gameReadContext.GameResults
                                .AnyAsync(r => r.Id == userId && r.MatchId == matchId);

                            if (!resultExists)
                            {
                                string winner = body.ContainsKey("winner") ? body["winner"]?.ToString() : null;
                                string resultStatus = (winner != null && winner == existingGame.Wdl) ? "WIN" : "LOSE";
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
                                    Winner = winner,
                                    Result = resultStatus,
                                    ResultPrice = resultPrice,
                                    ModifiedDate = koreaTime
                                };

                                _gameContext.GameResults.Add(result);

                                await _gameContext.SaveChangesAsync();
                            }

                            await transaction.CommitAsync();
                        }
                        catch (Exception ex)
                        {
                            await transaction.RollbackAsync();
                            throw;
                        }
                    });

                    // Balance 지급은 트랜잭션 밖에서 따로 처리 (동시성 충돌 피하기)
                    var resultEntity = await _gameReadContext.GameResults
                        .FirstOrDefaultAsync(r => r.Id == userId && r.MatchId == matchId);
                    if (resultEntity?.ResultPrice > 0)
                    {
                        var user = await _userReadContext.Users.FirstOrDefaultAsync(u => u.Id == userId);
                        if (user != null)
                        {
                            user.Balance += resultEntity.ResultPrice;
                            user.ModifiedDate = koreaTime;
                            await _userContext.SaveChangesAsync();
                        }
                    }
                }
                else
                {
                    await _gameContext.SaveChangesAsync();
                }

                return Ok(new
                {
                    message = "경기 상태가 업데이트되었습니다.",
                    status
                });
            }
            catch (DbUpdateException dbEx)
            {
                return StatusCode(500, new
                {
                    message = "DB 저장 중 오류가 발생했습니다.",
                    error = dbEx.Message
                });
            }
            catch (Exception ex)
            {
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
                var gameInfo = await _gameReadContext.GameInfos
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
