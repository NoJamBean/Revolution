const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

export const validators = {
  emailId: (val) => {
    if (val === '') return '이메일을 입력해주세요';
    if (!emailRegex.test(val)) return '올바른 이메일 형식이 아닙니다';
    return 'SUCCESS';
  },
  nickName: (val) => {
    if (val === '') return '닉네임을 입력해주세요';
    if (val.length < 3) return '닉네임은 최소 3자 이상이어야 합니다';
    return 'SUCCESS';
  },
  password: (val) => {
    if (val === '') return '비밀번호를 입력해주세요';
    return 'SUCCESS';
  },

  passwordCheck: (val, signUpVal) => {
    if (val === '') return '비밀번호를 입력해주세요';
    if (signUpVal.password !== val) return '비밀번호가 일치하지 않습니다';
    return 'SUCCESS';
  },

  phoneNum: (val) => {
    console.log(val, '길이', val.length);
    if (val === '') return '연락처를 입력해주세요';
    if (!/^[0-9]+$/.test(val)) return '연락처는 숫자로만 입력 가능합니다';
    return 'SUCCESS';
  },

  gender: (val) => {
    if (val === '') return '성별을 입력해주세요';
    return 'SUCCESS';
  },
};
