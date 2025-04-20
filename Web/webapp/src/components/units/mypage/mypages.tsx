import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import * as S from './mypagestyle';
import {
  faBell,
  faCreditCard,
  faUser,
} from '@fortawesome/free-regular-svg-icons';
import { faMoneyBill1Wave } from '@fortawesome/free-solid-svg-icons';
import { useState } from 'react';
import Info from './pagesections/info/info';
import MyBetList from './pagesections/\bbetting/betting';
import PayPoint from './pagesections/paypoint/paypoint';
import Notify from './pagesections/notify/notify';

const categoryList = [
  { key: 'INFO', icon: faUser, label: '내 정보' },
  { key: 'BETTING', icon: faMoneyBill1Wave, label: '배팅내역' },
  { key: 'PAYMENT', icon: faCreditCard, label: '포인트 결제' },
  { key: 'NOTIFY', icon: faBell, label: '수신함' },
];

export default function MypageComponent() {
  const [selectedCategory, setSelectedCategory] = useState('INFO');

  const renderMainContents = () => {
    switch (selectedCategory) {
      case 'INFO':
        return <Info />;
      case 'BETTING':
        return <MyBetList />;
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
            <span>Songseop</span>
            <span>manner9945@naver.com</span>
          </S.User_Info>
        </S.Side_User_InfoBox>
        {/* <S.Side_Section_Category>
          <FontAwesomeIcon icon={faUser} />
          <span>내 정보</span>
        </S.Side_Section_Category>
        <S.Side_Section_Category>
          <FontAwesomeIcon icon={faMoneyBill1Wave} />
          <span>배팅내역</span>
        </S.Side_Section_Category>
        <S.Side_Section_Category>
          <FontAwesomeIcon icon={faCreditCard} />
          <span>포인트 결제</span>
        </S.Side_Section_Category>
        <S.Side_Section_Category>
          <FontAwesomeIcon icon={faBell} />
          <span>수신함</span>
        </S.Side_Section_Category> */}
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
