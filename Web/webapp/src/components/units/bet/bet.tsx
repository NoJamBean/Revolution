import { useEffect, useRef, useState } from 'react';
import PlayListInfo from '../../commons/playinfo/playinfolist';
import * as S from './betstyle';
import PlayWidget from '../../commons/oddwidget/widget';
import { useMatchInfo } from '../../commons/oddwidget/widgetprovider';
import { useOddHooks } from '@/src/commons/hooks/useodhook';
import { useModal } from '../../commons/modal/modalprovider';
import { useAuthStore } from '@/src/commons/stores/authstore';
import { useDecodeToken } from '@/src/commons/utils/decodeusertoken';
import axios from 'axios';
import { useRouter } from 'next/router';

type SportMatchInfo = {
  sport: string;
  count: number;
};

export default function Betting() {
  const [selectOdd, setSelectOdd] = useState(0);
  const [selectTeam, setSelectTeam] = useState('');
  const [expected, setExpected] = useState(0);
  const [sportsCountList, setSportsCountList] = useState<SportMatchInfo[]>([]);
  const [noOdds, setNoOdds] = useState('');

  const [bet, setBet] = useState(0);
  const [betChange, setBetChange] = useState(false);

  const router = useRouter();

  const BetAmount = [5000, 10000, 50000, 100000, 300000, 500000];

  const { setSelectSport } = useMatchInfo();
  const { isLoading } = useModal();
  const { setBetError, betError, isVariableOdd, oddData } = useOddHooks();

  const token = useAuthStore((state) => state.token); // 사용자 토큰

  // const changeCategorySport = (e: React.MouseEvent<HTMLElement>) => {
  //   const spans = e.currentTarget.querySelectorAll('span');
  //   const target = spans[0].innerText;

  //   useSportStore.getState().setSource('betpage');

  //   setSelectSport(target);
  // };

  useEffect(() => {
    // 당일 스포츠 종목별 총 경기 수
    const countresult = localStorage.getItem('sportscount');
    if (countresult === null) return;

    const sportsList = JSON.parse(countresult ?? '');
    setSportsCountList(sportsList);
  }, []);

  useEffect(() => {
    console.log('매번 트리거된다잉');
    setBet(0);
    setExpected(0);

    if (!isLoading && betError) {
      alert(betError);
      setBetError(null); // 한 번 alert 띄운 뒤 초기화

      const localData = localStorage.getItem('odds') ?? '{}';
      const noOdds = JSON.parse(localData);

      setNoOdds(noOdds);
    }
  }, [isLoading, betError]);

  // 배당률 선택
  const clickOdd = (e: any, key) => {
    const selected = e.currentTarget.getAttribute('data-odd');
    const selectOdd = Number(selected);

    setSelectOdd(selectOdd);
    setSelectTeam(key);

    //이전 선택금액 기록 reset
    resetBet();
  };

  const multiplieBet = (amount: number) => {
    // 추후 각 경기별 선택한 배당률로 수정될 부분
    const totalRaw = (bet + Number(amount)) * Number(selectOdd);
    const total = Number(totalRaw.toFixed(2));

    setExpected(total);
  };

  // reset or max
  const resetBet = () => {
    setBet(0);
    setBetChange(true);

    setExpected(0);
  };

  const maxBet = () => {
    const total = Number(1000000) * Number(selectOdd);

    setBet(1000000);
    setBetChange(true);

    setExpected(total);
  };

  const payBet = (amount: number) => {
    if (bet + amount > 1000001) {
      alert('백만원 이상 못거셈 ㅅㄱ');
      return;
    }

    multiplieBet(amount);
    setBet((prev) => prev + Number(amount));
  };

  // 실제 배팅 트리거 함수
  const { getDecodedToken } = useDecodeToken(); // token Decoding Hooks

  const doBet = async () => {
    if (selectOdd === 0) {
      alert('배당률을 선택하세요');
      return;
    }

    const decoded = await getDecodedToken(token ?? '');

    const obj = decoded?.data;
    const userId = obj[`cognito:username`];

    const { sport } = router.query;

    // console.log(username, '23123123123');

    const result = await axios.post(
      `${process.env.NEXT_PUBLIC_BACKEND_API_ENDPOINT}/api/games/update`,
      {
        id: userId,
        type: sport,
        gameDate: '2025-04-20T19:00:00',
        home: 'ManCity',
        away: 'Liverpool',
        wdl: 'win',
        odds: 1.85,
        price: 10000,
        status: 'PLAYING',
      },
      {
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
      }
    );
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
              {sportsCountList.map((info) => (
                <S.Category_Li key={info.sport}>
                  <div className='hover-off'>
                    <span>{info.sport}</span>
                    <div>{`(?)`}</div>
                  </div>
                  <div className='hover-on'>
                    <span>{info.sport}</span>
                    <span className='count'>{info.count} 경기</span>
                  </div>
                </S.Category_Li>
              ))}
              <S.Category_Li>
                <span>VOLLEYBALL</span>
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
            <span>CART</span>
          </S.BettingBox_Top>
          <S.BettingBox_Body>
            <S.BetOdds>
              {(isVariableOdd
                ? Object.entries(oddData)
                : Object.entries(noOdds)
              ).map(([key, value]) => (
                <S.OddBtn
                  key={key}
                  data-odd={value}
                  onClick={
                    isVariableOdd && !Number.isNaN(Number(value))
                      ? (e) => clickOdd(e, key)
                      : undefined
                  }
                  isClicked={selectOdd === Number(value) && selectTeam === key}
                >
                  <span>{key.charAt(0).toUpperCase() + key.slice(1)}</span>
                  <span>{`(${value})`}</span>
                </S.OddBtn>
              ))}
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
              <span>배당률</span>
              <span>{`X ${selectOdd}`}</span>
            </S.OddsResult>
            <S.Expected_Payout>
              <span>예상당첨금액</span>
              <span>{`₩${expected}`}</span>
            </S.Expected_Payout>
            <S.Bet_Btn isVariableOdd={isVariableOdd} onClick={doBet}>
              BET
            </S.Bet_Btn>
          </S.BettingBox_Body>
        </S.BettionBox>
      </S.Section4>
    </S.Wrapper>
  );
}
