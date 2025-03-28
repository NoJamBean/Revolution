import styled from '@emotion/styled';
import Link from 'next/link';

export const Wrapper = styled.div`
  /* min-height: 20px; */
  border-bottom: 5px solid gold;
  display: flex;
  justify-content: center;
  align-items: center;
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
  margin-left: 100px;
  border: 3px solid blue;
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
