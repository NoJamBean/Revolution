import styled from '@emotion/styled';
import Link from 'next/link';

export const Main = styled.main`
  margin: 0 auto;
  border: 5px solid red;
  min-height: 95vh;
  display: flex;
  justify-content: space-between;
`;

export const Left_Side = styled.aside`
  border: 10px solid red;
  width: 100%;
  display: flex;
  flex-direction: column;
  /* height: 80%; */
  position: relative;
`;

export const TabButton_Wrap = styled.div`
  /* border: 2px solid green; */
  display: flex;
  justify-content: space-between;
`;

export const PlayInfo_Btn = styled.div`
  width: 49.5%;
  height: 90px;
  border-radius: 10px;
  border: 3px solid green;
  margin-bottom: 2px;
  cursor: pointer;
  background-color: ${({ clickedTab }: { clickedTab: string }) =>
    clickedTab === 'info' ? 'gray' : 'yellow'};
`;

export const Chat_Btn = styled.div`
  width: 49.5%;
  height: 90px;
  border-radius: 10px;
  margin-bottom: 2px;
  border: 3px solid gold;
  cursor: pointer;
  background-color: ${({ clickedTab }: { clickedTab: string }) =>
    clickedTab === 'info' ? 'yellow' : 'gray'};
`;

export const LeftSide_Contents = styled.div`
  width: 100%;
  /* height: calc(100% - 70px); */
  background-color: lightgray;
  /* border: 8px solid blue; */
  overflow-y: auto;
`;

export const Screen = styled.div`
  /* overflow: auto; */
  height: ${({ clickedTab }: { clickedTab: string }) =>
    clickedTab === 'info' && 'calc(100%  + 410px)'};
`;

export const Betting_Cart = styled.div`
  width: 100%;
  position: absolute;
  bottom: 0;
  border: 3px solid purple;
  background-color: wheat;
`;

export const BetCart_Top = styled.div`
  border: 5px solid green;
  height: 65px;
  display: flex;
  justify-content: center;
  align-items: flex-end;
  padding-bottom: 3px;
  font-size: 30px;

  span:nth-of-type(2) {
    color: orange;
  }
`;

export const BetCart_Body = styled.div`
  height: 220px;
  display: flex;
`;

export const Team_Wrap = styled.div`
  width: 30%;
  height: 100%;
`;

export const Home = styled.div`
  border: 2px solid red;
  height: 51%;
  border-radius: 0 0 10px 10px;
  display: flex;
  background-color: lightskyblue;
`;

export const Away = styled.div`
  border: 2px solid red;
  height: 51%;
  border-radius: 0 0 10px 10px;
  display: flex;
  background-color: lightskyblue;
`;

export const Team_Mark = styled.div`
  width: 40%;
  height: 90%;
  border: 2px solid black;
`;

export const Team_Name = styled.div`
  width: 60%;
  height: 90%;
  display: flex;
  align-items: center;
  padding-left: 20px;
  border: 2px solid black;
`;

export const BetInfo_Wrap = styled.div`
  width: 70%;
  border: 5px solid purple;
`;

export const Odds = styled.div`
  border: 3px solid red;
  height: 50%;
`;

export const Odds_Title = styled.div`
  border: 2px solid green;
  display: flex;
  justify-content: center;
  align-items: center;
  height: 35%;
  border-radius: 0 0 10px 10px;
`;

export const Odds_Select = styled.div`
  border: 3px solid yellowgreen;
  height: 65%;
  display: flex;
`;

export const Select = styled.div`
  border: 2px solid green;
  width: 33.3333%;
  /* display: flex; */
  /* flex-direction: row; */
`;

export const OddInfo = styled.div`
  border: 2px solid green;
  height: 50%;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 15px;
`;

export const Odd = styled.div`
  border: 2px solid green;
  height: 50%;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 15px;
`;

export const Betting_Btn = styled.div`
  border: 5px solid orange;
  height: 50%;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 32px;
  color: whitesmoke;
  background-color: orange;
  font-weight: 600;
`;

export const Context = styled.aside`
  border: 3px solid green;
  width: 100%;
  /* height: 100%; */
  display: flex;
  flex-direction: column;
`;

export const Carousel = styled.div`
  background-color: blue;
  flex: 2;
  width: 100%;
  max-height: 420px;
  display: flex;
  object-fit: cover;
  border: 5px solid blue;
`;

export const Section_Title = styled.div`
  border: 2px solid green;
  padding: 15px 0;
  font-size: 18px;
  font-weight: 800;
`;

export const Body = styled.div`
  border: 3px solid gold;
  display: flex;
  height: 800px;
  /* min-height: 500px; */
  flex-direction: row;
`;

export const Bottom = styled.div`
  border: 13px solid green;
  height: 330px;
  margin-top: 180px;
`;
