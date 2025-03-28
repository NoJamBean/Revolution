import Header from './header/header';
import * as S from './styles';

export default function Layout({ children }) {
  return (
    <S.Wrapper>
      <Header />
      <S.Child_Wrapper>{children}</S.Child_Wrapper>
    </S.Wrapper>
  );
}
