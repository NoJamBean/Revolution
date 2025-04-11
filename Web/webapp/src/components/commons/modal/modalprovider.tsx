import { createContext, useState, useContext } from 'react';
import Modal from './modal';

interface ModalContextType {
  isModalOpen: boolean;
  openModal: (content: any) => void;
  closeModal: () => void;
  changeModalContent: (content: any) => void;
  modalContent: React.ComponentType<any> | null;
  modalType: string;
}

const ModalContext = createContext<ModalContextType | undefined>(undefined);

export const ModalProvider = ({ children }: { children: any }) => {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalContent, setModalContent] = useState(() => null);
  const [modalType, setModalType] = useState('Login');

  const openModal = (content: any) => {
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

  const changeModalContent = (content: any) => {
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
export const useModal = (): ModalContextType => {
  const context = useContext(ModalContext);
  if (!context) {
    throw new Error('useModal은 ModalProvider 안에서만 써야 함');
  }
  return context;
};
