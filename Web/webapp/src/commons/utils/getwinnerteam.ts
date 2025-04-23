export const getWinner = (homescore: number, awayscore: number) => {
  console.log('체크합시다 위너를', homescore, awayscore);

  if (homescore > awayscore) return 'HOME';

  if (homescore < awayscore) return 'AWAY';

  return 'DRAW';
};
