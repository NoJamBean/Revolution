import * as S from './loadingstyle';

export default function Loading() {
  return (
    <S.Wrapper>
      <S.LoadingContent>
        <S.Loading_Context>로딩중...</S.Loading_Context>
        <S.ImgBox>
          <S.Loading_Img src='/maload.gif' />
        </S.ImgBox>
        <S.Loading_Context>잠시만 기다려주세요</S.Loading_Context>
      </S.LoadingContent>
      //{' '}
    </S.Wrapper>
  );
}
