import * as S from './infostyle';

export default function Info() {
  return (
    <S.InfoWrapper>
      <S.Info_Top>내 정보</S.Info_Top>
      <S.Info_Body>
        <S.Info_Section_Line>
          <S.Info>
            <span>이름</span>
            <span>송현섭</span>
          </S.Info>
          <S.Info>
            <span>닉네임</span>
            <span>Songseop</span>
          </S.Info>
        </S.Info_Section_Line>
        <S.Info_Section_Line>
          <S.Info>
            <span>E-MAIL</span>
            <span>manner9945@naver.com</span>
          </S.Info>
          <S.Info>
            <span>연락처</span>
            <span>010-9945-5352</span>
          </S.Info>
        </S.Info_Section_Line>
        <S.Info_Section_Line>
          <S.Info>
            <span>보유 포인트</span>
            <span>10000</span>
          </S.Info>
          <S.Info></S.Info>
        </S.Info_Section_Line>
        <S.Edit_Btn>수정하기</S.Edit_Btn>
      </S.Info_Body>
    </S.InfoWrapper>
  );
}
