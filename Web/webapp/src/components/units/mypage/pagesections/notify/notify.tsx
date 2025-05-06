import * as S from './notifystyle';

export default function Notify() {
  return (
    <S.InfoWrapper>
      <S.Info_Top>수신함</S.Info_Top>
      <S.Info_Body>
        <S.Edit_Btn>알림확인</S.Edit_Btn>
      </S.Info_Body>
    </S.InfoWrapper>
  );
}
