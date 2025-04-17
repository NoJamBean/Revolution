import styled from '@emotion/styled';

export const Wrapper = styled.div`
  height: 550px;
  overflow-y: auto;
  position: relative;
  width: 100%;
  border: 3px solid blue;
`;

export const Contents = styled.form`
  width: 100%;
  position: relative;
  display: flex;
  flex-direction: column;
  background-color: white;
`;

export const CloseBtn = styled.div`
  position: absolute;
  z-index: 100;
  top: 0;
  left: calc(100% - 50px);
  width: 50px;
  height: 50px;
  background-color: gray;
  color: aliceblue;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 22px;
  font-weight: 900;
  cursor: pointer;
`;

export const Title = styled.div`
  position: sticky;
  width: 100%;
  background-color: darkgray;
  top: 0;
  z-index: 99;
  height: 50px;
  font-size: 24px;
  font-weight: 400;
  color: whitesmoke;
  display: flex;
  justify-content: center;
  align-items: center;
`;

export const Title_Text = styled.span``;

export const SubTitle = styled.div`
  border: 2px solid red;
  font-size: 16px;
  font-weight: 700;
  display: flex;
  align-items: center;
  height: 30%;
`;

export const Input_Wrapper = styled.div`
  border: 3px solid gold;
  position: relative;
  height: 70%;
`;

export const Email_Input_Wrapper = styled.div`
  border: 1px solid red;
  position: relative;
  height: 70%;
  display: flex;
  align-items: center;
  justify-content: flex-end;
`;

export const Input = styled.input`
  width: ${({ isReq }: { isReq: boolean }) => (isReq ? '50%' : '100%')};
  height: 38px;
  padding-left: 10px;
  border-radius: 10px;
  border: none;
  position: relative;
  z-index: 1;
  border: 1px solid green;
`;

export const UserName = styled.div`
  height: 100px;
  margin: 18px 0;
  padding: 0 14px;
  border: 3px solid blue;
`;

export const NickName = styled.div`
  margin: 18px 0;
  height: 100px;
  padding: 0 14px;
  border: 3px solid blue;
`;

export const Email = styled.div`
  height: 150px;
  margin: 18px 0;
  padding: 0 14px;
  border: 3px solid blue;
`;

export const DoubleCheck = styled.button`
  position: absolute;
  width: 80px;
  height: 38px;
  top: 0;
  left: calc(100% - 80px);
  border-radius: 0 10px 10px 0;
  border: none;
  border: 1px solid green;
  z-index: 3;
  cursor: pointer;
`;

export const EmailReqBtn = styled.button`
  position: absolute;
  width: 80px;
  height: 38px;
  top: 0;
  left: calc(100% - 80px);
  border-radius: 0 10px 10px 0;
  border: none;
  border: 1px solid green;
  z-index: 3;
  cursor: pointer;
`;

export const EmailChkBtn = styled.button`
  position: absolute;
  width: 80px;
  height: 38px;
  top: calc(50% - 38px / 2);
  left: calc(100% - 80px);
  border-radius: 0 10px 10px 0;
  border: none;
  border: 1px solid green;
  z-index: 3;
  cursor: pointer;
`;

export const Password = styled.div`
  margin: 18px 0;
  height: 100px;
  padding: 0 14px;
  border: 3px solid blue;
`;

export const Phone = styled.div`
  margin: 18px 0;
  height: 100px;
  padding: 0 14px;
  border: 3px solid blue;
`;

export const Sex = styled.div`
  margin: 18px 0;
  height: 100px;
  padding: 0 14px;
  border: 3px solid blue;
  display: flex;
  flex-direction: column;
`;

export const Radio_Wrapper = styled.div`
  margin-top: 10px;
  display: flex;
`;

export const HiddenRadio = styled.input`
  display: none;
`;

export const RadioText = styled.span`
  margin-left: 3px;
  display: inline-block;
  transition: all 0.2s ease;
  line-height: 1;
`;

export const RadioMark = styled.span`
  display: inline-block;
  width: 18px;
  height: 18px;
  border: 2px solid gray;
  border-radius: 50%;
  position: relative;
`;

export const RadioLabel = styled.label`
  cursor: pointer;
  display: flex;
  align-items: flex-end;

  input[type='radio']:checked + span::after {
    content: '';
    position: absolute;
    top: 10%;
    left: 15%;
    width: 10px;
    height: 10px;
    background: gray;
    border-radius: 50%;
  }

  &:nth-of-type(2) {
    margin-left: 10px;
  }
`;

export const SignUpBtn = styled.button`
  height: 80px;
  width: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 20px;
  font-weight: 600;
  cursor: pointer;
  border: 2px solid gray;
`;
