import { useModal } from '../../modal/modalprovider';
import Login from '../../modal/contents/login';
import * as S from './styles';
import SignUp from '../../modal/contents/signup';
import { useMatchInfo } from '../../oddwidget/widgetprovider';

export default function Header() {
  const { openModal } = useModal();
  const { selectSport } = useMatchInfo();

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
          <S.MenuLink
            href={{ pathname: '/bet', query: { sport: selectSport } }}
          >
            BET GAME
          </S.MenuLink>
        </S.Menu>
        <S.Menu>
          <S.MenuLink href={'/test'}>FAQ</S.MenuLink>
        </S.Menu>
        <S.Menu>
          <S.MenuLink href={'/'}>MY PAGE</S.MenuLink>
        </S.Menu>
        <S.Sign_Container>
          <S.SignIn onClick={() => openModal(Login)}>로그인</S.SignIn>
          <S.SignUp onClick={() => openModal(SignUp)}>회원가입</S.SignUp>
        </S.Sign_Container>
      </S.Bar>
    </S.Wrapper>
  );
}
