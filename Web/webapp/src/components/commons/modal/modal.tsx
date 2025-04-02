import * as S from './modalstyle';
import { useModal } from './modalprovider';

export default function Modal() {
  const { closeModal, modalContent } = useModal();

  return (
    <S.ModalOverlay>
      <S.ModalContent>
        {modalContent}
        <S.Button onClick={closeModal}>닫기</S.Button>
      </S.ModalContent>
    </S.ModalOverlay>
  );
}
