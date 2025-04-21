import styled from '@emotion/styled';

export const Wrapper = styled.div`
  height: 100%;
  overflow-y: auto;
  background-color: #152230;
  border-right: ${({ isMain }) => (isMain ? '10px solid #152230' : 'none')};
`;

export const Info_Top = styled.div`
  height: 200px;
  display: flex;
  background-color: #192736;
`;

export const Info_Body = styled.div`
  border: 3px solid #6c7a91;
  background-color: #2a3f55;
  color: white;
  display: flex;
  flex-direction: ${({ isMain }: { isMain: boolean }) =>
    isMain ? 'row' : 'column'};
`;

export const Info_Top_Home = styled.div`
  display: flex;
  flex: 1;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  padding: 20px;
`;

export const Team_Logo = styled.img`
  width: ${({ isBet }: { isBet: boolean }) => (isBet ? '100%' : '80%')};
  max-width: ${({ isBet }: { isBet: boolean }) => (isBet ? '100%' : '80%')};
  height: 100%;
  object-fit: contain;
`;

export const Team_Name = styled.div`
  width: 200px;
  height: 30%;
`;

export const Verses = styled.div`
  height: 100%;
  width: 14%;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 40px;
  font-weight: 700;
  color: white;
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
  padding: 20px;
`;

export const Team_Title = styled.div`
  height: 45px;
  display: flex;
  /* 
  &.second {
    margin-top: 50px;
  } */
`;

export const Team_Title_Logo = styled.img`
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
  color: #cbd5e1;
`;

export const HomeInfo = styled.div`
  width: 100%;
`;

export const DivdedTag = styled.div`
  width: 100%;
  height: 70px;
  border-bottom: 2px solid #6c7a91;
  background-color: #192736;
`;

export const AwayInfo = styled.div`
  width: 100%;
  border-left: 2px solid #6c7a91;
`;

export const Info_Section_Title = styled.div`
  height: 30px;
  display: flex;
  justify-content: flex-start;
  align-items: center;
  padding-left: 5px;
  background-color: #6c737d;
  font-weight: 800;
`;

export const Info_Section = styled.div`
  border: 1px solid #6c7a91;
  height: 30px;
  display: flex;
  justify-content: space-between;
  color: #cbd5e1;
  padding: 0 5px;
`;

export const Section_Left = styled.div`
  display: flex;
  justify-content: center;
  align-items: center;
  font-weight: 600;
`;

export const Section_Right = styled.div`
  display: flex;
  justify-content: flex-end;
  align-items: center;
  /* width: 160px; */
  background-color: #192736;
  border-radius: 10px;
  padding: 3px 5px;
  color: #e2e8f0;
  font-weight: 700;

  span {
    display: inline-block;
    margin-left: 5px;
  }
`;

export const Section_Right_Img = styled.img`
  height: 100%;
  aspect-ratio: 1 / 1;
  padding: 2px;
`;
