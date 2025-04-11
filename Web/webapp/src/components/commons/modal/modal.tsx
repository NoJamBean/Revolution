import * as S from './modalstyle';
import { useModal } from './modalprovider';

type ModalProps = {
  content: React.ComponentType<any> | null;
};

export default function Modal({ content: Content }: ModalProps) {
  const { modalType, isModalOpen, modalContent: Component } = useModal();

  return (
    <S.ModalOverlay>
      <S.ModalContent modalType={modalType}>
        <S.Content>{Component ? <Component /> : null}</S.Content>
      </S.ModalContent>
    </S.ModalOverlay>
  );
}
