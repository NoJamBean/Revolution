import styled from '@emotion/styled';
import Link from 'next/link';

export const Wrapper = styled.div`
  border-bottom: 5px solid gold;
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  padding: 0 50px;
`;

export const LogoImg = styled.div`
  width: 100px;
  height: 100px;
  object-fit: cover;
  border: 2px solid green;
`;

export const Bar = styled.ul`
  display: flex;
  justify-content: space-between;
  width: 50vw;
  margin-bottom: 10px;
  /* border: 3px solid red; */
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
  cursor: pointer;
`;

export const SignUp = styled.button`
  width: 65px;
  height: 100%;
  border: 1px solid black;
  background-color: white;
  cursor: pointer;
`;
