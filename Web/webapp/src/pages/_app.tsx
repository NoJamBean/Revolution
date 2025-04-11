import { Global } from '@emotion/react';
import type { AppProps } from 'next/app';
import globalStyle from '../styles/globalstyles';
import Layout from '../components/commons/layout/layout';
import { ModalProvider } from '../components/commons/modal/modalprovider';
import { MatchInfoProvider } from '../components/commons/oddwidget/widgetprovider';

export default function App({ Component, pageProps }: AppProps) {
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
