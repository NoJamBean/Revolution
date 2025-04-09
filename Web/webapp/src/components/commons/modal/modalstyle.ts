import styled from '@emotion/styled';

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
`;

export const ModalContent = styled.div`
  /* width: 600px; */
  width: ${({ modalType }) => (modalType === 'Login' ? '600px' : '450px')};
  min-height: 400px;
  background-color: white;
`;

export const Content = styled.div`
  border: 2px solid red;
  display: flex;
  height: 100%;
`;

export const ButtonWrap = styled.div`
  border: 3px solid green;
`;

export const Button = styled.div`
  width: 100px;
  border: 3px solid gold;
`;
