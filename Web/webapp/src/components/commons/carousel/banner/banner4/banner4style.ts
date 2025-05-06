import styled from '@emotion/styled';

export const Wrapper = styled.div`
  position: relative;
  width: 100%;
  height: 450px;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: space-between;
`;

export const Background = styled.div`
  position: absolute;
  inset: 0;
  background-image: url('/banner_bg3.png');
  background-size: cover;
  background-position: center;
  z-index: 0;
`;

export const TextBlock = styled.div`
  position: relative;
  z-index: 2;
  padding-left: 60px;
  max-width: 600px;
  color: #1c1c1c;
  display: flex;
  flex-direction: column;
  gap: 12px;
`;

export const Title = styled.h2`
  font-size: 74px;
  font-weight: 800;
  line-height: 1.2;
  color: #004aad;
`;

export const Description = styled.p`
  font-size: 20px;
  font-weight: 600;
  line-height: 1.6;
  color: #333;

  span {
    color: #004aad;
    font-weight: 800;
  }
`;

export const Character = styled.img`
  position: relative;
  z-index: 2;
  height: 100%;
  object-fit: contain;
  padding-right: 110px;
`;
