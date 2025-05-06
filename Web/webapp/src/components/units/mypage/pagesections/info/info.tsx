import { userDataProps } from '../../mypages';
import * as S from './infostyle';

interface InfoProps {
  userData?: userDataProps;
}

export default function Info({ userData }: InfoProps) {
  console.log(userData, 33333);

  return (
    <S.InfoWrapper>
      <S.Info_Top>내 정보</S.Info_Top>
      <S.Info_Body>
        <S.Info_Section_Line>
          <S.Info>
            <span>ID</span>
            <span>{userData?.id}</span>
          </S.Info>
          <S.Info>
            <span>닉네임</span>
            <span>{userData?.nickname}</span>
          </S.Info>
        </S.Info_Section_Line>
        <S.Info_Section_Line>
          <S.Info>
            <span>E-MAIL</span>
            <span>{userData?.email}</span>
          </S.Info>
          <S.Info>
            <span>연락처</span>
            <span>{userData?.phoneNumber}</span>
          </S.Info>
        </S.Info_Section_Line>
        <S.Info_Section_Line>
          <S.Info>
            <span>보유 포인트</span>
            <span>{userData?.balance}</span>
          </S.Info>
          <S.Info></S.Info>
        </S.Info_Section_Line>
        <S.Edit_Btn>수정하기</S.Edit_Btn>
      </S.Info_Body>
    </S.InfoWrapper>
  );
}
