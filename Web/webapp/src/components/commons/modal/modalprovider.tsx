import { createContext, useState, useContext, useEffect } from 'react';
import Modal from './modal';
import LoadingModal from './loadingmodal';
import Loading from './contents/loading';

interface ModalContextType {
  isModalOpen: boolean;
  openModal: (content: any) => void;
  closeModal: () => void;
  changeModalContent: (content: any) => void;
  setIsLoading: React.Dispatch<React.SetStateAction<boolean>>;
  isLoading: boolean;
  modalContent: React.ComponentType<any> | null;
  modalType: string;
  modalTypeForAnim: string | null;
}

const ModalContext = createContext<ModalContextType | undefined>(undefined);

export const ModalProvider = ({ children }: { children: any }) => {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalContent, setModalContent] =
    useState<React.ComponentType<any> | null>(null);
  const [modalType, setModalType] = useState('');
  const [modalTypeForAnim, setModalTypeForAnim] = useState<string | null>(null);
  const [isLayoutReady, setIsLayoutReady] = useState(false);

  const [isLoading, setIsLoading] = useState(false);
  const [isVisible, setIsVisible] = useState(false);
  const [isModalVisible, setIsModalVisible] = useState(false);

  const openModal = (content: any) => {
    const isLoadingComponent = content?.name === 'Loading';

    if (isLoadingComponent) {
      setIsModalOpen(false);
      setIsModalVisible(false);
      setModalContent(() => Loading);
      setModalType('Loading');
      setModalTypeForAnim('Loading');
      setIsLoading(true);
      return;
    }

    setIsModalOpen(true);
    setIsModalVisible(true);
    setModalContent(() => content);
    setModalType(content.name || '');
    setModalTypeForAnim(content.name || '');

    document.body.style.overflow = 'hidden';
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setIsLoading(false);

    setTimeout(() => {
      setIsModalVisible(false);
      setModalContent(null);
      setModalType('');
      setModalTypeForAnim(null);
    }, 500);

    document.body.style.overflow = '';
  };

  const changeModalContent = (content: any) => {
    setModalContent(() => content);
    setModalType(content.name || '');
    setModalTypeForAnim(content.name || '');
  };

  useEffect(() => {
    if (isLoading) {
      setIsVisible(true);
    } else {
      const timeout = setTimeout(() => {
        setIsVisible(false);
        setModalTypeForAnim(null);
      }, 500);
      return () => clearTimeout(timeout);
    }
  }, [isLoading]);

  useEffect(() => {
    if (isModalVisible) {
      setIsModalOpen(true);
    }
  }, [isModalVisible]);

  useEffect(() => {
    const checkLayoutReady = () => {
      const el = document.getElementById('layout-wrapper');
      if (el) setIsLayoutReady(true);
      else requestAnimationFrame(checkLayoutReady);
    };
    checkLayoutReady();
  }, []);

  return (
    <ModalContext.Provider
      value={{
        isModalOpen,
        openModal,
        closeModal,
        changeModalContent,
        modalContent,
        modalType,
        modalTypeForAnim,
        setIsLoading,
        isLoading,
      }}
    >
      {children}

      {/* 일반 모달 */}
      {isModalVisible && modalType !== 'Loading' && modalContent && (
        <Modal content={modalContent} />
      )}

      {/* 로딩 모달 */}
      {isLayoutReady && isLoading && modalType === 'Loading' && (
        <LoadingModal content={Loading} />
      )}
    </ModalContext.Provider>
  );
};

export const useModal = (): ModalContextType => {
  const context = useContext(ModalContext);
  if (!context) {
    throw new Error('useModal은 ModalProvider 안에서만 써야 함');
  }
  return context;
};
