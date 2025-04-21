import * as S from './blockfallback1style';

interface Props {
  height?: number;
  isMainAndWidget?: boolean;
}
export default function BlockFallbackLimitAPI({
  height = 300,
  isMainAndWidget,
}: Props) {
  return (
    <S.Wrapper style={{ height }} isMainAndWidget={isMainAndWidget}>
      <S.Fallback_Img_Box>
        <S.Fallback_Img src='/blockfallback1.png' />
      </S.Fallback_Img_Box>
    </S.Wrapper>
  );
}
