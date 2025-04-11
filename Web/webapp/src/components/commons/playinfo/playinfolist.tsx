import { useEffect, useState } from 'react';
import * as S from './playinfoliststyle';
import { useMatchInfo } from '../oddwidget/widgetprovider';
import { getTargetedMatchInfo } from '@/src/api/gettargetmatch';
import {
  getBasketballMatchList,
  getFootballMatchList,
} from '@/src/api/getdefaulmatchlist';

export default function PlayListInfo(props: any) {
  const [clickedPlay, setClickedPlay] = useState(0);
  const [isLoading, setIsLoading] = useState(false);

  const {
    setDefaultApiData,
    setHomeAwayData,
    apiData,
    setSelectSport,
    selectSport,
  } = useMatchInfo();

  const getTargetMatch = async (target: any, selectSport: string) => {
    const targetMatchInfo = await getTargetedMatchInfo(target, selectSport);

    setHomeAwayData(targetMatchInfo, selectSport);
    setClickedPlay(target);
  };

  const clickSport = (e: any) => {
    const selectedSport = e.target.innerHTML;
    setSelectSport(selectedSport);
  };

  //
  //
  useEffect(() => {
    const getTodayFixtures = async () => {
      setIsLoading(true);

      try {
        // 이건 야구임
        // const response = await axios.get(
        //   'https://v1.baseball.api-sports.io/games',
        //   {
        //     params: { date: '2025-04-10' },
        //     headers: {
        //       'x-apisports-key': process.env.NEXT_PUBLIC_SPORTS_API_KEY,
        //     },
        //   }
        // );
        // const PlayListArr = response.data.response;
        // setPlayList(PlayListArr);
        // console.log(PlayListArr);
        // getTargetMatch(response.data.response[0].id);
        //
        //
        //
        //
        //
        //
        // if (selectSport === 'SOCCER') {
        //   // 축구 API (경기 List)
        //   const playMatchList = await getFootballMatchList();
        //   const modifiedResult = setDefaultApiData(playMatchList, 'FOOTBALL');
        //   return;
        // }
        // if (selectSport === 'BASKETBALL') {
        //   const playMatchList = await getBasketballMatchList();
        //   console.log('농구데이터', playMatchList);
        //   const modifiedResult = setDefaultApiData(playMatchList, 'BASKETBALL');
        //   return;
        // }
        // getTargetMatch(modifiedResult[0]?.id); // 초기 렌더링 시 첫번째 값에 대한 상세정보 표시되도록 미리 트리거
      } catch (error) {
        console.log((error as Error).message);
      }
    };

    getTodayFixtures();
  }, [selectSport]);

  const getDate = (timezone: string) => {
    const date = new Date(timezone);
    const koreaDate = new Date(date.getTime() + 9 * 60 * 60 * 1000);

    const month = String(koreaDate.getMonth() + 1).padStart(2, '0');
    const day = String(koreaDate.getDate()).padStart(2, '0');

    return `${month}-${day}`;
  };

  const getTime = (timezone: string) => {
    const date = new Date(timezone);
    const koreaDate = new Date(date.getTime() + 9 * 60 * 60 * 1000);

    const hour = String(koreaDate.getHours()).padStart(2, '0');
    const minute = String(koreaDate.getMinutes()).padStart(2, '0');

    return `${hour}:${minute}`;
  };

  return (
    <S.Right_Side>
      <S.Play_Category_Bar>
        <S.Category>
          <S.Category_Li onClick={clickSport}>ALL</S.Category_Li>
          <S.Category_Li onClick={clickSport}>FOOTBALL</S.Category_Li>
          <S.Category_Li onClick={clickSport}>BASEBALL</S.Category_Li>
          <S.Category_Li onClick={clickSport}>BASKETBALL</S.Category_Li>
          <S.Category_Li onClick={clickSport}>ICE HOCKEY</S.Category_Li>
        </S.Category>
      </S.Play_Category_Bar>

      {apiData?.map((el) => (
        <S.PlayInfo
          key={el.id}
          onClick={() => getTargetMatch(el.id, selectSport ?? 'FOOTBALL')}
          widget={props.widget}
        >
          <S.Blind
            isClicked={clickedPlay === el.id}
            widget={props.widget}
          ></S.Blind>
          <S.Info_Top widget={props.widget}>
            <S.League_Info>
              <S.League_Logo>
                <S.Logo_Img
                  src={el.league.logo}
                  onError={(e) => (e.currentTarget.src = '/noimage.png')}
                />
              </S.League_Logo>
              <S.LeagueName>{`${el.league.name} ${el.league.season}`}</S.LeagueName>
            </S.League_Info>
            <S.Game_Time_Wrap widget={props.widget}>
              <S.Game_Start_Date>{getDate(el.date)}</S.Game_Start_Date>
              <S.Game_Start_Time>{getTime(el.date)}</S.Game_Start_Time>
            </S.Game_Time_Wrap>
          </S.Info_Top>
          <S.Info_Bottom widget={props.widget}>
            <S.Play_Home widget={props.widget}>
              {props.widget ? (
                <>
                  <S.Info_TeamMark widget={props.widget}>
                    <S.Info_Team_Img
                      src={el.home.logo}
                      onError={(e) => (e.currentTarget.src = '/noimage.png')}
                    />
                  </S.Info_TeamMark>
                  <S.Info_TeamName widget={props.widget}>
                    {el.home.name}
                  </S.Info_TeamName>
                </>
              ) : (
                <>
                  <S.Info_TeamName widget={props.widget}>
                    {el.home.name}
                  </S.Info_TeamName>
                  <S.Info_TeamMark widget={props.widget}>
                    <S.Info_Team_Img
                      src={el.home.logo}
                      onError={(e) => (e.currentTarget.src = '/noimage.png')}
                    />
                  </S.Info_TeamMark>
                </>
              )}
            </S.Play_Home>
            <S.Verses widget={props.widget}>
              <span>{el.scores.home ?? 0}</span> <span>:</span>
              <span>{el.scores.away ?? 0}</span>
            </S.Verses>
            <S.Play_Away widget={props.widget}>
              <S.Info_TeamMark widget={props.widget}>
                <S.Info_Team_Img
                  src={el.away.logo}
                  onError={(e) => (e.currentTarget.src = '/noimage.png')}
                />
              </S.Info_TeamMark>
              <S.Info_TeamName widget={props.widget}>
                {el.away.name}
              </S.Info_TeamName>
            </S.Play_Away>
          </S.Info_Bottom>
        </S.PlayInfo>
      ))}
    </S.Right_Side>
  );
}
