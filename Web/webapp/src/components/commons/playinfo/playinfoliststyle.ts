import styled from '@emotion/styled';

export const Right_Side = styled.aside<{ isMain: boolean }>`
  /* border: 5px solid purple; */
  width: 100%;
  height: 100%;
  position: relative;
  overflow-y: auto;
  border-bottom: 10px solid #152230;
  background-color: #152230;
  border-left: 3px solid #152230;

  /* display: ${({ isMain }) => isMain && 'flex'}; */
  /* flex-direction: ${({ isMain }) => isMain && 'column'}; */
  /* align-items: ${({ isMain }) => isMain && 'center'}; */
`;

export const Play_Category_Bar = styled.nav`
  height: 70px;
  position: sticky;
  top: 0;
  background-color: #1e2a38;
  z-index: 9;
`;

export const Category = styled.ul`
  border: 3px solid #152230;
  height: 100%;
  display: flex;
`;

export const Category_Li = styled.li`
  border: 1px solid #475569;
  height: 100%;
  width: 63px;
  font-size: 10px;
  font-weight: 700;
  aspect-ratio: 1 / 1;
  list-style: none;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  justify-content: space-around;
  cursor: pointer;
  padding-bottom: 3px;
  font-weight: 700;
  color: ${({ isClicked }: { isClicked: boolean }) =>
    isClicked ? '#94a3b8' : '#e2e8f0'};
  background-color: ${({ isClicked }: { isClicked: boolean }) =>
    isClicked ? '#6c7a91' : '#2a3f55'};

  &:hover {
    background-color: #6c7a91;
  }
`;

export const PlayInfo = styled.div`
  height: ${({ widget }: { widget: any }) => (widget ? '200px' : '150px')};
  border-radius: 15px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  background-color: #d8e4f0;

  &:hover {
    color: '#555';
  }
`;

type BlindProps = {
  widget: boolean;
  isClicked: boolean;
};

export const Blind = styled.div<BlindProps>`
  width: 100%;
  height: ${({ widget }: { widget: any }) => (widget ? '200px' : '150px')};
  border-radius: 15px;
  cursor: pointer;
  position: absolute;
  z-index: 3;
  transition: all 0.2s ease;
  background-color: ${({ isClicked }) =>
    isClicked ? 'transparent' : '#3a3a3a'};

  mix-blend-mode: ${({ isClicked }) => (isClicked ? 'normal' : 'multiply')};

  filter: ${({ isClicked }) =>
    isClicked ? 'none' : 'grayscale(100%) brightness(0.7) contrast(0.8)'};

  ${PlayInfo}:hover & {
    background-color: transparent;
    filter: none;
  }
`;

export const Info_Top = styled.div`
  border: 3px solid #88a7c4;
  height: ${({ widget }: { widget: any }) => (widget ? '25%' : '40%')};
  border-radius: 13px 13px 0 0;
  display: flex;
  justify-content: center;
  align-items: center;
  position: relative;
`;

export const League_Info = styled.div`
  height: 100%;
  width: 100%;
  display: flex;
  justify-content: center;
  text-align: center;
`;

export const League_Logo = styled.div`
  aspect-ratio: 1 / 1;
  padding: 3px;
`;

export const Logo_Img = styled.img`
  width: 100%;
  height: 100%;
  object-fit: cover;
`;

export const LeagueName = styled.div`
  font-size: 18px;
  font-weight: 700;
  display: flex;
  justify-content: center;
  align-items: center;
  margin-left: 15px;
  /* position: absolute; */
`;

export const Game_Time_Wrap = styled.div`
  border: 3px solid #88a7c4;
  border-bottom: none;
  border-right: none;
  border-top: none;
  width: 70px;
  height: 100%;
  font-size: ${({ widget }: { widget: any }) => (widget ? '12px' : '16px')};
  font-weight: 600;
  border-radius: 0 10px 0 0;
  margin-left: auto;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
`;

export const Game_Start_Date = styled.div`
  font-weight: 700;
`;

export const Game_Start_Time = styled.div`
  font-size: 14px;
`;

export const Info_Bottom = styled.div`
  height: ${({ widget }: { widget: any }) => (widget ? '150px' : '60%')};
  border-radius: 0 0 13px 13px;
  display: flex;
`;

export const Info_TeamName = styled.div`
  flex: ${({ widget }: { widget: any }) => (widget ? 1 : 2.5)};
  font-size: 15px;
  display: flex;
  justify-content: center;
  align-items: center;
  text-align: center;
  font-weight: 600;
  border: 3px solid #88a7c4;
  border-top: none;
`;

export const Info_TeamMark = styled.div`
  flex: ${({ widget }: { widget: any }) => (widget ? 2.5 : 1)};
  padding: 10px;
  height: ${({ widget }: { widget: any }) => (widget ? '70%' : '100%')};
  object-fit: cover;
  border: 3px solid #88a7c4;
  border-top: none;
`;

export const Info_Team_Img = styled.img`
  width: 100%;
  height: 100%;
`;

export const Play_Home = styled.div`
  border-radius: 0 0 11px 11px;
  height: 100%;
  width: 50%;
  display: flex;
  flex-direction: ${({ widget }: { widget: any }) =>
    widget ? 'column' : 'row'};

  ${Info_TeamName} {
    border-radius: 0 0 0 11px;
  }

  ${Info_TeamMark} {
    border-radius: ${({ widget }) => (widget ? 'none' : '0 0 11px 0')};
  }
`;

export const Verses = styled.div`
  width: ${({ widget }: { widget: any }) => (widget ? '30%' : '25%')};
  font-size: ${({ widget }) => (widget ? '24px' : '34px')};
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 22px;
  font-weight: 600;
  border: none;

  span {
    :nth-of-type(2) {
      display: inline-block;
      padding: 0 8px;
    }
  }
`;

export const Play_Away = styled.div`
  border-radius: 0 0 11px 11px;
  height: 100%;
  width: 50%;
  display: flex;
  flex-direction: ${({ widget }: { widget: any }) =>
    widget ? 'column' : 'row'};

  ${Info_TeamName} {
    border-radius: 0 0 11px 0;
  }

  ${Info_TeamMark} {
    border-radius: ${({ widget }) => (widget ? 'none' : '0 0 0 11px')};
  }
`;
