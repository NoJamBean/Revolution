// SportsBanner.styles.ts
import styled from '@emotion/styled';

export const BannerWrapper = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 48px 60px;
  background: url('/banner_bg1.png') no-repeat center;
  background-size: cover;
  color: #f2f2f2;
  width: 100%;
  height: 450px;
  position: relative;
  overflow: hidden;
`;

export const BannerText = styled.div`
  z-index: 2;
  max-width: 45%;
`;

export const Title = styled.h1`
  font-size: 43px;
  line-height: 1.4;
  margin: 0;
  font-weight: 900;
  background: linear-gradient(90deg, #84fab0, #8fd3f4);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
`;

export const Description = styled.p`
  margin-top: 16px;
  font-size: 18px;
  line-height: 1.5;
  color: #f0f0f0;
`;

export const BannerFigure = styled.div`
  position: absolute;
  right: 0;
  top: 0;
  bottom: 0;
  width: 54%;
  background: url('/carousel3.png') no-repeat center;
  background-size: contain;
  z-index: 2;
`;
