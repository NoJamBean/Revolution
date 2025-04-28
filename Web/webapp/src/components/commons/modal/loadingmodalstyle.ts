import { keyframes } from '@emotion/react';
import styled from '@emotion/styled';

export const LoadingModalOverlay = styled.div`
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 9999;
  backdrop-filter: ${({ isLoading }: { isLoading: boolean }) =>
    isLoading ? 'blur(7px)' : 'blur(0px)'};
  background-color: ${({ isLoading }) =>
    isLoading ? 'rgba(0, 0, 0, 0.3)' : 'rgba(0, 0, 0, 0)'};

  transition: backdrop-filter 0.3s ease, background-color 0.3s ease;
  will-change: backdrop-filter, background-color;
  /* transform: translateZ(0); */
`;

const fadeIn = keyframes`
  from {
    opacity: 0;
    /* transform: scale(0.95); */
  }
  to {
    opacity: 1;
    /* transform: scale(1); */
  }
`;

const fadeOut = keyframes`
  from {
    opacity: 1;
    /* transform: scale(0.95); */
  }
  to {
    opacity: 0;
    /* transform: scale(1); */
  }
`;

export const LoadingModalContent = styled.div<{
  modalType: any;
  isLoading: boolean;
}>`
  /* width: ${({ modalType }) =>
    modalType === 'Login' ? '600px' : '450px'}; */
  height: 400px;
  background-color: #343b4a;
  animation: ${({ isLoading }) => (isLoading ? fadeIn : fadeOut)} 0.5s ease
    forwards;
  width: 260px;
  height: 300px;
  display: flex;
  flex-direction: column;
  border-radius: 10px;
`;

export const LoadingContent = styled.div`
  display: flex;
  height: 100%;
  background-color: #343b4a;
  border-radius: 10px;
  /* flex-grow: 1; */
`;

export const ButtonWrap = styled.div`
  /* border: 3px solid green; */
`;

export const Button = styled.div`
  width: 100px;
  border: 3px solid gold;
`;
