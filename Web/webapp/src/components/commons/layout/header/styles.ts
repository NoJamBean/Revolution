import styled from '@emotion/styled';
import Link from 'next/link';

export const Wrapper = styled.div`
  position: relative;
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  padding: 0 50px 0 20px;
  background-color: #2a3f55;
  /* border-bottom: 7px solid #4a5f73; */
  border-bottom: 5px solid #4a5f73;
  box-shadow: inset 0 -7px 7px -3px rgba(255, 255, 255, 0.75);
`;

export const LogoImgWrap = styled.div`
  width: 100px;
  height: 100px;
  cursor: pointer;
`;

export const LogoImg = styled.img`
  width: 100%;
  height: 100%;
  filter: blur(0.5px);
  filter: saturate(0.7);
`;

export const Bar = styled.ul`
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-items: flex-end;
  width: 52vw;
  margin-bottom: 15px;
`;

export const Menu_Bar = styled.div`
  order: 2;
  width: 500px;
  display: flex;
  justify-content: space-between;
  padding: 10px 0;
  margin-right: 80px;
`;

export const Menu = styled.li`
  list-style-type: none;
`;

export const MenuLink = styled(Link)`
  color: #94a3b8;
  text-decoration: none;
  font-size: 20px;
  font-weight: 600;

  &:hover {
    color: #ffed00;

    text-shadow: 0 0 5px #ffed00, 0 0 10px #ffed00, 0 0 20px #ffe100,
      0 0 40px #ffc800;
  }
`;

export const InfoLink = styled.div`
  color: #94a3b8;
  text-decoration: none;
  font-size: 20px;
  font-weight: 600;

  &:hover {
    color: #ffed00;

    text-shadow: 0 0 5px #ffed00, 0 0 10px #ffed00, 0 0 20px #ffe100,
      0 0 40px #ffc800;
  }
`;

export const Sign_Container = styled.div`
  order: 1;
  width: 135px;
  /* height: 80px; */
  display: flex;
  justify-content: space-between;
`;

export const LogIn_User_Container = styled.div`
  /* order: 2; */
  width: 170px;
  display: flex;
  justify-content: space-between;
  align-items: center;
`;

export const SignIn = styled.button`
  all: unset;
  width: 65px;
  height: 40px;
  /* border-radius: 3px; */
  /* border: 1px solid #94a3b8; */
  color: #94a3b8;
  display: flex;
  justify-content: center;
  align-items: center;
  font-weight: 700;
  /* background-color: #ffed00; */
  /* box-shadow: 2px 2px 0px #c5b800; */
  /* border: none; */
  cursor: pointer;

  &:hover {
    color: #ffed00;

    text-shadow: 0 0 5px #ffed00, 0 0 10px #ffed00, 0 0 20px #ffe100,
      0 0 40px #ffc800;
  }
`;

export const SignUp = styled.button`
  all: unset;
  width: 65px;
  height: 40px;
  /* border-radius: 3px; */
  /* border: 1px solid #94a3b8; */
  color: #94a3b8;
  display: flex;
  justify-content: center;
  align-items: center;
  font-weight: 700;
  /* background-color: #ffed00; */
  /* box-shadow: 2px 2px 0px #c5b800; */
  cursor: pointer;

  &:hover {
    color: #ffed00;

    text-shadow: 0 0 5px #ffed00, 0 0 10px #ffed00, 0 0 20px #ffe100,
      0 0 40px #ffc800;
  }
`;

export const UserInfo = styled.div`
  flex: 1;
  height: 33px;
  display: flex;
  align-items: center;
  cursor: pointer;
`;

export const Profile_Img = styled.img`
  width: 33px;
  height: 100%;
  object-fit: cover;
`;

export const Profile_Name = styled.span`
  display: inline-block;
  margin-left: 3px;
  color: #94a3b8;
  font-weight: 600;
  font-size: 16px;
`;

export const LogOut = styled.button`
  all: unset;
  width: 65px;
  height: 40px;
  /* border-radius: 3px; */
  /* border: 1px solid #94a3b8; */
  color: #94a3b8;
  display: flex;
  justify-content: center;
  align-items: center;
  font-weight: 700;
  /* background-color: #ffed00; */
  /* box-shadow: 2px 2px 0px #c5b800; */
  cursor: pointer;

  &:hover {
    color: #ffed00;

    text-shadow: 0 0 5px #ffed00, 0 0 10px #ffed00, 0 0 20px #ffe100,
      0 0 40px #ffc800;
  }
`;
