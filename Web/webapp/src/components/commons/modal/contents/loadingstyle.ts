import styled from '@emotion/styled';

export const Wrapper = styled.div`
  width: 100%;
  height: 100%;
  background-color: #343b4a;
  border-radius: 10px;
`;

export const LoadingContent = styled.div`
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: space-around;
  border-radius: 10px;
  border: 2px solid #2c313d;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.7);
`;

export const ImgBox = styled.div`
  width: 160px;
  height: 160px;
  border-radius: 10px;
`;

export const Loading_Img = styled.img`
  width: 100%;
  height: 100%;
`;

export const Loading_Context = styled.div`
  &:first-of-type {
    font-size: 22px;
    font-weight: 600;
  }

  &:last-of-type {
    font-size: 16px;
    font-weight: 400;
    margin-top: 30px;
  }

  color: #e2e8f0;
`;
