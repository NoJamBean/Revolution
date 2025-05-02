import { keyframes } from '@emotion/react';
import styled from '@emotion/styled';

export const LoadingModalOverlay = styled.div<{ isLoading: boolean }>`
  position: fixed;
  top: 0;
  left: 0;
<<<<<<< HEAD
  width: 100vw;
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
=======
  width: 100vw; /* ✅ 뷰포트 기준 100% */
  height: 100vh; /* ✅ 뷰포트 기준 100% */
  display: flex !important;
  justify-content: center !important;
  align-items: center !important;
>>>>>>> web
  z-index: 9999;
  isolation: isolate;

  backdrop-filter: blur(7px);
  background-color: rgba(0, 0, 0, 0.3); /* ✅ 반투명 블랙 깔고 */

  /* ✅ 버그 막기 위해 transform 제거 */
  will-change: backdrop-filter, background-color;

  /* ✅ ::before 꼬라지 방지 */
  &::before {
    content: none;
    display: none;
  }
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
  width: 100%;
  height: auto; /* 콘텐츠 높이에 맞게 자동으로 조정 */
  max-width: 500px; /* 최대 너비 제한 */
  padding: 20px; /* 여백 추가 */
  background-color: #343b4a;
  animation: ${({ isLoading }) => (isLoading ? fadeIn : fadeOut)} 0.5s ease forwards;
  display: flex;
  flex-direction: column;
  border-radius: 10px;
  position: static;
  margin: 0;
`;

export const LoadingContent = styled.div`
  display: flex;
  height: 100%;
  background-color: #343b4a;
  border-radius: 10px;
  justify-content: center;
  align-items: center; /* 콘텐츠 중앙 정렬 */
`;

// export const LoadingModalContent = styled.div<{
//   modalType: any;
//   isLoading: boolean;
// }>`
//   /* width: ${({ modalType }) =>
//     modalType === 'Login' ? '600px' : '450px'}; */
//   height: 400px;
//   background-color: #343b4a;
//   animation: ${({ isLoading }) => (isLoading ? fadeIn : fadeOut)} 0.5s ease
//     forwards;
//   width: 260px;
//   height: 300px;
//   display: flex;
//   flex-direction: column;
//   border-radius: 10px;
// `;

// export const LoadingContent = styled.div`
//   display: flex;
//   height: 100%;
//   background-color: #343b4a;
//   border-radius: 10px;
//   /* flex-grow: 1; */
// `;

// export const ButtonWrap = styled.div`
//   /* border: 3px solid green; */
// `;

// export const Button = styled.div`
//   width: 100px;
//   border: 3px solid gold;
// `;