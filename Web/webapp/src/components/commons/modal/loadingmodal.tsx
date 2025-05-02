import { useEffect, useState } from 'react';
import { createPortal } from 'react-dom';
import * as S from './loadingmodalstyle';
import { useModal } from './modalprovider';

type ModalProps = {
  content: React.ComponentType<any> | null;
};

export default function LoadingModal({ content: Content }: ModalProps) {
  const { modalType, modalContent: Component, isLoading } = useModal();

  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true); // 클라이언트 사이드에서만 렌더 보장
  }, []);

  if (!mounted || typeof window === 'undefined') return null;

  return createPortal(
    <S.LoadingModalOverlay isLoading={isLoading}>
      <S.LoadingModalContent modalType={modalType} isLoading={isLoading}>
        <S.LoadingContent>{Component && <Component />}</S.LoadingContent>
      </S.LoadingModalContent>
    </S.LoadingModalOverlay>,
    document.body // ✅ 뷰포트 전체 기준으로 이동
  );
}
