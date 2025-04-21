import BlockFallbackLimitAPI from '../blockfallback/blockfallback1';
import { useMatchInfo } from './widgetprovider';
import * as S from './widgetstyle';
import { useRouter } from 'next/router';

export default function PlayWidget({ isMain }: { isMain: boolean }) {
  const { homeAwayInfo, isLimit } = useMatchInfo();
  const router = useRouter();

  // console.log('데이터 체크용', homeAwayInfo);
  console.log('rerender check', homeAwayInfo);

  // 로고 쪽 hover 하면 화면 어두워지면서 해당 팀 승률 표시 (얻어온 data 기반 승률계산)
  return isLimit ? (
    <BlockFallbackLimitAPI
      height={450}
      isMainAndWidget={!router.asPath.includes('/bet')}
    />
  ) : (
    <S.Wrapper isMain={isMain}>
      <S.Info_Top>
        <S.Info_Top_Home>
          <S.Team_Logo
            isBet={router.asPath.includes('/bet')}
            src={homeAwayInfo?.home?.team?.logo || '/noimage.png'}
            onError={(e) => {
              e.currentTarget.onerror = null;
              e.currentTarget.src = '/noimage.png';
            }}
          />
        </S.Info_Top_Home>
        <S.Verses>VS</S.Verses>
        <S.Info_Top_Away>
          <S.Team_Logo
            isBet={router.asPath.includes('/bet')}
            src={homeAwayInfo?.away?.team?.logo || '/noimage.png'}
            onError={(e) => {
              e.currentTarget.onerror = null;
              e.currentTarget.src = '/noimage.png';
            }}
          />
        </S.Info_Top_Away>
      </S.Info_Top>
      <S.Info_Body isMain={isMain}>
        <S.HomeInfo>
          <S.Team_Title className='first'>
            <S.Team_Title_Logo
              src={homeAwayInfo?.home?.team?.logo || '/noimage.png'}
              onError={(e) => {
                e.currentTarget.onerror = null;
                e.currentTarget.src = '/noimage.png';
              }}
            />
            <S.Team_Title_Name>
              {homeAwayInfo?.home?.team?.name}
            </S.Team_Title_Name>
          </S.Team_Title>
          <S.Info_Section_Title>TEAM INFO</S.Info_Section_Title>
          <S.Info_Section>
            <S.Section_Left>리그</S.Section_Left>
            <S.Section_Right>
              <S.Section_Right_Img
                src={homeAwayInfo.home?.league?.logo || '/noimage.png'}
                onError={(e) => {
                  e.currentTarget.onerror = null;
                  e.currentTarget.src = '/noimage.png';
                }}
              />
              <span>{homeAwayInfo.home?.league?.name || 'NO_DATA'}</span>
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section>
            <S.Section_Left>국가</S.Section_Left>
            <S.Section_Right>
              <S.Section_Right_Img
                src={homeAwayInfo.home?.league?.flag || '/noimage.png'}
                onError={(e) => {
                  e.currentTarget.onerror = null;
                  e.currentTarget.src = '/noimage.png';
                }}
              />
              <span>{homeAwayInfo.home?.league?.country || 'NO_DATA'}</span>
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section>
            <S.Section_Left>경기 수</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.home?.info?.total ?? 0}
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section_Title>{`TEAM DETAILS (WIN)`}</S.Info_Section_Title>
          <S.Info_Section>
            <S.Section_Left>총 승리</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.home?.info?.win ?? 0}
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section>
            <S.Section_Left>{`승리 (홈)`}</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.home?.info?.winhome ?? 0}
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section>
            <S.Section_Left>{`승리 (어웨이)`}</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.home?.info?.winaway ?? 0}
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section_Title>{`TEAM DETAILS (LOSE)`}</S.Info_Section_Title>
          <S.Info_Section>
            <S.Section_Left>총 패배</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.home?.info?.loses ?? 0}
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section>
            <S.Section_Left>{`패배 (홈)`}</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.home?.info.loseshome ?? 0}
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section>
            <S.Section_Left>{`패배 (어웨이)`}</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.home?.info?.losesaway ?? 0}
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section_Title>{`SCORE AVERAGE(WIN)`}</S.Info_Section_Title>
          <S.Info_Section>
            <S.Section_Left>{`평균득점 (전체)`}</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.home?.info?.fortotal ?? 0}
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section>
            <S.Section_Left>{`평균득점 (홈)`}</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.home?.info?.forhome ?? 0}
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section>
            <S.Section_Left>{`평균득점 (어웨이)`}</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.home?.info?.foraway ?? 0}
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section_Title>{`SCORE AVERAGE(LOSE)`}</S.Info_Section_Title>
          <S.Info_Section>
            <S.Section_Left>{`평균실점 (전체)`}</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.home?.info?.againsttotal ?? 0}
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section>
            <S.Section_Left>{`평균실점 (홈)`}</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.home?.info?.againsthome ?? 0}
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section>
            <S.Section_Left>{`평균실점 (어웨이)`}</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.home?.info?.againstaway ?? 0}
            </S.Section_Right>
          </S.Info_Section>
        </S.HomeInfo>
        {!isMain && <S.DivdedTag></S.DivdedTag>}
        <S.AwayInfo isMain={isMain}>
          <S.Team_Title className='second'>
            <S.Team_Title_Logo
              src={homeAwayInfo?.away?.team?.logo || '/noimage.png'}
              onError={(e) => {
                e.currentTarget.onerror = null;
                e.currentTarget.src = '/noimage.png';
              }}
            />
            <S.Team_Title_Name>
              {homeAwayInfo?.away?.team?.name || 'NO_DATA'}
            </S.Team_Title_Name>
          </S.Team_Title>
          <S.Info_Section_Title>TEAM INFO</S.Info_Section_Title>
          <S.Info_Section>
            <S.Section_Left>리그</S.Section_Left>
            <S.Section_Right>
              <S.Section_Right_Img
                src={homeAwayInfo?.away?.league.logo || '/noimage.png'}
                onError={(e) => {
                  e.currentTarget.onerror = null;
                  e.currentTarget.src = '/noimage.png';
                }}
              />
              <span>{homeAwayInfo?.away?.league.name ?? 'NO_DATA'}</span>
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section>
            <S.Section_Left>국가</S.Section_Left>
            <S.Section_Right>
              <S.Section_Right_Img
                src={homeAwayInfo.away?.league.flag || '/noimage.png'}
                onError={(e) => {
                  e.currentTarget.onerror = null;
                  e.currentTarget.src = '/noimage.png';
                }}
              />
              <span>{homeAwayInfo.away?.league.country || 'NO_DATA'}</span>
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section>
            <S.Section_Left>경기 수</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.away?.info?.total ?? 0}
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section_Title>{`TEAM DETAILS (WIN)`}</S.Info_Section_Title>
          <S.Info_Section>
            <S.Section_Left>총 승리</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.away?.info?.win ?? 0}
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section>
            <S.Section_Left>{`승리 (홈)`}</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.away?.info?.winhome ?? 0}
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section>
            <S.Section_Left>{`승리 (어웨이)`}</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.away?.info?.winaway ?? 0}
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section_Title>{`TEAM DETAILS (LOSE)`}</S.Info_Section_Title>
          <S.Info_Section>
            <S.Section_Left>총 패배</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.away?.info?.loses ?? 0}
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section>
            <S.Section_Left>{`패배 (홈)`}</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.away?.info?.loseshome ?? 0}
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section>
            <S.Section_Left>{`패배 (어웨이)`}</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.away?.info?.losesaway ?? 0}
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section_Title>{`SCORE AVERAGE(WIN)`}</S.Info_Section_Title>
          <S.Info_Section>
            <S.Section_Left>{`평균득점 (전체)`}</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.away?.info?.fortotal ?? 0}
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section>
            <S.Section_Left>{`평균득점 (홈)`}</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.away?.info?.forhome ?? 0}
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section>
            <S.Section_Left>{`평균득점 (어웨이)`}</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.away?.info?.foraway ?? 0}
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section_Title>{`SCORE AVERAGE(LOSE)`}</S.Info_Section_Title>
          <S.Info_Section>
            <S.Section_Left>{`평균실점 (전체)`}</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.away?.info?.againsttotal ?? 0}
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section>
            <S.Section_Left>{`평균실점 (홈)`}</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.away?.info?.againsthome ?? 0}
            </S.Section_Right>
          </S.Info_Section>
          <S.Info_Section>
            <S.Section_Left>{`평균실점 (어웨이)`}</S.Section_Left>
            <S.Section_Right>
              {homeAwayInfo.away?.info?.againstaway ?? 0}
            </S.Section_Right>
          </S.Info_Section>
        </S.AwayInfo>
      </S.Info_Body>
    </S.Wrapper>
  );
}
