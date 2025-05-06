import styled from '@emotion/styled';

export const Wrapper = styled.div`
  height: 100vh;
  display: flex;
  background-color: #192736;
`;

export const SideBar_Left = styled.div`
  flex: 1;
  background-color: #223344;
  box-shadow: 4px 0 14px rgba(0, 0, 0, 0.28);
`;

export const Side_User_InfoBox = styled.div`
  height: 270px;
  padding: 25px;
  margin-bottom: 25px;
  box-shadow: inset 0 -2px 4px rgba(46, 65, 86, 0.25),
    0 3px 6px rgba(0, 0, 0, 0.12);
`;

export const Usser_ImgBox = styled.div`
  height: 150px;
  display: flex;
  justify-content: center;
`;

export const Profile_img = styled.img`
  width: 150px;
  height: 100%;
`;

export const User_Info = styled.div`
  display: flex;
  flex-direction: column;
  height: 70px;
  font-size: 18px;
  font-weight: 500;
  text-align: center;
  color: #9aa5b1;

  span {
    &:nth-of-type(1) {
      font-size: 20px;
      font-weight: 800;
    }

    &:nth-of-type(2) {
      margin-top: 7px;
    }
  }
`;

export const Side_Section_Category = styled.div<{ isClicked: boolean }>`
  flex: 1;
  height: 60px;
  font-size: 18px;
  font-weight: 700;
  padding: 0 40px;
  cursor: pointer;
  color: ${({ isClicked }) => (isClicked ? '#ffed00' : '#9aa5b1')};
  text-shadow: ${({ isClicked }) =>
    isClicked
      ? '0 0 0.5px #ffed0088, 0 0 1.5px #ffe10044, 0 0 3px #ffc80022'
      : 'none'};

  span {
    margin-left: 20px;
  }

  &:hover {
    color: #ffed00;
    text-shadow: 0 0 1px #ffed00aa, 0 0 3px #ffe10066, 0 0 5px #ffc80033;
  }
`;

export const MainContents = styled.div`
  flex: 3.5;
  display: flex;
  justify-content: center;
  align-items: flex-start;
  padding-top: 40px;
  /* border: 2px solid green; */
`;
