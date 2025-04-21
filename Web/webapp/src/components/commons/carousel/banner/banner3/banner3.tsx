import * as S from './banner3style';

export default function SportsNewADBanner() {
  return (
    <S.Wrapper>
      <S.AthleteImg src='/carousel1.png' alt='athletes' />
      <S.TextBlock>
        <S.Title>UPCOMING NEW SPORT</S.Title>
        <S.DateText>5월 30일 배구종목 추가 예정</S.DateText>
        <S.Description>
          지난 시즌 핸드볼 종목 영입에 힘입어 올 5월, 새롭게 배구종목이
          런칭됩니다!
          <br />
          공식 출시 전 사전 배팅을 경험해 볼 수 있는 이벤트 진행중!
        </S.Description>
      </S.TextBlock>
    </S.Wrapper>
  );
}
