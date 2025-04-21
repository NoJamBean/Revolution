import * as S from './loadingmodalstyle';
import { useModal } from './modalprovider';

type ModalProps = {
  content: React.ComponentType<any> | null;
};

export default function LoadingModal({ content: Content }: ModalProps) {
  const {
    modalType,
    // isModalOpen,
    modalContent: Component,
    isLoading,
  } = useModal();

  return (
    <S.LoadingModalOverlay isLoading={isLoading}>
      <S.LoadingModalContent modalType={modalType} isLoading={isLoading}>
        <S.LoadingContent>{Component && <Component />}</S.LoadingContent>
      </S.LoadingModalContent>
    </S.LoadingModalOverlay>
  );
}
