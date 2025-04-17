import { createContext, useState, useContext, useEffect } from 'react';
import Modal from './modal';
import LoadingModal from './loadingmodal';

interface ModalContextType {
  isModalOpen: boolean;
  openModal: (content: any) => void;
  closeModal: () => void;
  changeModalContent: (content: any) => void;
  setIsLoading: React.Dispatch<React.SetStateAction<boolean>>;
  isLoading: boolean;
  modalContent: React.ComponentType<any> | null;
  modalType: string;
}

const ModalContext = createContext<ModalContextType | undefined>(undefined);

export const ModalProvider = ({ children }: { children: any }) => {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalContent, setModalContent] = useState(() => null);
  const [modalType, setModalType] = useState('Login');
  const [isLoading, setIsLoading] = useState(false);
  const [isVisible, setIsVisible] = useState(false);

  const openModal = (content: any) => {
    setModalContent(() => content);
    setModalType(content.name);
    setIsModalOpen(true);

    document.body.style.overflow = 'hidden';
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setIsLoading(false);
    setModalType('Login');
    setModalContent(() => null);

    console.log('여기서 봅니다요~~~~~', isLoading);

    document.body.style.overflow = '';
  };

  const changeModalContent = (content: any) => {
    setModalContent(() => content);
    setModalType(content.name);
  };

  useEffect(() => {
    if (isLoading) {
      setIsVisible(true); // 로딩 시작 → 보여주기
    } else {
      const timeout = setTimeout(() => {
        setIsVisible(false); // 로딩 끝나고 애니 후 제거
      }, 300); // 애니메이션 시간과 맞춤
      return () => clearTimeout(timeout);
    }
  }, [isLoading]);

  return (
    <ModalContext.Provider
      value={{
        isModalOpen,
        openModal,
        closeModal,
        changeModalContent,
        modalContent,
        modalType,
        setIsLoading,
        isLoading,
      }}
    >
      {children}
      {isModalOpen && <Modal content={modalContent} />}
      {isVisible && (
        <LoadingModal content={modalContent} isLoading={isLoading} />
      )}
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
