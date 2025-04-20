import styled from '@emotion/styled';
import Link from 'next/link';

export const Main = styled.main`
  margin: 0 auto;
  /* border: 5px solid red; */
  min-height: 95vh;
  display: flex;
  justify-content: space-between;
`;

export const Left_Side = styled.aside`
  /* border: 5px solid red; */
  /* margin-top: 10px; */
  width: 100%;
  display: flex;
  flex-direction: column;
  /* height: 80%; */
  position: relative;
  border-bottom: 10px solid #152230;
`;

export const TabButton_Wrap = styled.div`
  /* border: 2px solid green; */
  display: flex;
  justify-content: space-between;
  /* background-color: white; */
  background-color: #192736;
  border-right: 10px solid #152230;
`;

export const PlayInfo_Btn = styled.div`
  width: 49.5%;
  height: 90px;
  display: flex;
  justify-content: center;
  align-items: center;
  margin-bottom: 2px;
  font-size: 24px;
  font-weight: 600;
  color: ${({ clickedTab }) =>
    clickedTab === 'info' ? ' #94a3b8;' : '#e2e8f0'};
  cursor: pointer;
  background-color: ${({ clickedTab }: { clickedTab: string }) =>
    clickedTab === 'info' ? '#5c6e83' : '#2a3f55'};

  &:hover {
    background-color: #5c6e83;
    color: #94a3b8;
  }
`;

export const Chat_Btn = styled.div`
  width: 49.5%;
  height: 90px;
  margin-bottom: 2px;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 24px;
  font-weight: 600;
  color: ${({ clickedTab }) =>
    clickedTab === 'info' ? ' #e2e8f0' : '#94a3b8'};
  cursor: pointer;
  background-color: ${({ clickedTab }: { clickedTab: string }) =>
    clickedTab === 'info' ? '#2a3f55' : '#5c6e83'};

  &:hover {
    background-color: #5c6e83;
    color: #94a3b8;
  }
`;

export const LeftSide_Contents = styled.div`
  width: 100%;
  overflow-y: auto;
`;

export const Screen = styled.div`
  /* overflow: auto; */
  height: ${({ clickedTab }: { clickedTab: string }) =>
    clickedTab === 'info' && 'calc(100%  + 440px)'};
`;

export const Betting_Cart = styled.div`
  width: 100%;
  position: absolute;
  bottom: 0;
  background-color: #192736;
`;

export const BetCart_Top = styled.div`
  width: 98.8%;
  height: 65px;
  display: flex;
  justify-content: center;
  align-items: flex-end;
  padding-bottom: 3px;
  font-size: 30px;
  background-color: #192736;
  color: #e2e8f0;
  border: 2px solid #3c4c5d;
  border-bottom: 8px solid #3c4c5d;
  border-radius: 0 0 15px 15px;
  /* border-right: 10px solid #152230; */

  span:nth-of-type(2) {
    color: #ffed00;
    text-shadow: 0 0 0.3px #ffed00, 0 0 0.7px #ffe100, 0 0 1.2px #ffc800;
  }
`;

export const BetCart_Body = styled.div`
  height: 220px;
  display: flex;
  color: #e2e8f0;
  background-color: #192736;
`;

export const Team_Wrap = styled.div`
  width: 30%;
  height: 100%;
`;

export const Home = styled.div`
  height: 51%;
  border-radius: 0 0 10px 10px;
  display: flex;
  background-color: #2a3f55;
  border-bottom: 3px solid #1e2834;
`;

export const Away = styled.div`
  height: 51%;
  border-radius: 0 0 10px 10px;
  display: flex;
  background-color: #2a3f55;
  border-bottom: 3px solid #1e2834;
`;

export const Team_Mark = styled.div`
  width: 50%;
  height: 90%;
  padding: 10px 0 0 10px;
`;

export const Team_Name = styled.div`
  width: 60%;
  height: 90%;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 0 10px;
  text-align: center;
  font-size: 16px;
  font-weight: 600;
`;

export const Team_Img = styled.img`
  width: 100%;
  height: 100%;
`;

export const BetInfo_Wrap = styled.div`
  width: 70%;
  border-right: 10px solid #152230;
`;

export const Odds = styled.div`
  /* border: 3px solid red; */
  height: 50%;
`;

export const Odds_Title = styled.div`
  border: 1px solid #e2e8f0;
  border-bottom: none;
  border-top: none;
  display: flex;
  justify-content: center;
  align-items: center;
  height: 35%;
  border-radius: 0 0 13px 13px;
`;

export const Odds_Select = styled.div`
  height: 65%;
  display: flex;
`;

export const OddInfo = styled.div`
  border: 1px solid #e2e8f0;
  height: 50%;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 15px;
`;

export const Select = styled.div`
  width: 33.3333%;
  /* display: flex; */
  /* flex-direction: row; */
`;

export const Odd = styled.div`
  border: 1px solid #e2e8f0;
  border-top: none;
  height: 50%;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 15px;
`;

export const Betting_Btn = styled.div`
  height: 50%;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 32px;
  color: whitesmoke;
  background-color: #f0c200;
  font-weight: 600;
  cursor: pointer;
  opacity: ${({ isVariableOdd }: { isVariableOdd: boolean }) =>
    isVariableOdd ? 1 : 0.3};

  &:hover {
    background-color: #ffdb1a;
  }
`;

export const Context = styled.aside`
  width: 100%;
  /* height: 100%; */
  display: flex;
  flex-direction: column;
`;

export const Carousel = styled.div`
  background-color: #152230;
  /* flex: 1; */
  width: 100%;
  height: 455px;
  display: flex;
  object-fit: cover;
`;

export const Section_Title = styled.div`
  padding: 15px 0 15px 10px;
  margin-top: 250px;
  border-bottom: 10px solid #152230;
  font-size: 18px;
  font-weight: 800;
  background-color: #192736;
  color: #e2e8f0;
`;

export const Body = styled.div`
  /* border: 3px solid gold; */
  display: flex;
  height: 800px;
  /* min-height: 500px; */
  flex-direction: row;
`;

export const Bottom = styled.div`
  position: relative;
  background-color: #192736;
  display: flex;
  height: 330px;
  margin-top: 250px;
`;

export const OverlayText = styled.div`
  position: absolute;
  top: 240px;
  z-index: 2;
  color: #e4e7eb;
  font-size: 42px;
  font-weight: 700;
  text-shadow: 1px 1px 4px rgba(0, 0, 0, 0.8);
  transition: all 0.4s ease-in-out;
  pointer-events: none; // 마우스에 안걸리게
`;

export const DetailText = styled.div<{ $left?: string }>`
  position: absolute;
  padding: 0 25px;
  top: 200px;
  left: ${({ $left }) => $left || '20px'};
  z-index: 2;
  color: #e4e7eb;
  font-size: 22px;
  font-weight: 500;
  opacity: 0;
  transition: all 0.4s ease;
  pointer-events: none;
  transition: opacity 0.4s ease-in-out 0.1s, transform 0.4s ease 0.1s;
`;

export const Bottom_Section = styled.div`
  position: relative;
  flex: 1;
  display: flex;
  justify-content: flex-start;
  align-items: center;
  cursor: pointer;

  background: radial-gradient(
    circle at center,
    rgba(0, 0, 0, 0.6) 0%,
    rgba(25, 39, 54, 1) 80%
  );
  overflow: hidden;

  &::before {
    content: '';
    position: absolute;
    width: 100%;
    height: 100%;
    top: -50%;
    left: -50%;
    background: radial-gradient(circle, rgba(0, 0, 0, 0.3) 0%, transparent 70%);
    filter: blur(50px);
    z-index: 0;
  }

  & > img {
    position: relative;
    z-index: 1;
  }

  ${OverlayText} {
    &:nth-of-type(1) {
      left: 180px;
    }

    &:nth-of-type(2) {
      left: 300px;
    }
  }

  &:hover ${OverlayText} {
    transform: translateY(-60px);
    opacity: 0;
  }

  &:hover ${DetailText} {
    opacity: 1;
  }

  &:hover > img {
    transform: scale(1.15);
  }
`;

export const Bottom_Img = styled.img`
  width: 63%;
  height: 80%;
  object-fit: contain;
  transition: transform 0.5s ease-in-out;
`;
