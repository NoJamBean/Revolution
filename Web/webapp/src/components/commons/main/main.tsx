import * as S from './styles';

export default function Main() {
  return (
    <>
      <S.Main>
        <S.Left_Side></S.Left_Side>
        <S.Context>
          <S.Carousel>
            <img src='/banner.jpg' style={{ width: '100%' }} />
          </S.Carousel>
          <S.WeeklyMatch></S.WeeklyMatch>
          <S.ProtoInfo></S.ProtoInfo>
        </S.Context>
        <S.Right_Side></S.Right_Side>
      </S.Main>
    </>
  );
}
