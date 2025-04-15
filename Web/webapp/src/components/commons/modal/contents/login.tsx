import { useState } from 'react';
import { useModal } from '../modalprovider';
import * as S from './loginstyle';

import SignUp from './signup';

export default function Login() {
  const { closeModal, changeModalContent } = useModal();

  const [userMail, setUserMail] = useState('');
  const [password, setPassword] = useState('');

  const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
  const hangelRegex = /[ㄱ-ㅎ가-힣]/;

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();

    if (userMail === '' || password === '') {
      alert('이름이나 비번 입력똑바로 하고 로그인해라잉');
      return;
    }

    if (!emailRegex.test(userMail)) {
      alert('이메일 형식에 맞게 입력해라');
      return;
    }

    if (hangelRegex.test(userMail)) {
      alert('아 마 한글말고 영어로 입력해라 마');
      return;
    }

    // 모든 검증 통과시 이쪽으로
    console.log('~이제 API로 요청 보내면 됨~~~');
  };

  return (
    <>
      <S.LoginMain>
        <S.CloseBtn onClick={closeModal}>X</S.CloseBtn>
        <S.Logo>존나좋은 토토사이트</S.Logo>
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
            <S.Button type='submit'>LOGIN</S.Button>
            <S.Button onClick={() => changeModalContent(SignUp)}>
              SIGN UP
            </S.Button>
          </S.ButtonWrap>
        </S.Form>
      </S.LoginMain>
    </>
  );
}
