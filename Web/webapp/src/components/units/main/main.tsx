import { useEffect, useState } from 'react';
import * as S from './styles';
import Chat from '../tabsection/chat';
import PlayListInfo from '../../commons/playinfo/playinfolist';
import PlayWidget from '../../commons/oddwidget/widget';
import { useMatchInfo } from '../../commons/oddwidget/widgetprovider';
import { useRouter } from 'next/router';
import { useModal } from '../../commons/modal/modalprovider';
import { useOddHooks } from '@/src/commons/hooks/useodhook';

export default function Main() {
  const [clickedTab, setClickedTab] = useState('info');

  const { homeAwayInfo, selectSport, clickedPlay } = useMatchInfo();
  const { isLoading } = useModal();

  const router = useRouter();
  const { setBetError, betError, isVariableOdd, oddData } = useOddHooks();

  const clickToggle = (e: any) => {
    if (e.target.id === clickedTab) return;
    setClickedTab(e.target.id);
  };

  const goToBet = () => {
    console.log(homeAwayInfo, 11);

    if (clickedPlay === '') {
      alert('경기 선택하셈');
      return;
    }

    router.push({
      pathname: '/bet',
      query: {
        id: router.query.id, // 이건 playinfolist 에서 shallow routing으로 main 페이지에있을 때 미리 넣은 값
        sport: router.query.sport,
      },
    });
  };

  // Bet Error로 정보값 없고, 로딩 시 트리거되는 useEffect
  useEffect(() => {
    setClickedTab('info');
    if (!isLoading && betError) {
      alert(betError);
      setBetError(null); // 한 번 alert 띄운 뒤 초기화
    }
  }, [isLoading, betError]);

  return (
    <>
      <S.Main>
        <S.Context>
          <S.Carousel>
            <img
              src='/banner.jpg'
              style={{ width: '100%', height: '100%' }}
              alt='carousel'
            />
          </S.Carousel>
          <S.Section_Title>LIVE SPORTS</S.Section_Title>
          <S.Body id='info-sport-section'>
            <S.Left_Side>
              <S.TabButton_Wrap>
                <S.PlayInfo_Btn
                  id='info'
                  onClick={clickToggle}
                  clickedTab={clickedTab}
                >
                  경기 정보
                </S.PlayInfo_Btn>
                <S.Chat_Btn
                  id='chat'
                  onClick={clickToggle}
                  clickedTab={clickedTab}
                >
                  채팅하기
                </S.Chat_Btn>
              </S.TabButton_Wrap>
              <S.LeftSide_Contents>
                <S.Screen clickedTab={clickedTab}>
                  {clickedTab === 'info' ? (
                    <PlayWidget isMain={true} />
                  ) : (
                    <Chat />
                  )}
                </S.Screen>
                <S.Betting_Cart>
                  <S.BetCart_Top>
                    <span>BETTING</span> <span>INFO</span>
                  </S.BetCart_Top>
                  <S.BetCart_Body>
                    <S.Team_Wrap>
                      <S.Home>
                        <S.Team_Mark>
                          <S.Team_Img
                            src={
                              homeAwayInfo?.home?.team?.logo || '/noimage.png'
                            }
                            onError={(e) => {
                              e.currentTarget.onerror = null;
                              e.currentTarget.src = '/noimage.png';
                            }}
                          />
                        </S.Team_Mark>
                        <S.Team_Name>
                          {homeAwayInfo?.home?.team?.name || 'NO_DATA'}
                        </S.Team_Name>
                      </S.Home>
                      <S.Away>
                        <S.Team_Mark>
                          <S.Team_Img
                            src={
                              homeAwayInfo?.away?.team?.logo || '/noimage.png'
                            }
                            onError={(e) => {
                              e.currentTarget.onerror = null;
                              e.currentTarget.src = '/noimage.png';
                            }}
                          />
                        </S.Team_Mark>
                        <S.Team_Name>
                          {homeAwayInfo?.away?.team?.name || 'NO_DATA'}
                        </S.Team_Name>
                      </S.Away>
                    </S.Team_Wrap>
                    <S.BetInfo_Wrap>
                      <S.Odds>
                        <S.Odds_Title>승무패</S.Odds_Title>
                        <S.Odds_Select>
                          <S.Select>
                            <S.OddInfo>Home</S.OddInfo>
                            <S.Odd>{oddData?.home}</S.Odd>
                          </S.Select>
                          <S.Select>
                            <S.OddInfo>Draw</S.OddInfo>
                            <S.Odd>{oddData?.draw}</S.Odd>
                          </S.Select>
                          <S.Select>
                            <S.OddInfo>Away</S.OddInfo>
                            <S.Odd>{oddData?.away}</S.Odd>
                          </S.Select>
                        </S.Odds_Select>
                      </S.Odds>
                      <S.Betting_Btn
                        isVariableOdd={isVariableOdd}
                        onClick={isVariableOdd ? goToBet : undefined}
                      >
                        배팅하기
                      </S.Betting_Btn>
                    </S.BetInfo_Wrap>
                  </S.BetCart_Body>
                </S.Betting_Cart>
              </S.LeftSide_Contents>
            </S.Left_Side>
            <PlayListInfo widget={false} />
          </S.Body>
          <S.Bottom id='info-section'>
            <S.Bottom_Section>
              <S.OverlayText>NEW SYSTEM</S.OverlayText>
              <S.DetailText $left='80px'>
                더 강력해진 안정성, 더 빨라진 응답 속도.
                <br /> 실시간 베팅에 최적화된 인프라로 새롭게 구축된 시스템을
                경험하세요.
              </S.DetailText>
              <S.Bottom_Img src='/banner_football.png' />
            </S.Bottom_Section>
            <S.Bottom_Section>
              <S.OverlayText>NEW GAMES</S.OverlayText>
              <S.DetailText $left='80px'>
                다양하고 새로운 종목들로 구성된 프리미엄 게임 라인업. 선택의
                다양성.
                <br />
                새로운 재미와 긴장감을 느껴보세요.
              </S.DetailText>
              <S.Bottom_Img src='/banner_baseball.png' />
            </S.Bottom_Section>
            <S.Bottom_Section>
              <S.OverlayText>NEW PLAN</S.OverlayText>
              <S.DetailText $left='80px'>
                보상률은 높이고 리스크는 낮춘, 새롭게 설계된 사용자 중심의 운영
                플랜.
                <br />
                배팅의 새로운 기준, 지금 확인해보세요.
              </S.DetailText>
              <S.Bottom_Img src='/banner_basketball.png' />
            </S.Bottom_Section>
          </S.Bottom>
        </S.Context>
      </S.Main>
    </>
  );
}
