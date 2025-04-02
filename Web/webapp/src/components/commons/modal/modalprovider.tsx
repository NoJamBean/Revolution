import { createContext, useState, useContext } from 'react';
import Modal from './modal';

const ModalContext = createContext('default');

export const ModalProvider = ({ children }) => {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalContent, setModalContent] = useState(null);

  const openModal = (content) => {
    setModalContent(content);
    setIsModalOpen(true);

    document.body.style.overflow = 'hidden';
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setModalContent(null);

    document.body.style.overflow = '';
  };

  return (
    <ModalContext.Provider
      value={{ isModalOpen, openModal, closeModal, modalContent }}
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
