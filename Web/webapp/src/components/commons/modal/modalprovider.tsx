import { createContext, useState, useContext } from 'react';
import Modal from './modal';

const ModalContext = createContext('default');

export const ModalProvider = ({ children }) => {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalContent, setModalContent] = useState(() => null);
  const [modalType, setModalType] = useState('Login');

  const openModal = (content) => {
    setModalContent(() => content);
    setModalType(content.name);
    setIsModalOpen(true);

    document.body.style.overflow = 'hidden';
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setModalType('Login');
    setModalContent(() => null);

    document.body.style.overflow = '';
  };

  const changeModalContent = (content) => {
    setModalContent(() => content);
    setModalType(content.name);
  };

  return (
    <ModalContext.Provider
      value={{
        isModalOpen,
        openModal,
        closeModal,
        changeModalContent,
        modalContent,
        modalType,
      }}
    >
      {children}
      {isModalOpen && <Modal content={modalContent} />}
    </ModalContext.Provider>
  );
};

// 모달 hook export
export const useModal = () => {
  return useContext(ModalContext);
};
