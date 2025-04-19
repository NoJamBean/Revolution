import { useModal } from '../../modal/modalprovider';
import Login from '../../modal/contents/login';
import * as S from './styles';
import SignUp from '../../modal/contents/signup';
import { useMatchInfo } from '../../oddwidget/widgetprovider';
import { useAuthStore } from '@/src/commons/stores/authstore';
import { sendLog } from '@/src/commons/utils/sendlogs';
import { useRouter } from 'next/router';

export default function Header() {
  const router = useRouter();

  const { openModal } = useModal();
  const { selectSport } = useMatchInfo();

  const userToken = useAuthStore((state) => state.token);

  const logout = async () => {
    if (userToken) {
      await setLogOUtLog(userToken);

      localStorage.removeItem('auth_token');
      useAuthStore.getState().clearToken();
      alert('로그아웃 되었습니다');
    }
  };

  const clickLogo = () => {
    router.push('/');
  };

  const scrollToSportInfo = () => {
    const sportInfo = document.getElementById('info-sport-section');
    if (sportInfo) sportInfo?.scrollIntoView({ behavior: 'smooth' });
  };

  const scrollToBottom = () => {
    const bottom = document.getElementById('info-section');
    if (bottom) bottom?.scrollIntoView({ behavior: 'smooth' });
  };

  const setLogOUtLog = async (userToken: string) => {
    if (userToken) {
      await sendLog({
        eventSource: 'webapp.example.com',
        awsRegion: 'ap-northeast-2',
        eventTime: new Date().toISOString(),
        eventName: 'LogOutSuccess',
        requestParameters: {
          httpMethod: 'GET',
          requestPath: '/',
          queryString: '',
          statusCode: 200,
        },
        sourceIPAddress: '',
        userAgent: '',
      });
    }
  };

  return (
    <S.Wrapper>
      <S.LogoImgWrap onClick={clickLogo}>
        <S.LogoImg src='/weblogo_v1.png' alt='logo image' />
      </S.LogoImgWrap>
      <S.Bar>
        <S.Menu_Bar>
          <S.Menu>
            <S.MenuLink
              href='/'
              onClick={(e) => {
                e.preventDefault();
                scrollToSportInfo();
              }}
            >
              SPORTS
            </S.MenuLink>
          </S.Menu>
          <S.Menu>
            <S.MenuLink
              href='/'
              onClick={(e) => {
                e.preventDefault();
                scrollToBottom();
              }}
            >
              INFO
            </S.MenuLink>
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
            <S.MenuLink href={'/'}>MY PAGE</S.MenuLink>
          </S.Menu>
        </S.Menu_Bar>
        {userToken ? (
          <S.LogIn_User_Container>
            <span>로그인완료</span>
            <S.LogOut onClick={logout}>로그아웃</S.LogOut>
          </S.LogIn_User_Container>
        ) : (
          <S.Sign_Container>
            <S.SignIn onClick={() => openModal(Login)}>SIGN_IN</S.SignIn>
            <S.SignUp onClick={() => openModal(SignUp)}>SIGN_UP</S.SignUp>
          </S.Sign_Container>
        )}
      </S.Bar>
    </S.Wrapper>
  );
}
