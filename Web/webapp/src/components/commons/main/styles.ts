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
  display: flex;
  flex-direction: column;
`;

export const Carousel = styled.div`
  background-color: blue;
  flex: 2;
  width: 100%;
  max-height: 150px;
  display: flex;
  object-fit: cover;
`;

export const WeeklyMatch = styled.div`
  background-color: red;
  flex: 2;
  margin: 10px 0 10px 0;
  /* min-height: 220px; */
`;

export const ProtoInfo = styled.div`
  background-color: green;
  flex: 4.5;
  /* min-height: 300px; */
`;

export const Right_Side = styled.aside`
  border: 3px solid purple;
  width: 400px;
`;
