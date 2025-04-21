// components/Banner/Banner.style.ts
import styled from '@emotion/styled';

export const Wrapper = styled.div`
  position: relative;
  width: 100%;
  height: 450px;
  background-image: url('/banner_bg2.png');
  background-size: cover;
  background-position: center;
  overflow: hidden;
`;

export const AthleteImg = styled.img`
  position: absolute;
  width: 50%;
  left: 30px;
  bottom: 0;
  z-index: 1;
  pointer-events: none;
  user-select: none;
`;

export const TextBlock = styled.div`
  position: absolute;
  right: 200px;
  top: 50%;
  transform: translateY(-50%);
  z-index: 2;
  display: flex;
  flex-direction: column;
  gap: 14px;
  max-width: 420px;
`;

export const Title = styled.div`
  font-size: 52px;
  font-weight: 900;
  color: #f7e6c5;
  letter-spacing: 1px;
`;

export const DateText = styled.div`
  font-size: 20px;
  font-weight: 700;
  color: #f2b8a0;
`;

export const Description = styled.p`
  width: 460px;
  font-size: 18px;
  font-weight: 500;
  line-height: 1.5;
  color: #f2f2f2;
`;
