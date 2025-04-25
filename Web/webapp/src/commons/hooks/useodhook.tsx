import axios from 'axios';
import { useRouter } from 'next/router';
import { useEffect, useState } from 'react';

export const useOddHooks = () => {
  const router = useRouter();
  const alertWarnText = '[주의]배당률 정보가 없어 배팅이 불가능한 경기입니다';

  const [oddData, setOddData] = useState<any>([]);
  const [isVariableOdd, setIsVariableOdd] = useState(true);
  const [betError, setBetError] = useState<string | null>(null);

  useEffect(() => {
    if (!router.isReady || !router.query.id) return;

    const getOddData = async () => {
      try {
        const response = await axios.get(
          'https://v1.baseball.api-sports.io/odds',
          {
            params: { game: router.query.id },
            headers: {
              'x-apisports-key': process.env.NEXT_PUBLIC_SPORTS_API_KEY,
            },
          }
        );

        const bookmakers = response.data?.response[0]?.bookmakers;
        if (!bookmakers) {
          throw Error(alertWarnText);
          return;
        }

        // ✅ 여기서 Home/Away 또는 Match Winner 찾아서 추출
        let matchValues = null;

        for (const bookmaker of bookmakers) {
          for (const bet of bookmaker.bets) {
            if (
              (bet.name === 'Match Winner' &&
                bet.values.some((v: any) => v.value === 'Home') &&
                bet.values.some((v: any) => v.value === 'Away')) ||
              (bet.name === 'Home/Away' &&
                bet.values.some((v: any) => v.value === 'Home') &&
                bet.values.some((v: any) => v.value === 'Away'))
            ) {
              matchValues = bet.values;
              break;
            }
          }
          if (matchValues) break;
        }

        const selectedMatchOddRaw = matchValues.reduce(
          (acc: any, curr: any) => {
            const key = curr.value.toLowerCase(); // 'home', 'draw', 'away'
            acc[key] = parseFloat(curr.odd).toFixed(1);
            return acc;
          },
          {}
        );

        // 일반 Home/Away 경기 배팅일 시 draw 항목 추가
        if (!('draw' in selectedMatchOddRaw)) {
          selectedMatchOddRaw.draw = 'X';
        }

        // 순서대로 재구성
        const selectedMatchOdd = {
          home: selectedMatchOddRaw.home,
          draw: selectedMatchOddRaw.draw,
          away: selectedMatchOddRaw.away,
        };

        localStorage.setItem('odds', JSON.stringify(selectedMatchOdd));
        setOddData(selectedMatchOdd);
        setIsVariableOdd(true);
      } catch (error) {
        const noOdds = { home: 'X', draw: 'X', away: 'X' };
        localStorage.setItem('odds', JSON.stringify(noOdds));
        setOddData(noOdds);
        setIsVariableOdd(false);

        if (error instanceof Error) setBetError(error.message);

        return;
      }
    };

    getOddData();
  }, [router.isReady, router.query.id]);

  return { setBetError, betError, isVariableOdd, oddData };
};
