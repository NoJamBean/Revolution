import styled from '@emotion/styled';

export const Wrapper = styled.div`
  border: 2px solid green;
  height: 100%;
  overflow: auto;
`;

export const Info_Top = styled.div`
  border: 2px solid blue;
  height: 140px;
  display: flex;
`;

export const Info_Body = styled.div`
  border: 3px solid red;
  display: flex;
  flex-direction: ${({ isMain }: { isMain: boolean }) =>
    isMain ? 'row' : 'column'};
`;

export const Info_Top_Home = styled.div`
  height: 100%;
  /* flex: 1; */
  width: 43%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  border: 3px solid blue;
`;

export const Team_Logo = styled.img`
  border: 2px solid orange;
  height: 70%;
`;

export const Team_Name = styled.div`
  border: 2px solid orange;
  height: 30%;
`;

export const Verses = styled.div`
  height: 100%;
  width: 14%;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 24px;
  font-weight: 700;
  /* border: 3px solid blue; */
`;

export const Info_Top_Away = styled.div`
  height: 100%;
  /* flex: 1; */
  width: 43%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  text-align: center;
  border: 3px solid blue;
`;

export const Team_Title = styled.div`
  border: 2px solid gray;
  height: 45px;
  display: flex;
  /* 
  &.second {
    margin-top: 50px;
  } */
`;

export const Team_Title_Logo = styled.img`
  border: 2px solid red;
  height: 100%;
  padding: 2px;
  aspect-ratio: 1 / 1;
`;

export const Team_Title_Name = styled.div`
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: flex-start;
  align-items: center;
  padding-left: 5px;
  font-weight: 700;
  border: 2px solid gray;
`;

export const HomeInfo = styled.div`
  border: 3px solid red;
  width: 100%;
  /* height: calc((100% - 60px) / 2); */
`;

export const AwayInfo = styled.div`
  border: 3px solid blue;
  width: 100%;
  /* height: calc((100% - 60px) / 2); */
`;

export const Info_Section_Title = styled.div`
  border: 2px solid gray;
  height: 30px;
  display: flex;
  justify-content: flex-start;
  align-items: center;
  padding-left: 5px;
  background-color: lightgray;
`;

export const Info_Section = styled.div`
  border: 2px solid gray;
  height: 30px;
  display: flex;
  justify-content: space-between;
  padding: 0 5px;
`;

export const Section_Left = styled.div`
  display: flex;
  justify-content: center;
  align-items: center;
  font-weight: 700;
  /* border: 2px solid black; */
`;

export const Section_Right = styled.div`
  display: flex;
  justify-content: flex-end;
  align-items: center;
  /* width: 160px; */

  span {
    display: inline-block;
    margin-left: 5px;
    border: 2px solid orange;
  }
`;

export const Section_Right_Img = styled.img`
  height: 100%;
  aspect-ratio: 1 / 1;
  padding: 2px;
`;
