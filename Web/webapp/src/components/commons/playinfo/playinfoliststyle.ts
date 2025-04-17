import styled from '@emotion/styled';

export const Right_Side = styled.aside`
  border: 5px solid purple;
  width: 100%;
  height: 100%;
  position: relative;
  overflow-y: auto;
  background-color: white;
`;

export const Play_Category_Bar = styled.nav`
  height: 70px;
  position: sticky;
  top: 0;
  background-color: aliceblue;
  border: 3px solid red;
  z-index: 9;
`;

export const Category = styled.ul`
  border: 3px solid blue;
  height: 100%;
  display: flex;
`;

export const Category_Li = styled.li`
  border: 2px solid green;
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
`;

export const PlayInfo = styled.div`
  height: ${({ widget }: { widget: any }) => (widget ? '200px' : '150px')};
  border-radius: 15px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
`;

type BlindProps = {
  widget: boolean;
  isClicked: boolean;
};

export const Blind = styled.div<BlindProps>`
  border: 1px solid orange;
  width: 100%;
  height: ${({ widget }: { widget: any }) => (widget ? '200px' : '150px')};
  border-radius: 15px;
  cursor: pointer;
  position: absolute;
  background-color: ${({ isClicked }: { isClicked: any }) =>
    isClicked ? 'transparent' : 'rgba(30, 30, 30, 0.7)'}; // 진한 회색
  filter: ${({ isClicked }: { isClicked: any }) =>
    isClicked ? 'none' : 'grayscale(100%) brightness(0.4) contrast(0.7)'};

  z-index: 3;
  transition: all 0.2s ease;

  ${PlayInfo}:hover & {
    background-color: transparent;
    filter: none;
  }
`;

export const Info_Top = styled.div`
  border: 3px solid green;
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
  /* border: 3px solid blueviolet; */
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
  border: 3px solid orange;
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

export const Game_Start_Time = styled.div``;

export const Info_Bottom = styled.div`
  border: 3px solid hotpink;
  height: ${({ widget }: { widget: any }) => (widget ? '150px' : '60%')};
  border-radius: 0 0 13px 13px;
  display: flex;
  border: 3px solid green;
`;

export const Info_TeamName = styled.div`
  border: 3px solid blue;
  flex: ${({ widget }: { widget: any }) => (widget ? 1 : 2.5)};
  font-size: 15px;
  display: flex;
  justify-content: center;
  align-items: center;
  text-align: center;
  font-weight: 600;
  border: 3px solid gold;
`;

export const Info_TeamMark = styled.div`
  border: 3px solid blue;
  flex: ${({ widget }: { widget: any }) => (widget ? 2.5 : 1)};
  padding: 10px;
  height: ${({ widget }: { widget: any }) => (widget ? '70%' : '100%')};
  object-fit: cover;
  border: 3px solid red;
`;

export const Info_Team_Img = styled.img`
  width: 100%;
  height: 100%;
`;

export const Play_Home = styled.div`
  /* border: 3px solid navy; */
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
  border: 2px solid red;
  width: ${({ widget }: { widget: any }) => (widget ? '30%' : '25%')};
  font-size: ${({ widget }) => (widget ? '24px' : '34px')};
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 22px;
  font-weight: 600;
  border: 3px solid blue;

  span {
    :nth-of-type(2) {
      display: inline-block;
      padding: 0 8px;
    }
  }
`;

export const Play_Away = styled.div`
  /* border: 3px solid navy; */
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
