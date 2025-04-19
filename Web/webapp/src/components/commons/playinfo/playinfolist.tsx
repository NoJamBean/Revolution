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
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faCircle, faFutbol } from '@fortawesome/free-regular-svg-icons';
import {
  faA,
  faBaseball,
  faBasketball,
  faHockeyPuck,
} from '@fortawesome/free-solid-svg-icons';
import { useModal } from '../modal/modalprovider';
import Loading from '../modal/contents/loading';
import { useGetDateandTime } from '@/src/commons/utils/getdatetime';

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
    clickedPlay,
    setClickedPlay,
  } = useMatchInfo();

  const { openModal, closeModal, isLoading } = useModal();
  const { getDate, getTime } = useGetDateandTime();

  const sportsList = [
    { sport: 'ALL', label: 'ALL', icon: faA },
    { sport: 'FOOTBALL', label: 'FOOTBALL', icon: faFutbol },
    { sport: 'BASEBALL', label: 'BASEBALL', icon: faBaseball },
    { sport: 'BASKETBALL', label: 'BASKETBALL', icon: faBasketball },
    { sport: 'ICEHOCKEY', label: 'ICEHOCKEY', icon: faHockeyPuck },
    { sport: 'HANDBALL', label: 'HANDBALL', icon: faCircle },
  ];

  const getTargetMatch = async (target: any, selectSport: string) => {
    console.log(target, 'targettete');

    if (!isLoading) {
      openModal(Loading); // API 응답 때 까지 로딩모달 open
    }

    try {
      const targetMatchInfo = await getTargetedMatchInfo(target, selectSport);
      console.log('매치인포메이12w션', targetMatchInfo);

      setHomeAwayData(targetMatchInfo, selectSport);
      setClickedPlay(target);

      // 자체적으로 선택된 값 (ex. 초기 페이지 렌더링 시, 그 때의 선택된 값을 그대로 query parms에 추가)
      const current = new URLSearchParams(window.location.search);
      current.set('id', target);
      current.set('sport', selectSport);

      router.push(
        `${window.location.pathname}?${current.toString()}`,
        undefined,
        { shallow: true }
      );
    } catch (error) {
      // setIsLimit(true)
    } finally {
      closeModal();
    }
  };

  const clickSport = (e: any) => {
    // const selectedSport = e.currentTarget.innerHTML;
    const selectedSport = e.currentTarget.getAttribute('data-sport');
    setSelectSport(selectedSport);
    // deleteParams(); // 일단 여기만 박아봐

    const current = new URLSearchParams(window.location.search);

    // ❗ id 제거
    current.delete('id');

    // ✅ sport 추가 또는 덮어쓰기
    current.set('sport', selectedSport);

    router.push(
      `${window.location.pathname}?${current.toString()}`,
      undefined,
      { shallow: true }
    );

    console.log(selectSport, '경로확인해라', selectedSport);
  };

  // const deleteParams = async () => {
  //   const url = new URL(window.location.href);
  //   url.searchParams.delete('id');

  //   const nextPath =
  //     url.pathname +
  //     (url.searchParams.toString() ? `?${url.searchParams.toString()}` : '');

  //   await router.replace(nextPath, undefined, { shallow: true });
  //   await new Promise((r) => setTimeout(r, 0));
  // };

  //
  //
  const getTodayFixtures = async () => {
    console.log('로딩중인가요??????', isLoading);

    if (!isLoading) {
      openModal(Loading); // API 응답 때 까지 로딩모달 open
    }

    try {
      let playMatchList = [];
      let sportKey = selectSport;

      if (sportKey === 'FOOTBALL') {
        playMatchList = await getFootballMatchList();
        if (playMatchList.length === 0) closeModal();
      } else if (sportKey === 'BASEBALL') {
        playMatchList = await getBaseballlMatchList();
        if (playMatchList.length === 0) closeModal();
      } else if (sportKey === 'BASKETBALL') {
        playMatchList = await getBasketballMatchList();
        if (playMatchList.length === 0) closeModal();
      } else if (sportKey === 'ICEHOCKEY') {
        playMatchList = await getIceHockeyMatchList();
        if (playMatchList.length === 0) closeModal();
      } else if (sportKey === 'HANDBALL') {
        playMatchList = await getHandBallMatchList();
        if (playMatchList.length === 0) closeModal();
      }

      const modifiedResult = setDefaultApiData(
        playMatchList,
        sportKey ?? 'BASEBALL'
      );

      if (modifiedResult.length === 0) throw Error('API 한도초과');

      // ✅ 공통 처리 구간
      const currentId = String(router.query.id);
      const validId = modifiedResult.some(
        (match: any) => String(match.id) === currentId
      )
        ? currentId
        : modifiedResult[0]?.id;

      // ❗ 유효하지 않은 경우 replace로 URL 정정
      if (validId !== currentId) {
        const params = new URLSearchParams(window.location.search);
        params.set('id', validId);
        params.set('sport', sportKey ?? 'BASEBALL');

        await router.replace(
          `${window.location.pathname}?${params.toString()}`,
          undefined,
          { shallow: true }
        );
      }

      allMatchRef.current = validId;
      setClickedPlay(validId);
      getTargetMatch(validId, sportKey ?? 'BASEBALL'); // router.push 안함

      if (isLimit) setIsLimit(false);
    } catch (error) {
      if ((error as Error).message === 'API 한도초과') setIsLimit(true);
    }
  };
  //
  //
  useEffect(() => {
    getTodayFixtures();
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

  return (
    <S.Right_Side>
      <S.Play_Category_Bar>
        <S.Category>
          {sportsList.map(({ sport, label, icon }) => (
            <S.Category_Li
              key={sport}
              data-sport={sport}
              onClick={sport === 'ALL' ? undefined : clickSport}
              isClicked={selectSport === sport}
            >
              <FontAwesomeIcon
                icon={icon}
                size='2x'
                style={{ color: selectSport === sport ? '#94a3b8' : '#fdfcf9' }}
              />
              <span>{label}</span>
            </S.Category_Li>
          ))}
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
