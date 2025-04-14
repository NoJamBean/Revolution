import { useState } from 'react';
import PlayListInfo from '../../commons/playinfo/playinfolist';
import * as S from './betstyle';
import PlayWidget from '../../commons/oddwidget/widget';
import { useRouter } from 'next/router';
import { useMatchInfo } from '../../commons/oddwidget/widgetprovider';

export default function Betting() {
  const BetAmount = [5000, 10000, 50000, 100000, 300000, 500000];
  // const router = useRouter();

  const { setSelectSport } = useMatchInfo();

  const [bet, setBet] = useState(0);
  const [expected, setExpected] = useState(0);

  const changeCategorySport = (e) => {
    const spans = e.currentTarget.querySelectorAll('span');
    const target = spans[0].innerText;

    setSelectSport(target);
  };

  const payBet = (amount: number) => {
    if (bet + amount > 1000001) {
      alert('백만원 이상 못거셈 ㅅㄱ');
      return;
    }

    multiplieBet(amount);
    setBet((prev) => prev + Number(amount));
  };

  const multiplieBet = (amount: number) => {
    // 추후 각 경기별 선택한 배당률로 수정될 부분
    const odd = 1.45;
    const total = (bet + Number(amount)) * odd;

    setExpected(total);
  };

  const resetBet = () => {
    setBet(0);
    setExpected(0);
  };

  const maxBet = () => {
    const odd = 1.45;
    const total = Number(1000000) * odd;

    setBet(1000000);
    setExpected(total);
  };

  return (
    <S.Wrapper>
      <S.Section1>
        <S.MatchBox>
          <S.MatchBox_Top>
            <span>MATCH OF THE DAY</span>
            <span>{`>>`}</span>
          </S.MatchBox_Top>
          <S.Category_Nav>
            <S.Category_Ul>
              <S.Category_Li onClick={changeCategorySport}>
                <span>FOOTBALL</span>
                <span>경기 수 51</span>
              </S.Category_Li>
              <S.Category_Li onClick={changeCategorySport}>
                <span>BASEBALL</span>
                <span>경기 수 15</span>
              </S.Category_Li>
              <S.Category_Li onClick={changeCategorySport}>
                <span>BASKETBALL</span>
                <span>경기 수 35</span>
              </S.Category_Li>
              <S.Category_Li onClick={changeCategorySport}>
                <span>ICE HOCKEY</span>
                <span>경기 수 25</span>
              </S.Category_Li>
              <S.Category_Li>
                <span>UFC</span>
                <span>{`예정 (준비중)`}</span>
              </S.Category_Li>
              <S.Category_Li>
                <span>E-SPORTS</span>
                <span>{`예정 (준비중)`}</span>
              </S.Category_Li>
            </S.Category_Ul>
          </S.Category_Nav>
        </S.MatchBox>
      </S.Section1>
      <S.Section2>
        <PlayListInfo widget={true} />
      </S.Section2>
      <S.Section3>
        <PlayWidget isMain={false} />
      </S.Section3>
      <S.Section4>
        <S.BettionBox>
          <S.BettingBox_Top>
            <span>BETTING</span>
            <span>CART</span>{' '}
          </S.BettingBox_Top>
          <S.BettingBox_Body>
            <S.BetOdds>
              <S.OddBtn>WIN</S.OddBtn>
              <S.OddBtn>VS</S.OddBtn>
              <S.OddBtn>LOSE</S.OddBtn>
            </S.BetOdds>
            <S.Betting_Total>
              <span>배팅금액</span>
              <span>{bet}</span>
            </S.Betting_Total>
            <S.Select_Bet_Money>
              {BetAmount.map((el) => (
                <S.Amount key={el} onClick={() => payBet(el)}>
                  {el}
                </S.Amount>
              ))}
              <S.BetAdjust>
                <S.AdjustBtn onClick={resetBet}>RESET</S.AdjustBtn>
                <S.AdjustBtn onClick={maxBet}>MAX</S.AdjustBtn>
              </S.BetAdjust>
            </S.Select_Bet_Money>
            <S.OddsResult>
              <span>배당률 합계</span>
              <span>x 1.45</span>
            </S.OddsResult>
            <S.Expected_Payout>
              <span>예상당첨금액</span>
              <span>{`₩${expected}`}</span>
            </S.Expected_Payout>
            <S.Bet_Btn>BET</S.Bet_Btn>
          </S.BettingBox_Body>
        </S.BettionBox>
      </S.Section4>
    </S.Wrapper>
  );
}
