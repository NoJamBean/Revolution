import styled from '@emotion/styled';
import Link from 'next/link';

export const Wrapper = styled.div`
  /* min-height: 20px; */
  border-bottom: 5px solid gold;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 calc((1400px - 872px) / 2) 0 calc((1400px - 872px) / 2);
`;

export const LogoImg = styled.div`
  width: 100px;
  height: 70px;
  object-fit: cover;
  border: 2px solid green;
`;

export const Bar = styled.ul`
  display: flex;
  justify-content: space-between;
  width: 50vw;
`;

export const Menu = styled.li`
  list-style-type: none;
`;

export const MenuLink = styled(Link)`
  color: black;
  text-decoration: none;
  font-size: 22px;
  font-weight: 700;
`;

export const Sign_Container = styled.div`
  width: 140px;
  display: flex;
  justify-content: space-between;
  /* border: 2px solid green; */
`;

export const SignIn = styled.button`
  width: 65px;
  height: 100%;
  border: 1px solid black;
  background-color: white;
`;

export const SignUp = styled.button`
  width: 65px;
  height: 100%;
  border: 1px solid black;
  background-color: white;
`;
