import { useEffect, useRef, useState } from 'react';
import * as S from './chatstyle';
import { faPaperPlane } from '@fortawesome/free-regular-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { useRouter } from 'next/router';
import { io, Socket } from 'socket.io-client';
import { useAuthStore } from '@/src/commons/stores/authstore';
import { useDecodeToken } from '@/src/commons/utils/decodeusertoken';
import { userDataProps } from '../../units/mypage/mypages';
import { transISOToHumanTime } from '@/src/commons/utils/getdatetime';
import axios from 'axios';

let socket: Socket;

type ChatMessage = {
  senderId: string;
  senderName: string;
  content: string;
  timestamp: string;
};

export default function Chat() {
  const [isChatConnected, setIsChatConnected] = useState(false);
  const [message, setMessage] = useState('');
  const [messages, setMessages] = useState<ChatMessage[]>([]);

  const [userInfoData, setUserInfoData] = useState<userDataProps | undefined>();

  const { getDecodedToken } = useDecodeToken();
  const setToken = useAuthStore((state) => state.setToken);

  const router = useRouter();

  // 스크롤링용 ref
  const messagesEndRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    const rawToken = localStorage.getItem('auth_token');

    const roomId = router.query.id as string;
    const userName = userInfoData?.nickname;

    if (!roomId || !userName || isChatConnected) return;

    console.log('일로넘어가냐?', userName);
    // socket 연결 시작
    if (!isChatConnected) {
      socket = io(process.env.NEXT_PUBLIC_BACKEND_ENDPOINT!, {
        path: '/ws',
        transports: ['websocket'],
      });

      socket.on('connect', () => {
        console.log('🟢 WebSocket 연결됨:', socket.id);

        socket.emit('joinRoom', {
          roomId,
          userName,
          token: rawToken,
        });

        setIsChatConnected(true);
        console.log(`➡️ ${userName}님이 ${roomId} 방에 입장`);
      });

      socket.on('chatMessage', (msg) => {
        console.log('📨 수신:', msg);
        setMessages((prev) => [...prev, msg]); // 객체 그대로 저장
      });
    }

    // 기존의 채팅 데이터 내역 불러오기
    const loadMessages = async () => {
      try {
        const messagesResult = await axios.get(
          `${process.env.NEXT_PUBLIC_BACKEND_ENDPOINT}/api/chat/message/list/${roomId}`,
          {
            headers: {
              'Content-type': 'application/json',
            },
          }
        );

        //
        console.log(messagesResult?.data, 'dataatatataat');
        const prevMessages = messagesResult?.data;
        setMessages(prevMessages);
      } catch (error) {
        console.log(error, '에러!');
      }
    };

    loadMessages();

    return () => {
      if (socket) {
        setIsChatConnected(false);
        socket.disconnect();
      }
    };
  }, [router.query.id, userInfoData]);

  useEffect(() => {
    const initToken = async () => {
      const rawToken = localStorage.getItem('auth_token');
      if (!rawToken) return;

      // 토큰 전역으로 먼저 저장 (상태 초기화)
      setToken(rawToken);

      try {
        const tokenUserInfo = await getDecodedToken(rawToken);
        setUserInfoData(tokenUserInfo?.data);

        console.log('token 값 체크합니다', tokenUserInfo);
      } catch (e) {
        console.error('토큰 디코딩 실패:', e);
      }
    };

    initToken();
  }, []);

  // 스크롤링 이벤트 감지용 useEffcet
  useEffect(() => {
    const scrollEl = messagesEndRef.current;

    if (scrollEl) {
      scrollEl.scrollTop = scrollEl.scrollHeight;
    }
  }, [messages]);

  // 메시지 전송
  const handleSendMessage = () => {
    const roomId = router.query.id as string;
    // const userName = userInfoData?.nickname;

    if (socket && message.trim()) {
      socket.emit('chatMessage', {
        roomId,
        userId: userInfoData?.nickname,
        // userName,
        content: message,
      });
      setMessage('');
    }
  };

  console.log('사용자정보들 다 조회하기', messages, userInfoData);

  return (
    <S.Wrapper>
      <S.Chat_Contents ref={messagesEndRef}>
        {messages.map((msg: any, idx) => (
          <S.Chat key={idx} isMine={msg.id === userInfoData?.nickname}>
            <S.UserImg_Box isMine={msg.id === userInfoData?.nickname}>
              <S.User_Img_Icon src='/chatuser1.png' />
              <S.User_Name>{msg.id}</S.User_Name>
            </S.UserImg_Box>
            <S.Chat_Info_Box isMine={msg.id === userInfoData?.nickname}>
              <S.Chat_Message isMine={msg.id === userInfoData?.nickname}>
                {msg.content}
              </S.Chat_Message>
              <S.Send_Time isMine={msg.id === userInfoData?.nickname}>
                {messages && transISOToHumanTime(msg.time)?.slice(10)}
              </S.Send_Time>
            </S.Chat_Info_Box>
          </S.Chat>
        ))}
      </S.Chat_Contents>
      <S.ChatEnter>
        <S.Message_Input
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
              e.preventDefault();
              handleSendMessage();
            }
          }}
        />
        <S.Send_Btn onClick={handleSendMessage}>
          <FontAwesomeIcon icon={faPaperPlane} size='lg' />
        </S.Send_Btn>
      </S.ChatEnter>
    </S.Wrapper>
  );
}
