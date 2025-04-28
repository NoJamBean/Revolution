using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyApi.Data;
using System.Security.Claims;

namespace MyApi.Controllers
{
    [ApiController]
    [Route("api/chat")]
    public class ChatController : ControllerBase
    {
        private readonly ChatDbContext _chatContext;
        private readonly ChatReadDbContext _chatReadContext;

        public ChatController(ChatDbContext chatContext, ChatReadDbContext chatReadContext)
        {
            _chatContext = chatContext;
            _chatReadContext = chatReadContext;
        }

        [Authorize]
        [HttpGet("room/join/{roomid}")]
        public async Task<IActionResult> JoinRoom(string roomid)
        {
            try
            {
                if (string.IsNullOrEmpty(roomid))
                    return BadRequest("roomid가 필요합니다.");

                var room = await _chatReadContext.Rooms.FirstOrDefaultAsync(r => r.RoomId == roomid);
                if (room == null)
                {
                    room = new Room {
                        RoomId = roomid,
                        ModifiedDate = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, TimeZoneInfo.FindSystemTimeZoneById("Asia/Seoul"))
                    };
                    _chatContext.Rooms.Add(room);
                    await _chatContext.SaveChangesAsync();
                    return Ok(new { created = true, room });
                }

                return Ok(new { created = false, room });
            }
            catch (DbUpdateException dbEx)
            {
                return StatusCode(500, new { message = "DB 오류 발생", error = dbEx.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "서버 오류 발생", error = ex.Message });
            }
        }

        [HttpGet("room/delete/{roomid}")]
        public async Task<IActionResult> DeleteRoom(string roomid)
        {
            if (string.IsNullOrEmpty(roomid))
                return BadRequest("roomid가 필요합니다.");

            var room = await _chatReadContext.Rooms.FirstOrDefaultAsync(r => r.RoomId == roomid);
            if (room == null)
                return Ok(new { deleted = false, message = "삭제할 방이 없습니다." });

            _chatContext.Rooms.Remove(room);
            await _chatContext.SaveChangesAsync();
            return Ok(new { deleted = true, message = $"{roomid} 방이 삭제되었습니다." });
        }


        // 4. 메시지 보내기
        [HttpPost("message/put")]
        public async Task<IActionResult> LogMessage([FromBody] Message req)
        {
            // 필수 값 검증
            if (string.IsNullOrEmpty(req.RoomId) ||
                string.IsNullOrEmpty(req.Id) ||
                string.IsNullOrEmpty(req.Content))
            {
                return BadRequest("roomid, id(보내는사람), content가 필요합니다.");
            }

            // 메시지 전송 시간 기록 (서버 기준)
            req.Time = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, TimeZoneInfo.FindSystemTimeZoneById("Asia/Seoul"));;

            // 메시지 DB 저장
            _chatContext.Messages.Add(req);
            await _chatContext.SaveChangesAsync();

            return Ok(new { logged = true, message = req });
        }

        [HttpGet("message/list/{roomid}")]
        public async Task<IActionResult> GetMessageList(string roomid)
        {
            try
            {
                if (string.IsNullOrEmpty(roomid))
                    return BadRequest("roomid가 필요합니다.");

                // 해당 방의 메시지 로그를 시간 순으로 모두 조회
                var messages = await _chatReadContext.Messages
                    .Where(m => m.RoomId == roomid)
                    .OrderBy(m => m.Time)
                    .ToListAsync();

                // messages가 null인 경우 빈 배열로 변환
                if (messages == null)
                    messages = new List<Message>();

                return Ok(messages); // 항상 200 OK와 배열 반환
            }
            catch (DbUpdateException dbEx)
            {
                return StatusCode(500, new { message = "DB 오류 발생", error = dbEx.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "서버 오류 발생", error = ex.Message });
            }
        }
    }
}