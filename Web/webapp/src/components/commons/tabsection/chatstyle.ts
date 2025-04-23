import styled from '@emotion/styled';

export const Wrapper = styled.div`
  width: 98.8%;
  height: 415px;
  padding: 10px 15px;
  display: flex;
  flex-direction: column;
`;

export const Chat_Contents = styled.div`
  flex-grow: 1;
  overflow-y: auto;
  padding: 0 10px;
  /* border: 2px solid red; */
`;

export const Chat = styled.div<{ isMine: boolean }>`
  height: 50px;
  display: flex;
  flex-direction: ${({ isMine }) => (isMine ? 'row-reverse' : 'row')};
  margin-bottom: 10px;
`;

export const UserImg_Box = styled.div<{ isMine: boolean }>`
  min-width: 80px;
  flex-shrink: 0;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: flex-start;
  flex-direction: ${({ isMine }) => (isMine ? 'row-reverse' : 'row')};
  ${({ isMine }) => (isMine ? 'padding-left:15px' : 'padding-right:15px')};
`;

export const User_Img_Icon = styled.img`
  width: 50px;
  height: 100%;
`;

export const User_Name = styled.div`
  /* width: 80px; */
  display: flex;
  /* padding-left: 10px; */
  color: #e2e8f0;
`;

export const Chat_Info_Box = styled.div<{ isMine: boolean }>`
  flex-grow: 1;
  margin-left: 7px;
  display: flex;
  flex-direction: column;
  align-items: ${({ isMine }) => (isMine ? 'flex-end' : 'flex-start')};
  margin-top: 1px;
`;

export const Chat_Message = styled.div<{ isMine: boolean }>`
  line-height: 1.2;
  padding: 6px 6px 4px 6px;
  display: flex;
  align-items: center;
  font-size: 15px;
  color: #e2e8f0;
  background-color: ${(props) => (props.isMine ? '#3C5C76' : '#2b3e52;')};
  width: fit-content; /* 텍스트 길이에 맞게 줄어들도록 */
  max-width: 100%; /* 혹시 넘칠 경우 대비 */
  border-radius: 5px;
  margin-left: ${(props) => (props.isMine ? 'auto' : '0')};
  margin-right: ${(props) => (props.isMine ? '0' : 'auto')};
`;

export const Send_Time = styled.div<{ isMine: boolean }>`
  height: 23px;
  font-size: 14px;
  margin-left: 3px;
  margin-top: 3px;
  color: #e2e8f0;
  margin-left: ${(props) => (props.isMine ? 'auto' : '0')};
  margin-right: ${(props) => (props.isMine ? '0' : 'auto')};
`;

export const ChatEnter = styled.div`
  /* border: 2px solid green; */
  height: 200px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 10px;
  border-radius: 10px;
  background-color: #263a4c;
`;

export const Message_Input = styled.input`
  all: unset;
  flex-grow: 1;
  height: 70%;
  background-color: #1d2a38;
  border-radius: 10px;
  padding-left: 15px;
`;

export const Send_Btn = styled.div`
  width: 55px;
  height: 70%;
  margin-left: 10px;
  border-radius: 10px;
  display: flex;
  justify-content: center;
  align-items: center;
  cursor: pointer;
  color: #d1d9e0;
  background-color: #304b60;
`;
