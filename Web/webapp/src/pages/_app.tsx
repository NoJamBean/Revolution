import { Global } from '@emotion/react';
import type { AppProps } from 'next/app';
import globalStyle from '../styles/globalstyles';

export default function App({ Component, pageProps }: AppProps) {
  return (
    <>
      <Global styles={globalStyle} />
      <Component {...pageProps} />
    </>
  );
}
