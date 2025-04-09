import styled from '@emotion/styled';

export const LoginMain = styled.div`
  width: 600px;
  height: 400px;
  display: flex;
  flex-direction: column;
  padding: 0 40px;
  border: 3px solid blue;
  position: relative;
`;

export const CloseBtn = styled.div`
  width: 25px;
  height: 25px;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 22px;
  font-weight: 900;
  position: absolute;
  top: 2px;
  left: calc(100% - 25px);
  cursor: pointer;
`;

export const Logo = styled.div`
  height: 20%;
  display: flex;
  justify-content: center;
  align-items: center;
  border: 5px solid purple;
`;

export const Form = styled.form`
  border: 3px solid gold;
  display: flex;
  flex-direction: column;
  justify-content: center;
  height: 100%;
  /* display: flex; */
`;

export const UserSection = styled.div`
  height: 25%;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border: 3px solid red;
`;

export const Title = styled.div`
  font-size: 20px;
  font-weight: 600;
`;

export const Input = styled.input`
  padding-left: 10px;
  font-size: 16px;
  width: 300px;
  height: 45px;
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
  border: 3px solid green;
`;

export const Button = styled.button`
  background-color: white;
  width: 300px;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  cursor: pointer;
  border: 3px solid gold;
`;
