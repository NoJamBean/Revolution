require('dotenv').config();
const { createServer } = require('http');
const { Server } = require('socket.io');
const { createAdapter } = require('@socket.io/redis-adapter');
const { createClient } = require('redis');

const httpServer = createServer();
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
    console.log(`[+] 유저 연결됨: ${socket.id}`);

    socket.on('joinRoom', (roomId) => {
      socket.join(roomId);
      console.log(`[+] ${socket.id}가 방 ${roomId}에 입장`);
    });

    socket.on('chatMessage', ({ roomId, content }) => {
      const payload = {
        senderId: socket.id,
        content,
        timestamp: new Date().toISOString(),
      };

      // 같은 room에 있는 클라이언트에게 메시지 전송
      io.to(roomId).emit('chatMessage', payload);
    });

    socket.on('disconnect', () => {
      console.log(`[-] 연결 해제됨: ${socket.id}`);
    });
  });

  httpServer.listen(3000, () => {
    console.log(`🚀 WebSocket 서버 실행됨 (포트: 3000)`);
  });
});
