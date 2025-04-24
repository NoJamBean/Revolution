import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import * as S from './mypagestyle';
import {
  faBell,
  faCreditCard,
  faUser,
} from '@fortawesome/free-regular-svg-icons';
import { faMoneyBill1Wave } from '@fortawesome/free-solid-svg-icons';
import { useEffect, useState } from 'react';
import Info from './pagesections/info/info';
import PayPoint from './pagesections/paypoint/paypoint';
import Notify from './pagesections/notify/notify';
import { useAuthStore } from '@/src/commons/stores/authstore';
import { useDecodeToken } from '@/src/commons/utils/decodeusertoken';
import MyBetList from './pagesections/betting/betting';
import { useRouter } from 'next/router';

export interface userDataProps {
  id: string;
  nickname: string;
  email: string;
  phoneNumber: string;
  balance: number;
}

const categoryList = [
  { key: 'INFO', icon: faUser, label: '내 정보' },
  { key: 'BETTING', icon: faMoneyBill1Wave, label: '배팅내역' },
  { key: 'PAYMENT', icon: faCreditCard, label: '포인트 결제' },
  { key: 'NOTIFY', icon: faBell, label: '수신함' },
];

export default function MypageComponent() {
  const [selectedCategory, setSelectedCategory] = useState('INFO');
  const [userInfoData, setUserInfoData] = useState<userDataProps | undefined>();
  //   const [isComeFromBet, setIsComeFromBet] = useState(false);

  const router = useRouter();

  const { getDecodedToken } = useDecodeToken();
  const token = useAuthStore((state) => state.token);
  const setToken = useAuthStore((state) => state.setToken);

  useEffect(() => {
    const initToken = async () => {
      const rawToken = localStorage.getItem('auth_token');
      if (!rawToken) return;

      // 토큰 전역으로 먼저 저장 (상태 초기화)
      setToken(rawToken);

      try {
        const tokenUserInfo = await getDecodedToken(rawToken);
        setUserInfoData(tokenUserInfo?.data);

        console.log('token 값 체크합니다', tokenUserInfo);
      } catch (e) {
        console.error('토큰 디코딩 실패:', e);
      }
    };

    initToken();
  }, []);

  useEffect(() => {
    if (!router.isReady) return;

    const isBetParam = router.query.isBet;
    const isBetValue = Array.isArray(isBetParam) ? isBetParam[0] : isBetParam;

    if (isBetValue === 'true') {
      setSelectedCategory('BETTING');
    }
  }, [router.isReady, router.query.isBet]);

  // mypage의 렌더 컴포넌트 결정 함수
  const renderMainContents = () => {
    switch (selectedCategory) {
      case 'INFO':
        return <Info userData={userInfoData} />;
      case 'BETTING':
        return <MyBetList userData={userInfoData} />;
      case 'PAYMENT':
        return <PayPoint />;
      case 'NOTIFY':
        return <Notify />;
      default:
        return null;
    }
  };

  const clickCategoryTab = (item: string) => {
    setSelectedCategory(item);
  };

  return (
    <S.Wrapper>
      <S.SideBar_Left>
        <S.Side_User_InfoBox>
          <S.Usser_ImgBox>
            <S.Profile_img src='/user_profile.png' />
          </S.Usser_ImgBox>
          <S.User_Info>
            <span>{userInfoData?.id}</span>
            <span>{userInfoData?.email}</span>
          </S.User_Info>
        </S.Side_User_InfoBox>
        {categoryList.map((item) => (
          <S.Side_Section_Category
            isClicked={selectedCategory === item.key}
            key={item.key}
            onClick={() => clickCategoryTab(item.key)}
          >
            <FontAwesomeIcon icon={item.icon} />
            <span>{item.label}</span>
          </S.Side_Section_Category>
        ))}
      </S.SideBar_Left>
      <S.MainContents>{renderMainContents()}</S.MainContents>
    </S.Wrapper>
  );
}
