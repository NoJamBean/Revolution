import styled from '@emotion/styled';

export const Main = styled.main`
  margin: 0 auto;
  border: 5px solid red;
  min-height: 95vh;
  width: 1400px;
  display: flex;
  justify-content: space-between;
`;

export const Left_Side = styled.aside`
  border: 3px solid blue;
  width: 300px;
`;

export const Context = styled.aside`
  border: 3px solid green;
  width: calc(100% - 200px);
  margin: 0 20px 0 20px;
`;

export const Right_Side = styled.aside`
  border: 3px solid purple;
  width: 400px;
`;
