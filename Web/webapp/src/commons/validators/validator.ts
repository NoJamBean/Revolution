const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

const passwordRegex =
  /^(?=.*[A-Z])(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]).{8,}$/;

const sixDigitCodeRegex = /^\d{6}$/;

export const validators = {
  id: (val: any) => {
    if (val?.trim() === '') return 'ID를 입력해주세요';
    return 'SUCCESS';
  },
  nickname: (val: any) => {
    if (val?.trim() === '') return '닉네임을 입력해주세요';
    if (val.length < 3) return '닉네임은 최소 3자 이상이어야 합니다';

    return 'SUCCESS';
  },
  email: (val: any) => {
    if (val?.trim() === '') return '이메일을 입력해주세요';
    if (!emailRegex.test(val)) return '올바른 이메일 형식이 아닙니다';
    return 'SUCCESS';
  },

  emailauth: (val: any) => {
    if (val?.trim() === '') return '이메일 요청 코드를 입력해주세요';
    if (!sixDigitCodeRegex.test(val)) return '인증번호는 6자리 숫자여야 합니다';
    return 'SUCCESS';
  },

  password: (val: any) => {
    if (val?.trim() === '') return '비밀번호를 입력해주세요';
    if (!passwordRegex.test(val)) {
      return '영문, 숫자, 특수기호 포함 8자 이상으로 입력해주세요';
    }

    return 'SUCCESS';
  },

  passwordCheck: (val: any, signUpVal: any) => {
    if (val?.trim() === '') return '비밀번호를 입력해주세요';
    if (signUpVal.password !== val) return '비밀번호가 일치하지 않습니다';

    return 'SUCCESS';
  },

  phoneNum: (val: any) => {
    console.log(val, '길이', val.length);
    if (val?.trim() === '') return '연락처를 입력해주세요';
    if (!/^[0-9]+$/.test(val)) return '연락처는 숫자로만 입력 가능합니다';

    return 'SUCCESS';
  },

  // gender: (val: any) => {
  //   if (val === '') return '성별을 입력해주세요';

  //   return 'SUCCESS';
  // },
};
