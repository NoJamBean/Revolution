import styled from '@emotion/styled';

export const Wrapper = styled.div`
  height: 550px;
  overflow-y: auto;
  position: relative;
  width: 100%;
  border-radius: 10px;
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
  background-color: #192736;
  color: #e2e8f0;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 28px;
  font-weight: 900;
  cursor: pointer;
`;

export const Title = styled.div`
  position: sticky;
  width: 100%;
  border-radius: 10px 10px 0 0;
  background-color: #192736;
  top: 0;
  z-index: 99;
  height: 50px;
  font-size: 22px;
  font-weight: 800;
  letter-spacing: 1px;
  color: #e2e8f0;
  display: flex;
  justify-content: center;
  align-items: center;
`;

export const Title_Text = styled.span``;

export const SubTitle = styled.div`
  font-size: 16px;
  font-weight: 700;
  display: flex;
  align-items: center;
  height: 30%;
  color: white;
`;

export const Input_Wrapper = styled.div`
  position: relative;
  height: 70%;
`;

export const Email_Input_Wrapper = styled.div`
  padding-top: 5px;
  position: relative;
  height: 70%;
  display: flex;
  align-items: flex-start;
  justify-content: flex-end;
`;

export const Input = styled.input`
  all: unset;
  width: ${({ isReq }: { isReq: boolean }) => (isReq ? '50%' : '97.2%')};
  height: 38px;
  color: white;
  padding-left: 10px;
  border-radius: 10px;
  border: 1px solid #94a3b8;
  position: relative;
  z-index: 1;
`;

export const UserName = styled.div`
  height: 100px;
  padding: 12px 20px 0 20px;
  background-color: #273848;
`;

export const NickName = styled.div`
  /* margin: 18px 0; */
  height: 100px;
  padding: 0 20px;
  background-color: #273848;
`;

export const Email = styled.div`
  height: 140px;
  padding: 0 20px;
  background-color: #273848;
`;

export const DoubleCheck = styled.button`
  all: unset;
  border-left: 1px solid #94a3b8;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 14px;
  font-weight: 600;
  position: absolute;
  width: 80px;
  height: 38px;
  top: 1px;
  left: calc(100% - 80px);
  border-radius: 0 10px 10px 0;
  z-index: 3;
  color: #94a3b8;
  cursor: pointer;

  &:hover {
    background-color: #94a3b8;
    color: #273848;
  }
`;

export const EmailReqBtn = styled.button`
  all: unset;
  border-left: 1px solid #94a3b8;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 14px;
  font-weight: 600;
  position: absolute;
  width: 80px;
  height: 38px;
  top: 1px;
  left: calc(100% - 80px);
  border-radius: 0 10px 10px 0;
  z-index: 3;
  color: #94a3b8;
  cursor: pointer;

  &:hover {
    background-color: #94a3b8;
    color: #273848;
  }
`;

export const EmailChkBtn = styled.button`
  all: unset;
  border-left: 1px solid #94a3b8;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 14px;
  font-weight: 600;
  position: absolute;
  width: 80px;
  height: 38px;
  top: 6px;
  left: calc(100% - 80px);
  border-radius: 0 10px 10px 0;
  z-index: 3;
  color: #94a3b8;
  cursor: pointer;

  &:hover {
    background-color: #94a3b8;
    color: #273848;
  }
`;

export const Password = styled.div`
  height: 100px;
  padding: 0 20px;
  background-color: #273848;
`;

export const Phone = styled.div`
  height: 100px;
  padding: 0 20px;
  background-color: #273848;
`;

export const SignUpBtn = styled.button`
  position: sticky;
  bottom: 0;
  z-index: 99;
  height: 80px;
  width: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 22px;
  font-weight: 600;
  cursor: pointer;
  border: 2px solid gray;
  border-radius: 0 0 10px 10px;
  background-color: #94a3b8;

  &:hover {
    border: none;
    background-color: #192736;
    color: #e2e8f0;
  }
`;
