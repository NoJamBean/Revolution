import styled from '@emotion/styled';

export const Wrapper = styled.div`
  margin: 0 auto;
  border: 5px solid red;
  min-height: 90vh;
  max-height: 500px;
  display: flex;
  justify-content: space-between;
  display: flex;
`;

export const Section1 = styled.div`
  /* border: 2px solid blue; */
  flex: 1;
`;

export const MatchBox = styled.div`
  border: 3px solid gold;
  /* height: 70%; */
`;

export const MatchBox_Top = styled.div`
  border: 2px solid red;
  height: 65px;
  font-size: 20px;
  font-weight: 700;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 10px;
`;

export const Category_Nav = styled.div`
  border: 2px solid green;
  height: 90%;
`;

export const Category_Ul = styled.div`
  border: 2px solid hotpink;
  height: 100%;
`;

export const Category_Li = styled.div`
  border: 3px solid gold;
  height: 55px;
  font-size: 17px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 10px;
`;

export const Section2 = styled.div`
  /* border: 2px solid blue; */
  flex: 1;
`;

export const Section3 = styled.div`
  width: 100%;
  flex: 1;
`;

export const Section4 = styled.div`
  border: 2px solid blue;
  flex: 1;
`;

export const BettionBox = styled.div`
  /* height: 80%; */
`;

export const BettingBox_Top = styled.div`
  height: 65px;
  font-size: 20px;
  font-weight: 700;
  display: flex;
  justify-content: center;
  align-items: center;

  span:nth-of-type(2) {
    color: orange;
  }
`;

export const BettingBox_Body = styled.div`
  border: 2px solid red;
  /* height: 100%; */
`;

export const BetOdds = styled.div`
  width: 100%;
  height: 50px;
  display: flex;
`;

export const OddBtn = styled.div`
  border: 2px solid green;
  width: calc(100% / 3);
  height: 50px;
  display: flex;
  justify-content: center;
  align-items: center;
`;

export const Betting_Total = styled.div`
  border: 3px solid blue;
  height: 50px;
  display: flex;
  justify-content: space-between;

  span {
    display: inline-block;
    width: 100px;
    height: 100%;
    display: flex;
    align-items: center;
    padding: 0 20px;

    :nth-of-type(1) {
      justify-content: flex-start;
      font-weight: 700;
    }

    :nth-of-type(2) {
      justify-content: flex-end;
      font-weight: 600;
    }
  }
`;

export const Select_Bet_Money = styled.div`
  display: flex;
  flex-wrap: wrap;
  align-items: center;
`;

export const Amount = styled.div`
  width: calc(100% / 3);
  height: 50px;
  display: flex;
  justify-content: center;
  align-items: center;
  cursor: pointer;
  border: 2px solid gold;
`;

export const BetAdjust = styled.div`
  width: 100%;
  height: 50px;
  display: flex;
  border: 3px solid green;
`;

export const AdjustBtn = styled.div`
  border: 2px solid red;
  width: 50%;
  display: flex;
  justify-content: center;
  align-items: center;
  font-weight: 700;
  cursor: pointer;
`;

export const OddsResult = styled.div`
  border: 2px solid red;
  height: 50px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;

  span {
    :nth-of-type(1) {
      font-weight: 700;
    }

    :nth-of-type(2) {
      font-weight: 600;
    }
  }
`;

export const Expected_Payout = styled.div`
  border: 2px solid red;
  height: 50px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;

  span {
    :nth-of-type(1) {
      font-weight: 700;
    }

    :nth-of-type(2) {
      font-weight: 600;
    }
  }
`;

export const Bet_Btn = styled.div`
  border: 2px solid red;
  height: 50px;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 22px;
  font-weight: 700;
`;

export const BettingBox_Bottom = styled.div``;
