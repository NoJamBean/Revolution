import { keyframes } from '@emotion/react';
import styled from '@emotion/styled';

const slideFadeIn = keyframes`
  from {
    opacity: 0;
    transform: translate(-50%, -70%);
  }
  to {
    opacity: 1;
    transform: translate(-50%, -50%);
  }
`;

const slideFadeOut = keyframes`
  from {
    opacity: 1;
    transform: translate(-50%, -50%);
  }
  to {
    opacity: 0;
    transform: translate(-50%, -30%);
  }
`;

export const ModalOverlay = styled.div`
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.3);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 9999;
`;

export const ModalContent = styled.div<{
  modalType: any;
  isModalOpen: boolean;
}>`
  /* width: 600px; */
  width: ${({ modalType }) => (modalType === 'Login' ? '550px' : '400px')};
  height: 400px;
  position: absolute;
  backdrop-filter: brightness(1) saturate(0.9);
  background-size: cover;
  background-image: ${({ modalType }) =>
    modalType === 'Login'
      ? `linear-gradient(
        to right,
        rgba(120, 160, 200, 0.05),
        rgba(60, 60, 60, 0.05)
      ), url('/signinbg.png')`
      : `linear-gradient(
        to right,
        rgba(120, 160, 200, 0.05),
        rgba(60, 60, 60, 0.05)
      )`};
  background-position: 40% 5%;
  background-repeat: no-repeat;
  background-blend-mode: overlay;
  top: 40%;
  left: 50%;
  animation: ${({ isModalOpen }) => (isModalOpen ? slideFadeIn : slideFadeOut)}
    0.5s ease;
  animation-fill-mode: forwards; // 이거 필수
  border-radius: 15px;

  &::before {
    content: '';
    position: absolute;
    inset: 0;
    background: rgba(255, 255, 255, 0.05); /* 아주 연한 투명 덮개 */
    backdrop-filter: blur(0.7px); /* 살짝만 흐림 */
    border-radius: 15px;
  }
`;

export const Content = styled.div`
  display: flex;
  flex-grow: 1;
  border-radius: 15px;
`;

// export const ButtonWrap = styled.div`
//   border: 3px solid green;
// `;

// export const Button = styled.div`
//   width: 100px;
//   border: 3px solid gold;
// `;
