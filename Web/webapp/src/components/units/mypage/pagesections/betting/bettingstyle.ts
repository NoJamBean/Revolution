import styled from '@emotion/styled';

// 게임 상태에 따른 색상 구별 함수
const getStatusColor = (status: string): string => {
  switch (status.toUpperCase()) {
    case 'BEFORE':
      return '#3c7ac4'; // 시작 전
    case 'PLAYING':
      return '#e6be3a'; // 진행 중
    case 'FINISHED':
      return '#c75c5c'; // 끝남
    default:
      return '#999999'; // 예외 또는 알 수 없음
  }
};

const getStatusLight = (status: string) => {
  switch (status.toUpperCase()) {
    case 'BEFORE':
      return {
        background: 'radial-gradient(circle at 40% 40%, #3d8bff, #1e2f3f 85%)',
        boxShadow: `0 0 4px 1px rgba(61, 139, 255, 0.45),
                    inset 0 0 3px rgba(255, 255, 255, 0.18)`,
      };
    case 'PLAYING':
      return {
        background: 'radial-gradient(circle at 40% 40%, #e6be3a, #1e2f3f 85%)',
        boxShadow: `0 0 4px 1px rgba(230, 190, 58, 0.4),
                    inset 0 0 3px rgba(255, 255, 255, 0.15)`,
      };
    case 'FINISHED':
      return {
        background: 'radial-gradient(circle at 40% 40%, #e74c3c, #1e2f3f 85%)',
        boxShadow: `0 0 4px 1px rgba(231, 76, 60, 0.45),
                    inset 0 0 3px rgba(255, 255, 255, 0.12)`,
      };
    default:
      return {
        background: 'transparent',
        boxShadow: 'none',
      };
  }
};

export const InfoWrapper = styled.div`
  background-color: #1e2f3f;
  box-shadow: 2px 2px 6px rgba(0, 0, 0, 0.4);
  width: 90%;
  height: 600px;
  border-radius: 20px;
  display: flex;
  flex-direction: column;
`;

export const Info_Top = styled.div`
  height: 100px;
  font-size: 36px;
  font-weight: 700;
  display: flex;
  align-items: center;
  padding-left: 30px;
  color: #d8e4f0;
`;

export const Info_Body = styled.div`
  margin: 0 30px 30px 30px;
  display: flex;
  flex-direction: column;
  border-top: 1px solid rgba(216, 228, 240, 0.3);
  height: 500px;
  cursor: pointer;
  overflow-y: auto;
  /* 스크롤바 숨기기 */
  scrollbar-width: none; /* Firefox */
  -ms-overflow-style: none; /* IE, Edge */

  &::-webkit-scrollbar {
    display: none; /* Chrome, Safari, Opera */
  }
`;

export const Bet_InfoBlock = styled.div`
  width: 100%;
  height: 140px;
  flex-shrink: 0;
  background-color: #27364a;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.35);
  border-radius: 12px;
  display: flex;
  align-items: center;
  padding-right: 20px;
  cursor: pointer;

  :nth-of-type(1) {
    margin-top: 40px;
  }

  :not(:nth-of-type(1)) {
    margin-top: 20px;
  }
`;

export const SelectSport = styled.div`
  width: 100px;
  height: 140px;
  display: flex;
  justify-content: flex-end;
  /* border: 2px solid green; */
`;

export const Sport_Img = styled.img`
  /* border: 2px solid red; */
  width: 85%;
  height: 85px;
`;

export const Bet_Contents = styled.div`
  flex: 1;
  height: 140px;
  position: relative;
`;

export const Match_Detail = styled.div`
  margin-left: 10px;
  margin-top: 15px;
  display: flex;
`;

export const Detail_Left = styled.div`
  flex: 1;
`;

export const Detail_Right = styled.div`
  flex: 1;
  display: flex;
  justify-content: flex-end;
`;

export const Match_Date = styled.div`
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  margin-bottom: 10px;
  span {
    display: inline-block;
    :nth-of-type(1) {
      color: #d8e4f0;
    }
  }
`;

export const Status_Light = styled.div<{ status: string }>`
  width: 14px;
  height: 14px;
  border-radius: 50%;

  ${({ status }) => {
    const { background, boxShadow } = getStatusLight(status);

    return `
      background: ${background};
      box-shadow: ${boxShadow};
    `;
  }}
`;

export const Games = styled.div`
  display: flex;
  justify-content: space-between;
  font-size: 16px;
  font-weight: 400;
  color: #e6c81a;
  text-shadow: 0 0 0.3px #e6c81a, 0 0 0.6px #dabd1a, 0 0 1.1px #c0a200;
  margin-bottom: 5px;
`;

export const Bet_Amount_Info = styled.div`
  display: flex;
  flex-direction: column;
  align-items: flex-end;
`;

export const MyBet = styled.div`
  margin-top: 55px;
  display: flex;
  justify-content: space-between;
  width: 160px;
  span {
    :nth-of-type(1) {
      color: #e6c81a;
      font-weight: 400;
      text-shadow: 0 0 0.3px #e6c81a, 0 0 0.6px #dabd1a, 0 0 1.1px #c0a200;
    }

    :nth-of-type(2) {
      color: #d8e4f0;
    }
  }
`;

export const Expected = styled.div`
  margin-top: 2px;
  display: flex;
  justify-content: space-between;
  width: 160px;
  top: 110px;
  left: 660px;

  span {
    :nth-of-type(1) {
      color: #e6c81a;
      font-weight: 400;
      text-shadow: 0 0 0.3px #e6c81a, 0 0 0.6px #dabd1a, 0 0 1.1px #c0a200;
    }

    :nth-of-type(2) {
      color: #d8e4f0;
    }
  }
`;

export const HomeandAway = styled.div`
  display: flex;
  justify-content: space-between;
  color: #d8e4f0;
  font-size: 18px;
  font-weight: 600;

  span {
    :nth-of-type(1) {
      margin-right: 8px;
      color: #3da5f5;
    }

    :nth-of-type(3) {
      margin-left: 8px;
      color: #f25b5b;
    }
  }
`;

export const MatchTeams = styled.div``;

export const Game_Status = styled.div<{ status: string }>`
  margin-top: 15px;
  color: ${({ status }) => getStatusColor(status)};
`;

export const Edit_Btn = styled.button`
  width: 100px;
  height: 40px;
  border-radius: 7px;
  margin-top: 15px;
  font-weight: 700;
  letter-spacing: 0.32px;
  background-color: #e6c81a;
  cursor: pointer;
`;
