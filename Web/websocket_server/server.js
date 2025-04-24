require('dotenv').config();
const { createServer } = require('http');
const { Server } = require('socket.io');
const { createAdapter } = require('@socket.io/redis-adapter');
const { createClient } = require('redis');
const axios = require('axios');

// const fetch = require('node-fetch'); // fetch 사용을 위한 모듈 (node18 이하일 경우 설치 필요)

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

  // 채팅방 접속자 수 체크용
  const roomUserMap = new Map(); // ✅ 방 별로 소켓ID Set 저장

  io.on('connection', (socket) => {
    console.log(`🟢 연결됨: ${socket.id}`);

    // 방 입장
    socket.on('joinRoom', async ({ roomId, userName, token }) => {
      // ✅ 방 존재 여부 API 요청

      // 방 생성 or 해당 방에 user 등록
      socket.join(roomId);

      // ✅ 상태 저장
      socket.data.roomId = roomId;
      socket.data.userName = userName;

      // 방에 처음 들어온 사용자일 경우 Set 생성
      if (!roomUserMap.has(roomId)) {
        roomUserMap.set(roomId, new Set());
      }

      // 사용자 저장
      roomUserMap.get(roomId).add(socket.id);

      try {
        const result = await axios.get(
          `${process.env.BACKEND_API_ENDPOINT}/api/chat/room/join/${roomId}`,
          {
            headers: {
              'Content-type': 'application/json',
              Authorization: `Bearer ${token}`,
            },
          }
        );

        // console.log(result, '방 join 체크');

        socket.emit('success', { message: '방 생성 되었음!!!' });
      } catch (err) {
        console.error('❌ 방 join 요청 실패:', err);
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
    socket.on('chatMessage', async ({ roomId, userId, content }) => {
      const payload = {
        id: userId, // <-- 유저 닉네임
        // senderName: userName, // <-- 닉네임
        content,
        time: new Date().toISOString(),
      };

      console.log(roomId, userId, '12321312312');

      io.to(roomId).emit('chatMessage', payload);

      // ✅ API 서버에 메시지 저장 요청
      try {
        const result = await axios.post(
          `${process.env.BACKEND_API_ENDPOINT}/api/chat/message/put`,
          {
            roomid: roomId,
            id: userId,
            content: content,
          },
          {
            headers: {
              'Content-type': 'application/json',
            },
          }
        );
        console.log('message api 요청 성공');
      } catch (err) {
        console.error('❌ 메시지 저장 실패:', err);
      }
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

      const userSet = roomUserMap.get(roomId);
      userSet?.delete(socket.id);

      // 아무도 없으면 방 삭제
      if (userSet && userSet.size === 0) {
        roomUserMap.delete(roomId);
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
      const userSet = roomUserMap.get(roomId);
      userSet?.delete(socket.id);

      if (userSet && userSet.size === 0) {
        roomUserMap.delete(roomId);

        try {
          const result = await axios.get(
            `${process.env.BACKEND_API_ENDPOINT}/api/chat/room/delete/${roomId}`,
            {
              headers: {
                'Content-type': 'application/json',
              },
            }
          );

          socket.emit('success', { message: '방 삭제 되었음!!!' });
        } catch (err) {
          socket.emit('error', { message: '방 삭제처리 실패' });
        }
        socket.data.roomId = null;
      }
    });
  });

  httpServer.listen(3001, '0.0.0.0',() => {
    console.log('🚀 WebSocket 서버가 3001번 포트에서 실행됨');
  });
});
