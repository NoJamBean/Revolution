import { useDecodeToken } from '@/src/commons/utils/decodeusertoken';
import { userDataProps } from '../../mypages';
import * as S from './bettingstyle';
import { useAuthStore } from '@/src/commons/stores/authstore';
import { useEffect, useState } from 'react';
import axios from 'axios';
import {
  getExpectedOddPrice,
  transISOToHumanTime,
} from '@/src/commons/utils/getdatetime';
import { getBettedMatchInfo } from '@/src/api/gettargetmatch';
import { getWinner } from '@/src/commons/utils/getwinnerteam';
import { getUpperCase } from '@/src/commons/utils/getUppercase';

interface InfoProps {
  userData?: userDataProps;
}

export interface BetInfo {
  id: string;
  type: string;
  home: string;
  away: string;
  gameDate: string;
  modifiedDate: string;
  odds: number;
  price: number;
  status: string;
  matchId: string;
  wdl: 'HOME' | 'DRAW' | 'AWAY';
}

export default function MyBetList({ userData }: InfoProps) {
  const token = useAuthStore((state) => state.token); // 사용자 토큰

  const [betList, setBetList] = useState<BetInfo[]>([]);
  // const { getDecodedToken } = useDecodeToken();

  useEffect(() => {
    const getUserBetList = async () => {
      const result = await axios.get(
        `${process.env.NEXT_PUBLIC_BACKEND_API_ENDPOINT}/api/games/mygames`,
        {
          headers: {
            Authorization: `Bearer ${token}`,
            'Content-Type': 'application/json',
          },
        }
      );

      console.log('결과체크', result);
      // 이거 다시 생각할 것  (원빈이가 만들어줄 때 까지 안만짐)
      const ResultListArr = result?.data ?? [];
      if (!ResultListArr || ResultListArr.length === 0) return;

      // 병렬보다 순차 처리 추천 (외부 API 제한 있을 수 있음)
      for (const match of ResultListArr) {
        const matchId = match.matchId;
        if (!matchId) continue;

        try {
          const response = await getBettedMatchInfo(matchId);
          const latestStatus = response?.data?.response[0]?.status?.long;

          if (!latestStatus) continue;

          if (latestStatus === 'Not Started') {
            // 아무것도 안 함
            continue;
          }

          if (latestStatus === 'Finished') {
            const homescore = response?.data?.response[0]?.scores?.home?.total;
            const awayscore = response?.data?.response[0]?.scores?.away?.total;
            const winner = getWinner(homescore, awayscore);

            await axios.post(
              `${process.env.NEXT_PUBLIC_BACKEND_API_ENDPOINT}/api/games/update`,
              {
                matchid: matchId,
                winner: winner,
                status: getUpperCase(latestStatus),
              },
              {
                headers: {
                  Authorization: `Bearer ${token}`,
                  'Content-Type': 'application/json',
                },
              }
            );

            continue;
          }

          // 나머지는 PLAYING 처리
          await axios.post(
            `${process.env.NEXT_PUBLIC_BACKEND_API_ENDPOINT}/api/games/update`,
            {
              matchid: matchId,
              status: 'PLAYING',
            },
            {
              headers: {
                Authorization: `Bearer ${token}`,
                'Content-Type': 'application/json',
              },
            }
          );
          continue;
        } catch (err) {
          console.error(`❌ matchId ${matchId} 조회 실패`, err);
        }
      }

      // 👉 다 끝나고 나면 DB 재조회
      const updatedList = await axios.get(
        `${process.env.NEXT_PUBLIC_BACKEND_API_ENDPOINT}/api/games/mygames`,
        {
          headers: {
            Authorization: `Bearer ${token}`,
            'Content-Type': 'application/json',
          },
        }
      );

      const updatedListArr = updatedList?.data ?? [];

      setBetList(updatedListArr);
    };

    getUserBetList();
  }, []);

  console.log('Betting 결과 확인요오오오오오오오옹', betList);

  return (
    <S.InfoWrapper>
      <S.Info_Top>배팅 내역</S.Info_Top>
      <S.Info_Body>
        {betList?.map((bet) => (
          <S.Bet_InfoBlock key={bet?.matchId}>
            <S.SelectSport>
              <S.Sport_Img src='/baseball_ball.png' />
            </S.SelectSport>
            <S.Bet_Contents>
              <S.Match_Detail>
                <S.Detail_Left>
                  <S.Match_Date>
                    <span>{transISOToHumanTime(bet?.gameDate)}</span>
                  </S.Match_Date>
                  <S.Games>
                    <span>GAMES</span>
                  </S.Games>
                  <S.HomeandAway>
                    <S.MatchTeams>
                      <span>{bet?.home}</span>
                      <span>VS</span>
                      <span>{bet?.away}</span>
                    </S.MatchTeams>
                  </S.HomeandAway>
                  <S.Game_Status status={bet?.status}>
                    {bet?.status}
                  </S.Game_Status>
                </S.Detail_Left>
                <S.Detail_Right>
                  <S.Bet_Amount_Info>
                    <S.Status_Light status={bet?.status}></S.Status_Light>
                    <S.MyBet>
                      <span>MYBET</span>
                      <span>{`₩${bet?.price}`}</span>
                    </S.MyBet>
                    <S.Expected>
                      <span>EXPECTED</span>
                      <span>{`₩${getExpectedOddPrice(
                        bet?.price,
                        bet?.odds
                      )}`}</span>
                    </S.Expected>
                  </S.Bet_Amount_Info>
                </S.Detail_Right>
              </S.Match_Detail>
            </S.Bet_Contents>
          </S.Bet_InfoBlock>
        ))}
      </S.Info_Body>
    </S.InfoWrapper>
  );
}
