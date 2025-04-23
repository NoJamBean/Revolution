import { useState } from 'react';
import * as S from './chatstyle';
import { faPaperPlane } from '@fortawesome/free-regular-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

export default function Chat() {
  const dummyMessages = [
    {
      id: '1',
      senderId: 'user_123',
      senderName: '현섭',
      content: '안녕하세요! 경기 기대되네요 🔥',
      timestamp: '10:32',
    },
    {
      id: '2',
      senderId: 'user_456',
      senderName: 'Alice',
      content: '저도요! 어느 팀 응원하세요?',
      timestamp: '10:33',
    },
    {
      id: '3',
      senderId: 'user_789',
      senderName: 'Bob',
      content: '우리 팀 이겨야죠!!',
      timestamp: '10:33',
    },
    {
      id: '4',
      senderId: 'user_123',
      senderName: '현섭',
      content: '전 홈팀 응원 중이에요 ㅎㅎ',
      timestamp: '10:34',
    },
    {
      id: '5',
      senderId: 'user_321',
      senderName: 'Jessica',
      content: '방금 골 장면 봤어요?! 대박!',
      timestamp: '10:35',
    },
    {
      id: '6',
      senderId: 'user_123',
      senderName: '현섭',
      content: '봤어요!! 진짜 미쳤음 ㄷㄷ',
      timestamp: '10:36',
    },
    {
      id: '7',
      senderId: 'user_321',
      senderName: 'Jessica',
      content: '방금 골 장면 봤어요?! 대박!',
      timestamp: '10:35',
    },
    {
      id: '8',
      senderId: 'user_123',
      senderName: '현섭',
      content: '봤어요!! 진짜 미쳤음 ㄷㄷ',
      timestamp: '10:36',
    },
    {
      id: '9',
      senderId: 'user_321',
      senderName: 'Jessica',
      content: '방금 골 장면 봤어요?! 대박!',
      timestamp: '10:35',
    },
    {
      id: '10',
      senderId: 'user_123',
      senderName: '현섭',
      content: '봤어요!! 진짜 미쳤음 ㄷㄷ',
      timestamp: '10:36',
    },
    {
      id: '11',
      senderId: 'user_321',
      senderName: 'Jessica',
      content: '방금 골 장면 봤어요?! 대박!',
      timestamp: '10:35',
    },
    {
      id: '12',
      senderId: 'user_123',
      senderName: '현섭',
      content: '봤어요!! 진짜 미쳤음 ㄷㄷ',
      timestamp: '10:36',
    },
    {
      id: '13',
      senderId: 'user_321',
      senderName: 'Jessica',
      content: '방금 골 장면 봤어요?! 대박!',
      timestamp: '10:35',
    },
    {
      id: '14',
      senderId: 'user_123',
      senderName: '현섭',
      content: '봤어요!! 진짜 미쳤음 ㄷㄷ',
      timestamp: '10:36',
    },
  ];

  const me = 'user_123';

  return (
    <S.Wrapper>
      <S.Chat_Contents>
        {dummyMessages?.map((message) => (
          <S.Chat isMine={message.senderId === me}>
            <S.UserImg_Box isMine={message.senderId === me}>
              <S.User_Img_Icon src='/chatuser1.png' />
              <S.User_Name>{message.senderName}</S.User_Name>
            </S.UserImg_Box>
            <S.Chat_Info_Box>
              <S.Chat_Message isMine={message.senderId === me}>
                {message.content}
              </S.Chat_Message>
              <S.Send_Time isMine={message.senderId === me}>
                {message.timestamp}
              </S.Send_Time>
            </S.Chat_Info_Box>
          </S.Chat>
        ))}
      </S.Chat_Contents>
      <S.ChatEnter>
        <S.Message_Input></S.Message_Input>
        <S.Send_Btn>
          <FontAwesomeIcon icon={faPaperPlane} size='lg' />
        </S.Send_Btn>
      </S.ChatEnter>
    </S.Wrapper>
  );
}
