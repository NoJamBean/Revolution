import { Global } from '@emotion/react';
import type { AppProps } from 'next/app';
import globalStyle from '../styles/globalstyles';
import Layout from '../components/commons/layout/layout';

export default function App({ Component, pageProps }: AppProps) {
  return (
    <>
      <Global styles={globalStyle} />
      <Layout>
        <Component {...pageProps} />
      </Layout>
    </>
  );
}
