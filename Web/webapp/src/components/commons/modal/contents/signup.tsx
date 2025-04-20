import { useState } from 'react';
import * as S from './signupstyle';
import { validators } from '@/src/commons/validators/validator';
import { useModal } from '../modalprovider';
import axios from 'axios';
import { useRouter } from 'next/router';
import { sendLog } from '@/src/commons/utils/sendlogs';

type SignUpVal = {
  id: string;
  nickname: string;
  email: string;
  emailauth: string;
  password: string;
  passwordCheck: string;
  phoneNum: string;
};

type SignUpKey = keyof SignUpVal;

export default function SignUp() {
  const [isReqed, setIsRequed] = useState(false);

  const router = useRouter();
  const { closeModal } = useModal();

  const defaultVal: SignUpVal = {
    id: '',
    nickname: '',
    email: '',
    emailauth: '',
    password: '',
    passwordCheck: '',
    phoneNum: '',
  };

  const checkValList = [
    'id',
    'nickname',
    'email',
    'emailauth',
    'password',
    'passwordCheck',
    'phoneNum',
  ];

  const [signUpVal, setSignUpVal] = useState(defaultVal);

  const changeInputValue = (e: any) => {
    const { name, value } = e.target;
    setSignUpVal((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e: any) => {
    e.preventDefault();

    for (const key of checkValList as SignUpKey[]) {
      const validatorFunc = validators[key];
      const validateResult = validatorFunc(signUpVal[key], signUpVal);

      if (validateResult !== 'SUCCESS') {
        alert(validateResult);
        return;
      }
    }

    const { id, password, email, nickname, phoneNum } = signUpVal;

    try {
      const result = await axios.post(
        `${process.env.NEXT_PUBLIC_BACKEND_API_ENDPOINT}/api/users/register/confirm`,
        {
          id: id,
          password: password,
          email: email,
          nickname: nickname,
          phoneNumber: phoneNum,
          balance: 0,
        },
        {
          headers: { 'Content-type': 'application/json' },
        }
      );

      // 회원가입 성공 시 로그기록
      if (result.status === 200) {
        await sendLog({
          eventSource: 'webapp.example.com',
          awsRegion: 'ap-northeast-2',
          eventTime: new Date().toISOString(),
          eventName: 'SignupSuccess',
          requestParameters: {
            httpMethod: 'POST',
            requestPath: '/api/users/register/confirm',
            queryString: '',
            statusCode: result.status,
          },
          sourceIPAddress: '',
          userAgent: '',
        });
      }

      console.log(result, '회원가입 성공');

      closeModal();
      router.push('/');
    } catch (error) {
      console.log(error);
    }

    // 모든 검증을 통과하였을 경우 이쪽으로
    // signUp(email, password, nickname);
  };

  const requestEmailCode = async () => {
    // console.log('email 코드 전송임');
    for (const key of checkValList as SignUpKey[]) {
      const validatorFunc = validators[key];
      const validateResult = validatorFunc(signUpVal[key], signUpVal);

      console.log(validateResult, '결과물');
      console.log(key, key === 'emailauth', 1231231);

      if (String(key) !== 'emailauth' && validateResult !== 'SUCCESS') {
        alert('모든 정보를 기입해주세요');
        return;
      }
    }

    const { id, password, email, nickname, phoneNum } = signUpVal;

    try {
      const result = await axios.post(
        `${process.env.NEXT_PUBLIC_BACKEND_API_ENDPOINT}/api/users/register`,
        {
          id: id,
          password: password,
          email: email,
          nickname: nickname,
          phoneNumber: phoneNum,
          balance: 0,
        },
        {
          headers: { 'Content-type': 'application/json' },
        }
      );

      // 이메일 인증코드 요청 시 로그 기록
      if (result.status === 200) {
        await sendLog({
          eventSource: 'webapp.example.com',
          awsRegion: 'ap-northeast-2',
          eventTime: new Date().toISOString(),
          eventName: 'RequestEmailVerification',
          requestParameters: {
            httpMethod: 'POST',
            requestPath: '/api/users/register',
            queryString: '',
            statusCode: result.status,
          },
          sourceIPAddress: '',
          userAgent: '',
        });
      }

      alert('이메일 요청 전송완료');
      setIsRequed(true);
    } catch (error) {
      console.log(error, 'error~~!!');
    }
  };

  const requestEmailAuth = async () => {
    // console.log('email 코드 전송임');
    if (!isReqed) {
      alert('이메일 인증 요청을 완료해주세요');
      return;
    }

    for (const key of checkValList as SignUpKey[]) {
      const validatorFunc = validators[key];
      const validateResult = validatorFunc(signUpVal[key], signUpVal);

      if (validateResult !== 'SUCCESS') {
        if (key === 'emailauth') {
          alert('인증코드를 입력하세요');
          return;
        }

        alert('모든 정보를 기입해주세요');
        return;
      }
    }

    const { id, emailauth } = signUpVal;

    try {
      const result = await axios.post(
        `${process.env.NEXT_PUBLIC_BACKEND_API_ENDPOINT}/api/users/register/validate`,
        {
          id: id,
          code: emailauth,
        },
        {
          headers: { 'Content-type': 'application/json' },
        }
      );

      // 이메일 인증코드 입력 및 전송시 로그 기록
      if (result.status === 200) {
        await sendLog({
          eventSource: 'webapp.example.com',
          awsRegion: 'ap-northeast-2',
          eventTime: new Date().toISOString(),
          eventName: 'VerifyEmailCode',
          requestParameters: {
            httpMethod: 'POST',
            requestPath: '/api/users/register/validate',
            queryString: '',
            statusCode: result.status,
          },
          sourceIPAddress: '',
          userAgent: '',
        });
      }

      alert('인증이 완료되었습니다');
      setIsRequed(false);
    } catch (error) {
      console.log(error, 'error~~!!');
    }
  };

  return (
    <S.Wrapper>
      <S.Contents onSubmit={handleSubmit}>
        <S.Title>
          <S.Title_Text>회원가입</S.Title_Text>
          <S.CloseBtn onClick={closeModal}>X</S.CloseBtn>
        </S.Title>
        <S.UserName>
          <S.SubTitle>아이디</S.SubTitle>
          <S.Input_Wrapper>
            <S.Input isReq={false} name='id' onChange={changeInputValue} />
            <S.DoubleCheck type='button'>중복확인</S.DoubleCheck>
          </S.Input_Wrapper>
        </S.UserName>
        <S.NickName>
          <S.SubTitle>닉네임</S.SubTitle>
          <S.Input_Wrapper>
            <S.Input
              isReq={false}
              name='nickname'
              onChange={changeInputValue}
            />
            <S.DoubleCheck type='button'>중복확인</S.DoubleCheck>
          </S.Input_Wrapper>
        </S.NickName>
        <S.Email>
          <S.SubTitle>E-MAIL</S.SubTitle>
          <S.Input_Wrapper>
            <S.Input isReq={false} name='email' onChange={changeInputValue} />
            <S.EmailReqBtn type='button' onClick={requestEmailCode}>
              발급요청
            </S.EmailReqBtn>
            <S.Email_Input_Wrapper>
              <S.Input
                isReq={true}
                name='emailauth'
                onChange={changeInputValue}
              />
              <S.EmailChkBtn type='button' onClick={requestEmailAuth}>
                인증요청
              </S.EmailChkBtn>
            </S.Email_Input_Wrapper>
          </S.Input_Wrapper>
        </S.Email>
        <S.Password>
          <S.SubTitle>비밀번호</S.SubTitle>
          <S.Input_Wrapper>
            <S.Input
              isReq={false}
              name='password'
              type='password'
              onChange={changeInputValue}
            />
          </S.Input_Wrapper>
        </S.Password>
        <S.Password>
          <S.SubTitle>비밀번호 확인</S.SubTitle>
          <S.Input_Wrapper>
            <S.Input
              isReq={false}
              name='passwordCheck'
              type='password'
              onChange={changeInputValue}
            />
          </S.Input_Wrapper>
        </S.Password>
        <S.Phone>
          <S.SubTitle>연락처</S.SubTitle>
          <S.Input_Wrapper>
            <S.Input
              isReq={false}
              name='phoneNum'
              onChange={changeInputValue}
            />
          </S.Input_Wrapper>
        </S.Phone>
        <S.SignUpBtn type='submit'>SIGN UP</S.SignUpBtn>
      </S.Contents>
    </S.Wrapper>
  );
}
