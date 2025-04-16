import { useEffect, useRef, useState } from 'react';
import * as S from './playinfoliststyle';
import { useMatchInfo } from '../oddwidget/widgetprovider';
import { getTargetedMatchInfo } from '@/src/api/gettargetmatch';
import {
  getBaseballlMatchList,
  getBasketballMatchList,
  getFootballMatchList,
  getHandBallMatchList,
  getIceHockeyMatchList,
} from '@/src/api/getdefaulmatchlist';
import { useRouter } from 'next/router';

export default function PlayListInfo(props: any) {
  const [clickedPlay, setClickedPlay] = useState(0);
  const [isLoading, setIsLoading] = useState(false);

  const router = useRouter();
  const allMatchRef = useRef<string | string[] | undefined>();

  const {
    setDefaultApiData,
    setHomeAwayData,
    apiData,
    setSelectSport,
    selectSport,
    isLimit,
    setIsLimit,
    setMatchId,
  } = useMatchInfo();

  const getTargetMatch = async (target: any, selectSport: string) => {
    const targetMatchInfo = await getTargetedMatchInfo(target, selectSport);
    setHomeAwayData(targetMatchInfo, selectSport);

    // console.log(router.query, 'router query');
    console.log(target, '시발타겟');

    if (router.pathname === '/bet') {
      // shallow routing
      router.push(
        {
          pathname: '/bet',
          query: { id: target.id, sport: selectSport },
        },
        undefined,
        { shallow: true }
      );
    }

    setClickedPlay(target);
    setMatchId(target.id); // 이후 배팅하기 버튼 클릭 시 사용될 쿼리 파라미터 url 값
  };

  const clickSport = (e: any) => {
    const selectedSport = e.target.innerHTML;
    setSelectSport(selectedSport);
  };

  //
  //
  const getTodayFixtures = async () => {
    setIsLoading(true);

    try {
      if (selectSport === 'FOOTBALL') {
        // 축구 API (경기 List)
        const playMatchList = await getFootballMatchList();
        const modifiedResult = setDefaultApiData(playMatchList, 'FOOTBALL');

        // console.log(modifiedResult.length)
        if (modifiedResult.length === 0) throw Error('API 한도초과');

        if (router.query.id) {
          allMatchRef.current = String(router.query.id);
        } else {
          allMatchRef.current = modifiedResult?.[0]?.id;
        }

        getTargetMatch(allMatchRef.current, selectSport);

        setIsLimit(false);
        return;
      }
      if (selectSport === 'BASEBALL') {
        console.log('BASEBALL HOHO');

        const playMatchList = await getBaseballlMatchList();
        const modifiedResult = setDefaultApiData(playMatchList, 'BASEBALL');

        if (modifiedResult.length === 0) throw Error('API 한도초과');

        if (router.query.id) {
          allMatchRef.current = String(router.query.id);
        } else {
          allMatchRef.current = modifiedResult?.[0]?.id;
        }

        // console.log(modifiedResult.length);

        getTargetMatch(allMatchRef.current, selectSport);

        setIsLimit(false);
        return;
      }
      if (selectSport === 'BASKETBALL') {
        console.log('여기가 트리거됩니다!', router.asPath);

        const playMatchList = await getBasketballMatchList();
        const modifiedResult = setDefaultApiData(playMatchList, 'BASKETBALL');

        // console.log(modifiedResult.length);
        if (modifiedResult.length === 0) throw Error('API 한도초과');

        if (router.query.id) {
          allMatchRef.current = String(router.query.id);
        } else {
          allMatchRef.current = modifiedResult?.[0]?.id;
        }

        getTargetMatch(allMatchRef.current, selectSport);

        setIsLimit(false);
        return;
      }

      if (selectSport === 'ICE HOCKEY') {
        const playMatchList = await getIceHockeyMatchList();
        const modifiedResult = setDefaultApiData(playMatchList, 'ICE HOCKEY');

        if (modifiedResult.length === 0) throw Error('API 한도초과');

        if (router.query.id) {
          allMatchRef.current = String(router.query.id);
        } else {
          allMatchRef.current = modifiedResult?.[0]?.id;
        }

        getTargetMatch(allMatchRef.current, selectSport);

        setIsLimit(false);
        return;
      }

      if (selectSport === 'HANDBALL') {
        const playMatchList = await getHandBallMatchList();
        const modifiedResult = setDefaultApiData(playMatchList, 'HANDBALL');

        if (modifiedResult.length === 0) throw Error('API 한도초과');

        if (router.query.id) {
          allMatchRef.current = String(router.query.id);
        } else {
          allMatchRef.current = modifiedResult?.[0]?.id;
        }

        getTargetMatch(allMatchRef.current, selectSport);

        setIsLimit(false);
        return;
      }

      // getTargetMatch(modifiedResult[0]?.id); // 초기 렌더링 시 첫번째 값에 대한 상세정보 표시되도록 미리 트리거
    } catch (error) {
      console.log((error as Error).message);
      const message = (error as Error).message;

      if (message === 'API 한도초과') setIsLimit(true);
    }
  };
  //
  //
  useEffect(() => {
    console.log(router, 'router');
    getTodayFixtures();
  }, [router.isReady, selectSport]);

  const handleparms = (id: string) => {
    const current = new URLSearchParams(window.location.search);
    current.set('id', id);

    router.push(
      `${window.location.pathname}?${current.toString()}`,
      undefined,
      { shallow: true }
    );
  };

  const getDate = (timezone: string) => {
    const date = new Date(timezone);

    const koreaDate = new Date(date.getTime() + 9 * 60 * 60 * 1000);

    const month = String(koreaDate.getMonth() + 1).padStart(2, '0');
    const day = String(koreaDate.getDate()).padStart(2, '0');

    return `${month}-${day}`;
  };

  const getTime = (timezone: string) => {
    const date = new Date(timezone);

    const koreaDate = new Date(
      date.toLocaleString('en-US', { timeZone: 'Asia/Seoul' })
    );

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
          <S.Category_Li onClick={clickSport}>HANDBALL</S.Category_Li>
        </S.Category>
      </S.Play_Category_Bar>
      {isLimit ? (
        <div>API LIMITED</div>
      ) : (
        apiData?.map((el) => (
          <S.PlayInfo
            key={el.id}
            onClick={() => {
              getTargetMatch(el.id, selectSport ?? 'FOOTBALL');
              handleparms(el.id);
            }}
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
        ))
      )}
    </S.Right_Side>
  );
}
