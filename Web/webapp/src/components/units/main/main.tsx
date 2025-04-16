import { useState } from 'react';
import * as S from './styles';
import Chat from '../tabsection/chat';
import PlayListInfo from '../../commons/playinfo/playinfolist';
import PlayWidget from '../../commons/oddwidget/widget';
import { useMatchInfo } from '../../commons/oddwidget/widgetprovider';
import { useRouter } from 'next/router';

export default function Main() {
  const [clickedTab, setClickedTab] = useState('info');
  const { homeAwayInfo, selectSport, matchId } = useMatchInfo();

  const router = useRouter();
  //   const [clickedPlay, setClickedPlay] = useState(0);

  const clickToggle = (e: any) => {
    if (e.target.id === clickedTab) return;
    setClickedTab(e.target.id);
  };

  const goToBet = () => {
    console.log(homeAwayInfo, 11);
    // console.log(router.query, router.asPath, 333);

    if (matchId === '') {
      alert('경기 선택하셈');
      return;
    }

    router.replace({
      pathname: '/bet',
      query: {
        id: matchId,
        sport: selectSport,
      },
    });
  };

  return (
    <>
      <S.Main>
        <S.Context>
          <S.Carousel>
            <img src='/banner.jpg' style={{ width: '100%' }} alt='carousel' />
          </S.Carousel>
          <S.Section_Title>LIVE SPORTS</S.Section_Title>
          <S.Body>
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
                              homeAwayInfo?.home?.team?.logo || '/banner.jpg'
                            }
                            onError={(e) => {
                              e.currentTarget.onerror = null;
                              e.currentTarget.src = '/banner.jpg';
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
                              homeAwayInfo?.away?.team?.logo || '/banner.jpg'
                            }
                            onError={(e) => {
                              e.currentTarget.onerror = null;
                              e.currentTarget.src = '/banner.jpg';
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
                            <S.OddInfo>1팀승</S.OddInfo>
                            <S.Odd>1.17</S.Odd>
                          </S.Select>
                          <S.Select>
                            <S.OddInfo>무승부</S.OddInfo>
                            <S.Odd>VS</S.Odd>
                          </S.Select>
                          <S.Select>
                            <S.OddInfo>2팀승</S.OddInfo>
                            <S.Odd>4.20</S.Odd>
                          </S.Select>
                        </S.Odds_Select>
                      </S.Odds>
                      <S.Betting_Btn onClick={goToBet}>배팅하기</S.Betting_Btn>
                    </S.BetInfo_Wrap>
                  </S.BetCart_Body>
                </S.Betting_Cart>
              </S.LeftSide_Contents>
            </S.Left_Side>
            <PlayListInfo widget={false} />
          </S.Body>
          <S.Bottom>여기는 그냥 광고나 아무 Data</S.Bottom>
        </S.Context>
      </S.Main>
    </>
  );
}
