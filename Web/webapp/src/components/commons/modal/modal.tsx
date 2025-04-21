import * as S from './modalstyle';
import { useModal } from './modalprovider';

type ModalProps = {
  content: React.ComponentType<any> | null;
};

export default function Modal({ content: Content }: ModalProps) {
  const {
    modalType,
    modalTypeForAnim,
    isModalOpen,
    modalContent: Component,
  } = useModal();

  return (
    <S.ModalOverlay>
      <S.ModalContent
        modalType={modalTypeForAnim || 'Signup'}
        isModalOpen={isModalOpen}
      >
        <S.Content>{Component && <Component />}</S.Content>
      </S.ModalContent>
    </S.ModalOverlay>
  );
}
