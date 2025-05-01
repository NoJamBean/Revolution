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
  const [modalContent, setModalContent] = useState(() => null);
  const [modalType, setModalType] = useState('Login');
  const [hasMounted, setHasMounted] = useState(false);

  // 애니메이션 계산용 state
  const [isLoading, setIsLoading] = useState(false);
  const [modalTypeForAnim, setModalTypeForAnim] = useState<
    'Login' | 'Signup' | null
  >(null);

  const [isVisible, setIsVisible] = useState(false);
  const [isModalVisible, setIsModalVisible] = useState(false);

  const openModal = (content: any) => {
    console.log('모달을 체크합니다', content.name);

    if (content.name === 'Loading') {
      setIsLoading(true);
      setModalContent(() => content);
      setModalType(content.name);
      setModalTypeForAnim(content.name);

      return;
    }

    setIsModalOpen(true);
    setIsModalVisible(true);
    setModalContent(() => content);
    setModalType(content.name);
    setModalTypeForAnim(content.name);

    document.body.style.overflow = 'hidden';
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setIsLoading(false);

    // 모달 제거 지연시키기 (애니메이션 이후 동작)
    setTimeout(() => {
      setIsModalVisible(false);
      setModalContent(() => null);

      setModalType('Login');
      setModalTypeForAnim(null);
    }, 500);

    console.log('여기서 봅니다요~~~~~', isLoading);

    document.body.style.overflow = '';
  };

  const changeModalContent = (content: any) => {
    setModalContent(() => content);
    setModalType(content.name);
    setModalTypeForAnim(content.name);
  };

  // loading modal
  useEffect(() => {
    if (isLoading) {
      setIsVisible(true); // 로딩 시작 → 보여주기
    } else {
      const timeout = setTimeout(() => {
        setIsVisible(false); // 로딩 끝나고 애니 후 제거
        setModalTypeForAnim(null);
      }, 500); // 애니메이션 시간과 맞춤
      return () => clearTimeout(timeout);
    }
  }, [isLoading]);

  useEffect(() => {
    if (isModalVisible) {
      setIsModalOpen(true); // 다음 렌더에서 opacity/transform 트리거
    }
  }, [isModalVisible]);

  useEffect(() => {
    setHasMounted(true);
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
      {isModalVisible && <Modal content={modalContent} />}
      {hasMounted && isVisible && <LoadingModal content={modalContent} />}
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
