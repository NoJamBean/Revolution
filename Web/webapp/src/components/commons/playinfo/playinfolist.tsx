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
import { useSportStore } from '@/src/commons/stores/queryparmstore';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faCircle, faFutbol } from '@fortawesome/free-regular-svg-icons';
import {
  faA,
  faBaseball,
  faBasketball,
  faHockeyPuck,
} from '@fortawesome/free-solid-svg-icons';
import { useModal } from '../modal/modalprovider';

export default function PlayListInfo(props: any) {
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
    clickedPlay,
    setClickedPlay,
    setMatchCount,
  } = useMatchInfo();

  const { setIsLoading, isLoading, closeModal } = useModal();

  const getTargetMatch = async (target: any, selectSport: string) => {
    setIsLoading(true);

    try {
      const targetMatchInfo = await getTargetedMatchInfo(target, selectSport);
      console.log('매치인포메이션', targetMatchInfo);

      setHomeAwayData(targetMatchInfo, selectSport);

      setClickedPlay(target);
      setMatchId(target); // 이후 배팅하기 버튼 클릭 시 사용될 쿼리 파라미터 url 값

      // 페이지 이동 방지 (url 경로만 변경해서 라우팅)
      if (router.pathname === '/bet') {
        // shallow routing
        router.push(
          {
            pathname: '/bet',
            query: { id: target, sport: selectSport },
          },
          undefined,
          { shallow: true }
        );
      }
    } catch (error) {
      // setIsLimit(true)
      console.log(error);
    } finally {
      console.log('해결됨됨디ㅚ도디ㅗ미ㅗ디ㅗㅗ디뫼도미');
      closeModal();
    }
  };

  const clickSport = (e: any) => {
    // const selectedSport = e.currentTarget.innerHTML;
    const selectedSport = e.currentTarget.getAttribute('data-sport');
    setSelectSport(selectedSport);
    deleteParams(); // 일단 여기만 박아봐

    console.log(selectSport, '경로확인해라 씹새끼야', selectedSport);
  };

  const deleteParams = async () => {
    const url = new URL(window.location.href);
    url.searchParams.delete('id');

    const nextPath =
      url.pathname +
      (url.searchParams.toString() ? `?${url.searchParams.toString()}` : '');

    await router.replace(nextPath, undefined, { shallow: true });
    await new Promise((r) => setTimeout(r, 0));
  };

  //
  //
  const getTodayFixtures = async () => {
    const { source } = useSportStore.getState();

    try {
      if (selectSport === 'FOOTBALL') {
        // 축구 API (경기 List)
        const playMatchList = await getFootballMatchList();
        const modifiedResult = setDefaultApiData(playMatchList, 'FOOTBALL');

        if (modifiedResult.length === 0) throw Error('API 한도초과');

        setMatchCount((prev) => {
          return {
            ...prev,
            FOOTBALL: modifiedResult.length,
          };
        });

        // deleteParams();

        if (router.query.id) {
          allMatchRef.current = String(router.query.id);
        } else {
          allMatchRef.current = modifiedResult?.[0]?.id;
        }

        getTargetMatch(allMatchRef.current, selectSport);

        if (isLimit) setIsLimit(false);
        return;
      }
      if (selectSport === 'BASEBALL') {
        const playMatchList = await getBaseballlMatchList();
        const modifiedResult = setDefaultApiData(playMatchList, 'BASEBALL');

        if (modifiedResult.length === 0) throw Error('API 한도초과');

        setMatchCount((prev) => {
          return {
            ...prev,
            BASEBALL: modifiedResult.length,
          };
        });

        // await deleteParams();

        if (router.query.id) {
          allMatchRef.current = String(router.query.id);
        } else {
          allMatchRef.current = modifiedResult?.[0]?.id;
        }

        getTargetMatch(allMatchRef.current, selectSport);

        if (isLimit) setIsLimit(false);
        return;
      }
      if (selectSport === 'BASKETBALL') {
        const playMatchList = await getBasketballMatchList();
        const modifiedResult = setDefaultApiData(playMatchList, 'BASKETBALL');

        if (modifiedResult.length === 0) throw Error('API 한도초과');

        setMatchCount((prev) => {
          return {
            ...prev,
            BASKETBALL: modifiedResult.length,
          };
        });

        if (router.query.id) {
          allMatchRef.current = String(router.query.id);
        } else {
          allMatchRef.current = modifiedResult?.[0]?.id;
        }

        getTargetMatch(allMatchRef.current, selectSport);

        if (isLimit) setIsLimit(false);
        return;
      }

      if (selectSport === 'ICEHOCKEY') {
        const playMatchList = await getIceHockeyMatchList();
        const modifiedResult = setDefaultApiData(playMatchList, 'ICEHOCKEY');

        if (modifiedResult.length === 0) throw Error('API 한도초과');

        setMatchCount((prev) => {
          return {
            ...prev,
            ICEHOCKEY: modifiedResult.length,
          };
        });

        // deleteParams();

        if (router.query.id) {
          allMatchRef.current = String(router.query.id);
        } else {
          allMatchRef.current = modifiedResult?.[0]?.id;
        }

        getTargetMatch(allMatchRef.current, selectSport);

        if (isLimit) setIsLimit(false);
        return;
      }

      if (selectSport === 'HANDBALL') {
        const playMatchList = await getHandBallMatchList();
        const modifiedResult = setDefaultApiData(playMatchList, 'HANDBALL');

        if (modifiedResult.length === 0) throw Error('API 한도초과');

        await deleteParams();
        // console.log('시발아시발아시발아시발아시발아시발아', router.query);

        setMatchCount((prev) => {
          return {
            ...prev,
            HANDBALL: modifiedResult.length,
          };
        });

        const currentId = new URL(window.location.href).searchParams.get('id');

        if (currentId) {
          allMatchRef.current = String(currentId);
        } else {
          allMatchRef.current = modifiedResult?.[0]?.id;
        }
        // if (router.query.id) {
        //   allMatchRef.current = String(router.query.id);
        // } else {
        //   allMatchRef.current = modifiedResult?.[0]?.id;
        // }

        getTargetMatch(allMatchRef.current, selectSport);

        if (isLimit) setIsLimit(false);
        return;
      }

      // getTargetMatch(modifiedResult[0]?.id); // 초기 렌더링 시 첫번째 값에 대한 상세정보 표시되도록 미리 트리거
    } catch (error) {
      const message = (error as Error).message;
      if (message === 'API 한도초과') setIsLimit(true);
    }
  };
  //
  //
  useEffect(() => {
    getTodayFixtures();
    // console.log(isLoading, 'fdsfksnlfksejoigjzslktjesrl;gjerskjhelrsjgerjsa');
  }, [selectSport]);

  useEffect(() => {
    if (router.asPath === '/') {
      getTodayFixtures();
    }
  }, [router.asPath]);

  const handleparms = (id: string) => {
    const current = new URLSearchParams(window.location.search);
    current.set('id', id);

    router.push(
      `${window.location.pathname}?${current.toString()}`,
      undefined,
      { shallow: true }
    );
  };

  //
  //
  //
  // 시간대 설정
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
          <S.Category_Li>
            <FontAwesomeIcon icon={faA} size='2x' />
            <span>ALL</span>
          </S.Category_Li>
          <S.Category_Li data-sport='FOOTBALL' onClick={clickSport}>
            <FontAwesomeIcon icon={faFutbol} size='2x' />
            <span>FOOTBALL</span>
          </S.Category_Li>
          <S.Category_Li data-sport='BASEBALL' onClick={clickSport}>
            <FontAwesomeIcon icon={faBaseball} size='2x' />
            <span>BASEBALL</span>
          </S.Category_Li>
          <S.Category_Li data-sport='BASKETBALL' onClick={clickSport}>
            <FontAwesomeIcon icon={faBasketball} size='2x' />
            <span>BASKETBALL</span>
          </S.Category_Li>
          <S.Category_Li data-sport='ICEHOCKEY' onClick={clickSport}>
            <FontAwesomeIcon icon={faHockeyPuck} size='2x' />
            <span>ICEHOCKEY</span>
          </S.Category_Li>
          <S.Category_Li data-sport='HANDBALL' onClick={clickSport}>
            <FontAwesomeIcon icon={faCircle} size='2x' />
            <span>HANDBALL</span>
          </S.Category_Li>
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
              isClicked={String(clickedPlay) === String(el.id)}
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
