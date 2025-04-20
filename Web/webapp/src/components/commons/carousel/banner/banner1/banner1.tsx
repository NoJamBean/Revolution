import React from 'react';
import * as S from './banner1style';
import { useModal } from '../../../modal/modalprovider';
import SignUp from '../../../modal/contents/signup';

export default function FootBallCarouselBanner() {
  const { openModal } = useModal();

  return (
    <S.BannerWrapper>
      <S.BannerText>
        <S.Title>
          배팅하라! <br />
          <S.Highlight>당신의 열정을 위해!</S.Highlight>
          <br /> 도전적으로!
        </S.Title>
        <S.Description>신규가입 이벤트기간을 절대 놓치지 마세요!</S.Description>
        <S.CTAButton onClick={() => openModal(SignUp)}>SIGN UP NOW</S.CTAButton>
      </S.BannerText>
      <S.BannerImage />
    </S.BannerWrapper>
  );
}
