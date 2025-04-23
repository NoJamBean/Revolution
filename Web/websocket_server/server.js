require('dotenv').config();
const { createServer } = require('http');
const { Server } = require('socket.io');
const { createAdapter } = require('@socket.io/redis-adapter');
const { createClient } = require('redis');
const fetch = require('node-fetch'); // fetch 사용을 위한 모듈 (node18 이하일 경우 설치 필요)

//healthCheck 처리 응답
const httpServer = createServer((req, res) => {
  if (req.url === '/health' && req.method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    return res.end('OK');
  }

  // socket.io 외의 다른 경로는 기본적으로 무시
  res.writeHead(404, { 'Content-Type': 'text/plain' });
  res.end('Not Found');
});

const io = new Server(httpServer, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
  path: '/socket',
});

const pubClient = createClient({ url: process.env.REDIS_URL });
const subClient = pubClient.duplicate();

Promise.all([pubClient.connect(), subClient.connect()]).then(() => {
  io.adapter(createAdapter(pubClient, subClient));

  io.on('connection', (socket) => {
    console.log(`🟢 연결됨: ${socket.id}`);

    // 방 입장
    socket.on('joinRoom', async ({ roomId, userName }) => {
      // ✅ 방 존재 여부 API 요청

      // 방 생성 or 해당 방에 user 등록
      socket.join(roomId);

      // ✅ 상태 저장
      socket.data.roomId = roomId;
      socket.data.userName = userName;

      try {
        const res = await fetch(`http://api.internal.local/rooms/${roomId}`);
        if (res.status === 404) {
          // 방 생성
          await fetch('http://api.internal.local/rooms', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ id: roomId, createdBy: userId }),
          });
        }
      } catch (err) {
        socket.emit('error', { message: '방 처리 실패' });
      }

      console.log(`➡️ ${userName} (${socket.id})가 ${roomId} 방에 입장`);

      socket.to(roomId).emit('userJoined', {
        userId: socket.id,
        userName,
        timestamp: new Date().toISOString(),
      });
    });

    // 메시지 전송
    socket.on('chatMessage', async ({ roomId, userName, content }) => {
      const payload = {
        senderId: socket.id,
        senderName: userName,
        content,
        timestamp: new Date().toISOString(),
      };

      // ✅ API 서버에 메시지 저장 요청
      try {
        await fetch('http://api.internal.local/messages', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ roomId, ...payload }),
        });
      } catch (err) {
        console.error('❌ 메시지 저장 실패:', err);
      }

      io.to(roomId).emit('chatMessage', payload);
    });

    // 명시적 방 나가기
    socket.on('leaveRoom', async ({ roomId, userName }) => {
      socket.leave(roomId);
      console.log(`⬅️ ${userName} (${socket.id})가 ${roomId} 방에서 퇴장`);

      // 채팅 방 나간 이벤트를 모든 소켓 연결 이용자에게 broadcast
      //   socket.to(roomId).emit('userLeft', {
      //     userId: socket.id,
      //     userName,
      //     timestamp: new Date().toISOString(),
      //   });

      // ✅ 방에 아무도 없으면 방 삭제
      if (!roomId) return;

      const sockets = await io.in(roomId).fetchSockets();
      if (sockets.length === 0) {
        await fetch(`http://api.internal.local/rooms/${roomId}`, {
          method: 'DELETE',
        });
        console.log(`🗑️ 방 ${roomId} 삭제 요청 보냄`);
      }

      socket.data.roomId = null;
    });

    // 연결 끊김 처리
    socket.on('disconnect', async () => {
      const roomId = socket.data.roomId;
      const userName = socket.data.userName || 'Unknown';

      console.log(`🔴 연결 종료됨: ${socket.id}`);

      // 채팅 방 나간 이벤트를 모든 소켓 연결 이용자에게 broadcast
      //   if (roomId) {
      //     socket.to(roomId).emit('userLeft', {
      //       userId: socket.id,
      //       userName,
      //       timestamp: new Date().toISOString(),
      //     });
      //   }

      // ✅ 방에 아무도 없으면 방 삭제
      if (!roomId) return;

      const sockets = await io.in(roomId).fetchSockets();
      if (sockets.length === 0) {
        await fetch(`http://api.internal.local/rooms/${roomId}`, {
          method: 'DELETE',
        });
        console.log(`🗑️ 방 ${roomId} 삭제 요청 보냄`);

        socket.data.roomId = null;
      }
    });
  });

  httpServer.listen(3000, () => {
    console.log('🚀 WebSocket 서버가 3000번 포트에서 실행됨');
  });
});
