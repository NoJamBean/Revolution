import styled from '@emotion/styled';

export const BannerWrapper = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 40px;
  background-color: #1a1a1a;
  background-image: radial-gradient(
      circle at 30% 50%,
      rgba(255, 204, 77, 0.1),
      transparent 70%
    ),
    linear-gradient(to bottom, rgba(0, 0, 0, 0.4), transparent 40%),
    linear-gradient(to top, rgba(0, 0, 0, 0.4), transparent 40%),
    linear-gradient(to left, rgba(0, 0, 0, 0.2), transparent 50%);
  color: #d8e4f0;
  width: 100%;
  height: 450px;
  position: relative;
  overflow: hidden;
  flex: 1;
`;

export const BannerText = styled.div`
  z-index: 2;
  flex-basis: 45%;
  flex-shrink: 0;
`;

export const Title = styled.h1`
  font-size: 42px;
  line-height: 1.2;
  margin: 0;
  font-weight: 800;
`;

export const Highlight = styled.span`
  color: #e6be3a;
`;

export const Description = styled.p`
  margin-top: 16px;
  font-size: 18px;
  opacity: 0.85;
`;

export const CTAButton = styled.button`
  margin-top: 20px;
  background-color: #e6be3a;
  color: #1e2f3f;
  border: none;
  padding: 12px 24px;
  font-size: 16px;
  font-weight: 700;
  border-radius: 6px;
  cursor: pointer;
  transition: background-color 0.2s ease;

  &:hover {
    background-color: #d3ab32;
  }
`;

export const BannerImage = styled.div`
  width: 55%;
  position: absolute;
  right: 0;
  top: 0;
  bottom: 0;
  flex: 1;
  background: url('/carousel2.png') no-repeat center;
  background-size: cover;
  filter: brightness(1.05);
  z-index: 1;
`;
