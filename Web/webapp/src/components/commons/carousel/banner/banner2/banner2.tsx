import * as S from './banner2style';

export default function SportsBanner() {
  return (
    <S.BannerWrapper>
      <S.BannerText>
        <S.Title>
          더 이상 기다리지 마세요!
          <br />
          2025 상반기 신규 종목 업데이트!
        </S.Title>
        <S.Description>
          신규 종목 하키, 핸드볼 추가
          <br />더 다양해진 종목을 선택하고 지금 바로 시작하세요.
        </S.Description>
      </S.BannerText>
      <S.BannerFigure />
    </S.BannerWrapper>
  );
}
