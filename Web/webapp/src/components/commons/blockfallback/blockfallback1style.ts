import styled from '@emotion/styled';

export const Wrapper = styled.div<{ isMainAndWidget?: boolean }>`
  width: ${({ isMainAndWidget }) => (isMainAndWidget ? '98.8%' : 'auto')};
  background-color: #2a3f55;
  border: 1px solid #192736;
  border-bottom: none;
  display: flex;
`;

export const Fallback_Img_Box = styled.div`
  flex-grow: 1;
  width: 100%;
`;

export const Fallback_Img = styled.img`
  width: 100%;
  height: 100%;
`;
