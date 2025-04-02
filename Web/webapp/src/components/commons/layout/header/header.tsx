import { useModal } from '../../modal/modalprovider';
import * as S from './styles';

export default function Header() {
  const { openModal } = useModal();

  return (
    <S.Wrapper>
      <S.LogoImg>
        <img
          src='/logo.jpg'
          style={{ width: '100%', height: '100%' }}
          alt='logo image'
        />
      </S.LogoImg>
      <S.Bar>
        <S.Menu>
          <S.MenuLink href={'/'}>SPORTS</S.MenuLink>
        </S.Menu>
        <S.Menu>
          <S.MenuLink href={'/'}>MINI GAME</S.MenuLink>
        </S.Menu>
        <S.Menu>
          <S.MenuLink href={'/'}>BET GAME</S.MenuLink>
        </S.Menu>
        <S.Menu>
          <S.MenuLink href={'/'}>FAQ</S.MenuLink>
        </S.Menu>
        <S.Menu>
          <S.MenuLink href={'/'}>MY PAGE</S.MenuLink>
        </S.Menu>
        <S.Sign_Container>
          <S.SignIn onClick={() => openModal(<div>Hello World</div>)}>
            로그인
          </S.SignIn>
          <S.SignUp>회원가입</S.SignUp>
        </S.Sign_Container>
      </S.Bar>
    </S.Wrapper>
  );
}
