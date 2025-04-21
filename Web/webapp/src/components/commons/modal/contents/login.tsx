import * as S from './loginstyle';
import SignUp from './signup';
import { useState } from 'react';
import { useModal } from '../modalprovider';
import axios from 'axios';
import { useAuthStore } from '@/src/commons/stores/authstore';
import { sendLog } from '@/src/commons/utils/sendlogs';

export default function Login() {
  const { closeModal, changeModalContent } = useModal();

  const [userMail, setUserMail] = useState('');
  const [password, setPassword] = useState('');

  // const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
  const hangelRegex = /[ㄱ-ㅎ가-힣]/;

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();

    if (userMail === '' || password === '') {
      alert('이름이나 비번 입력똑바로 하고 로그인해라');
      return;
    }

    if (hangelRegex.test(userMail)) {
      alert('아 마 한글말고 영어로 입력해라 마');
      return;
    }

    try {
      const result = await axios.post(
        `${process.env.NEXT_PUBLIC_BACKEND_API_ENDPOINT}/api/users/login`,
        {
          id: userMail,
          password: password,
        },
        {
          headers: { 'Content-type': 'application/json' },
        }
      );

      //
      //
      const loginBody = { id: userMail, password: password }; // 로그인 로그 기록 body data

      // 로그인 성공 시 로그기록
      if (result.status === 200) {
        await sendLog({
          eventSource: 'webapp.example.com',
          awsRegion: 'ap-northeast-2',
          eventTime: new Date().toISOString(),
          eventName: 'LoginSuccess',
          requestParameters: {
            httpMethod: 'POST',
            requestPath: '/api/users/login',
            queryString: JSON.stringify(loginBody),
            statusCode: result.status,
          },
          sourceIPAddress: '', // 서버에서 채움
          userAgent: '', // 서버에서 채움
        });
      }

      // 받아온 토큰 전역관리 state 저장
      const tokens = result?.data?.tokens;
      const { idToken } = tokens;

      const setToken = useAuthStore.getState().setToken;
      setToken(idToken);

      alert('환영합니다! 토토로 토토로');
      closeModal();
    } catch (error) {
      console.log(error);
      alert('로그인 실패!! 에러!!');

      return;
    }
  };

  return (
    <>
      <S.LoginMain>
        <S.CloseBtn onClick={closeModal}>X</S.CloseBtn>
        <S.LogoImgBox>
          <S.LogoImg src='/weblogo_v2.png' />
        </S.LogoImgBox>
        <S.Form onSubmit={handleSubmit}>
          <S.UserSection>
            <S.Title>Username</S.Title>
            <S.Input onChange={(e) => setUserMail(e.target.value)} />
          </S.UserSection>
          <S.UserSection>
            <S.Title>Password</S.Title>
            <S.Input
              type='password'
              onChange={(e) => setPassword(e.target.value)}
            />
          </S.UserSection>
          <S.ButtonWrap>
            <S.Button type='submit'>
              <span>LOG IN</span>
            </S.Button>
            <S.Button onClick={() => changeModalContent(SignUp)}>
              <span>SIGN UP</span>
            </S.Button>
          </S.ButtonWrap>
        </S.Form>
      </S.LoginMain>
    </>
  );
}
