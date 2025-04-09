import { useState } from 'react';
import * as S from './signupstyle';
import { validators } from '@/src/commons/validators/validator';
import { useModal } from '../modalprovider';

export default function SignUp() {
  const { closeModal } = useModal();

  const defaultVal = {
    emailId: '',
    nickName: '',
    password: '',
    passwordCheck: '',
    phoneNum: '',
    gender: '',
  };

  const checkValList = [
    'emailId',
    'nickName',
    'password',
    'passwordCheck',
    'phoneNum',
    'gender',
  ];

  const [signUpVal, setSignUpVal] = useState(defaultVal);

  const changeInputValue = (e) => {
    const { name, value } = e.target;
    setSignUpVal((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();

    for (const key of checkValList) {
      const validatorFunc = validators[key];
      const validateResult = validatorFunc(signUpVal[key], signUpVal);

      if (validateResult !== 'SUCCESS') {
        alert(validateResult);
        return;
      }

      // 모든 검증을 통과하였을 경우 이쪽으로
      if (key === 'gender') console.log('이제 api 요청 보내면 됨~~~');
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
            <S.Input name='emailId' onChange={changeInputValue} />
            <S.DoubleCheck type='button'>중복확인</S.DoubleCheck>
          </S.Input_Wrapper>
        </S.UserName>
        <S.NickName>
          <S.SubTitle>닉네임</S.SubTitle>
          <S.Input_Wrapper>
            <S.Input name='nickName' onChange={changeInputValue} />
            <S.DoubleCheck type='button'>중복확인</S.DoubleCheck>
          </S.Input_Wrapper>
        </S.NickName>
        <S.Password>
          <S.SubTitle>비밀번호</S.SubTitle>
          <S.Input_Wrapper>
            <S.Input
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
              name='passwordCheck'
              type='password'
              onChange={changeInputValue}
            />
          </S.Input_Wrapper>
        </S.Password>
        <S.Phone>
          <S.SubTitle>연락처</S.SubTitle>
          <S.Input_Wrapper>
            <S.Input name='phoneNum' onChange={changeInputValue} />
          </S.Input_Wrapper>
        </S.Phone>
        <S.Sex>
          <S.SubTitle>성별</S.SubTitle>
          <S.Radio_Wrapper>
            <S.RadioLabel>
              <S.HiddenRadio
                type='radio'
                name='gender'
                value='male'
                onChange={changeInputValue}
              />
              <S.RadioMark />
              <S.RadioText>남자</S.RadioText>
            </S.RadioLabel>
            <S.RadioLabel>
              <S.HiddenRadio
                type='radio'
                name='gender'
                value='female'
                onChange={changeInputValue}
              />
              <S.RadioMark />
              <S.RadioText>여자</S.RadioText>
            </S.RadioLabel>
          </S.Radio_Wrapper>
        </S.Sex>
        <S.SignUpBtn type='submit'>회원가입</S.SignUpBtn>
      </S.Contents>
    </S.Wrapper>
  );
}
