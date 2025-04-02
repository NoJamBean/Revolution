import styled from '@emotion/styled';

export const Main = styled.main`
  margin: 0 auto;
  border: 5px solid red;
  min-height: 95vh;
  display: flex;
  justify-content: space-between;
`;

export const Left_Side = styled.aside`
  border: 3px solid blue;
  width: 100%;
  height: 100%;
`;

export const Right_Side = styled.aside`
  border: 3px solid purple;
  width: 100%;
  height: 100%;
`;

export const PlayInfo = styled.div`
  border: 2px solid black;
  min-height: 150px;
  border-radius: 15px;
`;

export const Context = styled.aside`
  border: 3px solid green;
  width: 100%;
  display: flex;
  flex-direction: column;
`;

export const Carousel = styled.div`
  background-color: blue;
  flex: 2;
  width: 100%;
  max-height: 420px;
  display: flex;
  object-fit: cover;
  border: 5px solid blue;
`;

export const Body = styled.div`
  border: 3px solid gold;
  display: flex;
  min-height: 800px;
  flex-direction: row;
`;

export const Bottom = styled.div`
  border: 3px solid green;
  min-height: 330px;
`;
