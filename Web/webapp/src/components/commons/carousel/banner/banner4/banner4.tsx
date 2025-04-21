import * as S from './banner4style';

export default function SportsHealthADBanner() {
  return (
    <S.Wrapper>
      <S.Background />
      <S.TextBlock>
        <S.Title>PLAY SMART, BET FAIR.</S.Title>
        <S.Description>
          배팅 전문 사이트 <span>TOTORO</span>는 누구나 안심하고 즐길 수 있는,
          건전하고 책임감 있는 스포츠 베팅 문화를 만들어갑니다.
          <br /> 단순한 승패에 치우친 운영이 아닌, 올바른 게임을 지향하고
          있습니다.
        </S.Description>
      </S.TextBlock>
      <S.Character src='/carousel4.png' alt='sports kids' />
    </S.Wrapper>
  );
}
