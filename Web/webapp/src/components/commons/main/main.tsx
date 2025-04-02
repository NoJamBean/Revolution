import * as S from './styles';

export default function Main() {
  return (
    <>
      <S.Main>
        <S.Context>
          <S.Carousel>
            <img src='/banner.jpg' style={{ width: '100%' }} />
          </S.Carousel>
          <S.Body>
            <S.Left_Side>여기는 선택한 경기에 대한 상세 Data</S.Left_Side>
            <S.Right_Side>
              {new Array(6).fill(1).map((el) => (
                <S.PlayInfo>여기는 예정 경기 Data</S.PlayInfo>
              ))}
            </S.Right_Side>
          </S.Body>
          <S.Bottom>여기는 그냥 광고나 아무 Data</S.Bottom>
        </S.Context>
      </S.Main>
    </>
  );
}
