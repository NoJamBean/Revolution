import styled from '@emotion/styled';

export const LoginMain = styled.div`
  width: 550px;
  height: 400px;
  display: flex;
  flex-direction: column;
  position: relative;
  border: 1px solid rgba(100, 140, 180, 0.15);
  border-radius: 15px;
  box-shadow: 0 0 0 1px rgba(255, 255, 255, 0.04), 0 4px 8px rgba(0, 0, 0, 0.5);
`;

export const CloseBtn = styled.div`
  position: absolute;
  height: 40px;
  width: 40px;
  display: flex;
  justify-content: center;
  align-items: center;
  text-align: center;
  line-height: 1;
  font-size: 30px;
  font-weight: 900;
  color: white;
  top: 10px;
  left: calc(100% - 40px - 10px);
  cursor: pointer;
  z-index: 9;
`;

export const LogoImgBox = styled.div`
  height: 35%;
  display: flex;
  justify-content: center;
  border-radius: 10px 10px 0 0;
  font-size: 30px;
  color: white;
  z-index: 2;
  filter: brightness(0.8);
`;

export const LogoImg = styled.img`
  position: absolute;
  width: 170px;
  height: 160px;
  filter: blur(0.5px);
  filter: saturate(0.7);
`;

export const Logo = styled.div``;

export const Form = styled.form`
  display: flex;
  flex-direction: column;
  justify-content: center;
  height: 100%;
  border-radius: 0 0 10px 10px;
`;

export const UserSection = styled.div`
  height: 22%;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 40px;
`;

export const Title = styled.div`
  font-size: 20px;
  font-weight: 800;
  color: #ffffff;
`;

export const Input = styled.input`
  all: unset;
  padding-left: 15px;
  font-size: 18px;
  width: 270px;
  height: 55px;
  background-color: #3a3a3a;
  border-radius: 5px;
  color: #f1f5f9;
`;

export const Password = styled.div`
  height: 25%;
  border: 3px solid red;
`;

export const ButtonWrap = styled.div`
  height: 40%;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  justify-content: space-between;
  padding: 2px 40px;
`;

export const Button = styled.button`
  border: none;
  width: 285px;
  height: 55px;
  display: flex;
  justify-content: center;
  align-items: center;
  cursor: pointer;
  border-radius: 5px;
  background-color: #5c6e83;
  color: #ffffff;
  font-size: 16px;
  font-weight: 700;
  position: relative;
  overflow: hidden;
  z-index: 0;
  transition: color 0.3s ease;

  &::before {
    content: '';
    position: absolute;
    width: 200%;
    height: 200%;
    background: linear-gradient(135deg, #2a3f55, #2a3f55);
    border-radius: 50%;
    clip-path: circle(0% at 0% 100%); /* 왼쪽 아래 시작 */
    transition: clip-path 0.6s ease;
    z-index: 1;
  }

  &:hover::before {
    clip-path: circle(150% at 0% 100%);
  }

  & > span {
    position: relative;
    z-index: 2;
  }

  &:hover {
    color: #192736;
  }
`;
