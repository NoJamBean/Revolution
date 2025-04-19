import { Global } from '@emotion/react';
import type { AppProps } from 'next/app';
import globalStyle from '../styles/globalstyles';
import Layout from '../components/commons/layout/layout';
import { ModalProvider } from '../components/commons/modal/modalprovider';
import { MatchInfoProvider } from '../components/commons/oddwidget/widgetprovider';

// layout.tsx 또는 entrypoint에 추가
import '@fortawesome/fontawesome-svg-core/styles.css';
import { config } from '@fortawesome/fontawesome-svg-core';
import { useAuthStore } from '../commons/stores/authstore';
import { useEffect } from 'react';
import { sendLog } from '../commons/utils/sendlogs';
import { useRouter } from 'next/router';
import {
  getBaseballlMatchList,
  getBasketballMatchList,
  getFootballMatchList,
  getHandBallMatchList,
  getIceHockeyMatchList,
} from '../api/getdefaulmatchlist';
config.autoAddCss = false;

export default function App({ Component, pageProps }: AppProps) {
  const router = useRouter();

  const setToken = useAuthStore((state) => state.setToken);

  useEffect(() => {
    //
    // 매 페이지 refresh마다 저장된 토큰 값 전역관리 변수에 저장
    const loginToken = localStorage.getItem('auth_token'); // 로그인 관련 토큰 실시간 check (구현예정)

    if (loginToken) {
      setToken(loginToken);
    }

    //
    //
    // 매 페이지 이동 시 로그 기록
    console.log('라우팅이 다시 또 트리거됩니다요오오오오오오옹');

    const fullUrl = window.location.pathname + window.location.search;

    if ((window as any).__lastLoggedUrl === fullUrl) return;
    (window as any).__lastLoggedUrl = fullUrl;

    const handlePageVisit = (url: string) => {
      const query = new URLSearchParams(window.location.search).toString();
      const requestParameters = {
        httpMethod: 'GET',
        requestPath: url,
        queryString: query,
        statusCode: 200,
      };

      sendLog({
        eventSource: 'webapp.example.com',
        awsRegion: 'ap-northeast-2',
        eventTime: new Date().toISOString(),
        eventName: 'PageRouting',
        requestParameters,
        sourceIPAddress: '',
        userAgent: '',
      });
    };

    handlePageVisit(router.asPath); // 초기 렌더링 시

    router.events.on('routeChangeComplete', handlePageVisit);

    return () => {
      router.events.off('routeChangeComplete', handlePageVisit);
    };
  }, [router]);

  useEffect(() => {
    try {
      const storedData = localStorage.getItem('sportscount');
      const storedDate = localStorage.getItem('sportscount_saved_date');

      const now = new Date();

      // 한국 표준시 기준 날짜 구하기 (UTC+9)
      const nowInKST = new Date(now.getTime() + 9 * 60 * 60 * 1000);
      const todayString = nowInKST.toISOString().split('T')[0]; // 'YYYY-MM-DD'

      // 이미 저장된 상태일 경우 return
      if (storedData && storedDate === todayString) return;

      if (!storedData || !storedDate || storedDate !== todayString) {
        const getAllSportsMatchCount = async () => {
          const footballcount = await getFootballMatchList();
          const baseballcount = await getBaseballlMatchList();
          const basketballcount = await getBasketballMatchList();
          const icehockeycount = await getIceHockeyMatchList();
          const handballcount = await getHandBallMatchList();

          const resultArray = [
            { sport: 'FOOTBALL', count: footballcount.length },
            { sport: 'BASEBALL', count: baseballcount.length },
            { sport: 'BASKETBALL', count: basketballcount.length },
            { sport: 'ICEHOCKEY', count: icehockeycount.length },
            { sport: 'HANDBALL', count: handballcount.length },
          ];

          localStorage.setItem('sportscount', JSON.stringify(resultArray));
          localStorage.setItem('sportscount_saved_date', todayString);
        };

        getAllSportsMatchCount();
      }
    } catch (error) {
      console.log(error);
    }
  }, []);

  return (
    <>
      <Global styles={globalStyle} />
      <ModalProvider>
        <MatchInfoProvider>
          <Layout>
            <Component {...pageProps} />
          </Layout>
        </MatchInfoProvider>
      </ModalProvider>
    </>
  );
}
