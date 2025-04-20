import * as S from './bettingstyle';

export default function MyBetList() {
  return (
    <S.InfoWrapper>
      <S.Info_Top>배팅 내역</S.Info_Top>
      <S.Info_Body>
        {new Array(8).fill(1).map((_, idx) => (
          <S.Bet_InfoBlock key={idx}>
            <S.SelectSport>
              <S.Sport_Img src='/baseball_ball.png' />
            </S.SelectSport>
            <S.Bet_Contents>
              <S.MyBet>
                <span>MY BETS</span>
                <span>₩19000</span>
              </S.MyBet>
              <S.Expected>
                <span>EXPECTED</span>
                <span>₩22500</span>
              </S.Expected>
              <S.Match_Detail>
                <S.Match_Date>
                  <span>2024-04-20</span>
                  <S.Status_Light></S.Status_Light>
                </S.Match_Date>
                <S.Games>
                  <span>GAMES</span>
                </S.Games>
                <S.HomeandAway>
                  <S.MatchTeams>
                    <span>LA DNS</span>
                    <span>VS</span>
                    <span>LA NAT</span>
                  </S.MatchTeams>
                </S.HomeandAway>
                <S.Game_Status>Finished</S.Game_Status>
              </S.Match_Detail>
            </S.Bet_Contents>
          </S.Bet_InfoBlock>
        ))}
      </S.Info_Body>
    </S.InfoWrapper>
  );
}
