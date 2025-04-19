import styled from '@emotion/styled';

export const Wrapper = styled.div`
  margin: 0 auto;
  min-height: 90vh;
  max-height: 500px;
  display: flex;
  justify-content: space-between;
  display: flex;
`;

export const Section1 = styled.div`
  background-color: #152230;
  flex: 1;
`;

export const MatchBox = styled.div`
  /* height: 70%; */
`;

export const MatchBox_Top = styled.div`
  background-color: #2a3f55;
  height: 65px;
  font-size: 20px;
  font-weight: 700;
  color: #e2e8f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 10px;
`;

export const Category_Nav = styled.div`
  height: 90%;
`;

export const Category_Ul = styled.div`
  height: 100%;
`;

export const Category_Li = styled.div`
  position: relative;
  border: 2px solid #2a3f55;
  height: 55px;
  font-size: 17px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 10px;
  background-color: #5c6e83;
  font-weight: 700;
  color: #e2e8f0;
  cursor: pointer;

  .hover-on {
    display: flex;
    justify-content: space-between;
    width: 100%;
    opacity: 0;
    pointer-events: none;
    position: absolute;
    top: 0;
    left: 0;
    height: 100%;
    align-items: center;
    padding: 0 10px;
    transition: opacity 0.8s ease;
  }

  .hover-off {
    display: flex;
    justify-content: space-between;
    width: 100%;
    transition: opacity 0.3s ease;
  }

  &:hover .hover-off {
    opacity: 0;
    pointer-events: none;
  }

  &:hover .hover-on {
    opacity: 1;
    pointer-events: auto;
    background-color: #2a3f55;
  }

  .count {
    opacity: 0;
    transition: opacity 0.3s ease;
  }

  &:hover .count {
    opacity: 1;
  }
`;

export const Section2 = styled.div`
  flex: 1;
`;

export const Section3 = styled.div`
  width: 100%;
  flex: 1;
  background-color: white;
`;

export const Section4 = styled.div`
  background-color: #192736;
  flex: 1;
`;

export const BettionBox = styled.div`
  /* height: 80%; */
  background-color: white;
  border: 3px solid #475569;
  border-top: none;
`;

export const BettingBox_Top = styled.div`
  height: 65px;
  font-size: 20px;
  font-weight: 700;
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: #192736;
  color: #e2e8f0;

  span:nth-of-type(2) {
    color: #ffed00;
    text-shadow: 0 0 0.3px #ffed00, 0 0 0.7px #ffe100, 0 0 1.2px #ffc800;
  }
`;

export const BettingBox_Body = styled.div`
  /* height: 100%; */
`;

export const BetOdds = styled.div`
  width: 100%;
  height: 50px;
  display: flex;
`;

export const OddBtn = styled.div`
  border: 1.5px solid #475569;
  width: calc(100% / 3);
  height: 50px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  color: #e2e8f0;
  background-color: ${({ isClicked }: { isClicked: boolean }) =>
    isClicked ? '#2a3f55' : '#5c6e83'};
  cursor: pointer;

  &:hover {
    background-color: #2a3f55;
  }

  span:first-of-type {
    font-size: 14px;
    font-weight: 500;
  }

  span:last-of-type {
    font-size: 16px;
    font-weight: 600;
  }
`;

export const Betting_Total = styled.div`
  height: 50px;
  display: flex;
  background-color: #192736;
  color: #e2e8f0;
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
      color: #e7c846;
      text-shadow: 0 0 0.4px #e7c846, 0 0 0.9px #d6b834, 0 0 1.2px #c7a82a;
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
  border: 1.5px solid #2a3f55;
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: #5c6e83;
  color: #e2e8f0;
  font-weight: 700;
  cursor: pointer;

  &:hover {
    background-color: #2a3f55;
    color: #e7c846;
    text-shadow: 0 0 0.3px #e7c846, 0 0 0.6px #d6b834, 0 0 0.8px #c7a82a;
  }
`;

export const BetAdjust = styled.div`
  width: 100%;
  height: 50px;
  display: flex;
`;

export const AdjustBtn = styled.div`
  background-color: #5c6e83;
  border: 1.5px solid #2a3f55;
  width: 50%;
  display: flex;
  justify-content: center;
  align-items: center;
  font-weight: 700;
  color: #e2e8f0;
  cursor: pointer;

  &:hover {
    background-color: #2a3f55;
  }
`;

export const OddsResult = styled.div`
  border: 2px solid #2a3f55;
  height: 50px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;
  background-color: #2a3f55;
  color: #e2e8f0;

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
  border: 2px solid #2a3f55;
  height: 50px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background-color: #192736;
  color: #e2e8f0;
  padding: 0 20px;

  span {
    :nth-of-type(1) {
      font-weight: 700;
    }

    :nth-of-type(2) {
      font-weight: 600;
      color: #e7c846;
      text-shadow: 0 0 0.3px #e7c846, 0 0 0.6px #d6b834, 0 0 0.8px #c7a82a;
    }
  }
`;

export const Bet_Btn = styled.div`
  height: 50px;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 22px;
  font-weight: 700;
  background-color: #f0c200;
  cursor: pointer;
  opacity: ${({ isVariableOdd }: { isVariableOdd: boolean }) =>
    isVariableOdd ? 1 : 0.3};

  &:hover {
    background-color: #ffdb1a;
  }
`;

export const BettingBox_Bottom = styled.div``;
