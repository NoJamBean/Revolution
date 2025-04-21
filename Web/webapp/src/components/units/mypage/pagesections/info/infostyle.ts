import styled from '@emotion/styled';

export const InfoWrapper = styled.div`
  background-color: #1e2f3f;
  box-shadow: 2px 2px 6px rgba(0, 0, 0, 0.4);
  width: 90%;
  height: 600px;
  border-radius: 20px;
  display: flex;
  flex-direction: column;
`;

export const Info_Top = styled.div`
  height: 100px;
  font-size: 36px;
  font-weight: 700;
  display: flex;
  align-items: center;
  padding-left: 30px;
  color: #d8e4f0;
`;

export const Info_Body = styled.div`
  flex: 1;
  margin: 0 30px 30px 30px;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  border-top: 1px solid rgba(216, 228, 240, 0.3);
`;

export const Info_Section_Line = styled.div`
  width: 100%;
  height: 60px;
  margin-top: 15px;
  display: flex;
  justify-content: space-between;
`;

export const Info = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 50%;
  padding-right: 100px;
  span {
    display: inline-block;

    :nth-of-type(1) {
      color: #b6c2cd;
      font-size: 16px;
      font-weight: 700;
      padding: 7px;
      background-color: #151f2b;
      border-radius: 5px;
    }

    :nth-of-type(2) {
      color: #d8e4f0;
    }
  }
`;

export const Edit_Btn = styled.button`
  width: 100px;
  height: 40px;
  border-radius: 7px;
  margin-top: 15px;
  font-weight: 700;
  letter-spacing: 0.32px;
  background-color: #e6c81a;
  cursor: pointer;
`;
