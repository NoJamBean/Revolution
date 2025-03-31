import * as S from './styles';

export default function Header() {
  return (
    <S.Wrapper>
      <S.LogoImg>
        <img src='/logo.jpg' style={{ width: '100%', height: '100%' }} />
      </S.LogoImg>
      <S.Bar>
        <S.Menu>
          <S.MenuLink href={'/'}>게임구매</S.MenuLink>
        </S.Menu>
        <S.Menu>
          <S.MenuLink href={'/'}>경기정보</S.MenuLink>
        </S.Menu>
        <S.Menu>
          <S.MenuLink href={'/'}>토토카페</S.MenuLink>
        </S.Menu>
        <S.Menu>
          <S.MenuLink href={'/'}>건전토토</S.MenuLink>
        </S.Menu>
        <S.Menu>
          <S.MenuLink href={'/'}>고객센터</S.MenuLink>
        </S.Menu>
        <S.Sign_Container>
          <S.SignIn>로그인</S.SignIn>
          <S.SignUp>회원가입</S.SignUp>
        </S.Sign_Container>
      </S.Bar>
    </S.Wrapper>
  );
}
