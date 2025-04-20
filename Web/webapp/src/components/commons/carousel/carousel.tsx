// components/BannerCarousel/BannerCarousel.tsx
import Slider from 'react-slick';
import * as S from './carouselstyle';
import FootBallCarouselBanner from './banner/banner1/banner1';
import SportsBanner from './banner/banner2/banner2';
import SportsNewADBanner from './banner/banner3/banner3';
import SportsHealthADBanner from './banner/banner4/banner4';

const banners = [
  <FootBallCarouselBanner />,
  <SportsBanner />,
  <SportsNewADBanner />,
  <SportsHealthADBanner />,
];

export default function BannerCarousel() {
  const settings = {
    dots: true,
    infinite: true,
    speed: 1500,
    slidesToShow: 1,
    slidesToScroll: 1,
    autoplay: true,
    autoplaySpeed: 4500,
    arrows: false,
    pauseOnHover: false,
    pauseOnFocus: false,
  };

  return (
    <S.Wrapper>
      <Slider {...settings}>
        {banners.map((Comp, idx) => (
          <S.Slide key={idx}>{Comp}</S.Slide>
        ))}
      </Slider>
    </S.Wrapper>
  );
}
