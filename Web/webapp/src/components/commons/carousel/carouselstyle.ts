import styled from '@emotion/styled';

export const Wrapper = styled.div`
  width: 100%;
  height: 450px;
  overflow: hidden;

  .slick-slider,
  .slick-list,
  .slick-track {
    width: 100%;
  }

  .slick-dots {
    bottom: 20px;

    li button:before {
      color: #ffffff;
      opacity: 0.5;
      font-size: 10px;
      transition: all 0.3s ease;
    }

    li.slick-active button:before {
      opacity: 1;
      color: #ffed00;
      text-shadow: 0 0 0.3px #ffed00, 0 0 0.7px #ffe100, 0 0 1.2px #ffc800;
      opacity: 1;
      font-size: 14px;
    }
  }
`;

export const Slide = styled.div`
  width: 100%;
  height: 100%;
  display: flex;
`;
