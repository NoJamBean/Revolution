import { keyframes } from '@emotion/react';
import styled from '@emotion/styled';

const blurIn = keyframes`
  0% {
    backdrop-filter: blur(0px);
    background-color: rgba(0, 0, 0, 0);
  }
  100% {
    backdrop-filter: blur(7px);
    background-color: rgba(0, 0, 0, 0.3);
  }
`;

const blurOut = keyframes`
  100% {
    backdrop-filter: blur(7px);
    background-color: rgba(0, 0, 0, 0);
  }
  0% {
    backdrop-filter: blur(0px);
    background-color: rgba(0, 0, 0, 0.3);
  }
`;

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
  backdrop-filter: blur(6px);
  animation: ${({ isLoading }: { isLoading: boolean }) =>
      isLoading ? blurIn : blurOut}
    0.2s ease forwards;
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
  /* width: 600px; */
  width: ${({ modalType }) => (modalType === 'Login' ? '600px' : '450px')};
  height: 400px;
  background-color: white;
  animation: ${({ isLoading }) => (isLoading ? fadeIn : fadeOut)} 0.3s ease
    forwards;
`;

export const LoadingContent = styled.div`
  border: 2px solid red;
  display: flex;
  /* height: 100%; */
  flex-grow: 1;
`;

export const ButtonWrap = styled.div`
  border: 3px solid green;
`;

export const Button = styled.div`
  width: 100px;
  border: 3px solid gold;
`;
