import * as S from './modalstyle';
import { useModal } from './modalprovider';

export default function Modal() {
  const { modalType, isModalOpen, modalContent: Component } = useModal();

  return (
    <S.ModalOverlay>
      <S.ModalContent modalType={modalType}>
        <S.Content>
          <Component />
        </S.Content>
      </S.ModalContent>
    </S.ModalOverlay>
  );
}
