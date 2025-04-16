import axios from 'axios';

export const getFootballMatchList = async () => {
  const date = new Date();
  const formattedDate = date.toISOString().split('T')[0];

  const response = await axios.get(
    'https://v3.football.api-sports.io/fixtures',
    {
      params: { date: formattedDate }, // 원하는 날짜
      headers: {
        'x-apisports-key': process.env.NEXT_PUBLIC_SPORTS_API_KEY,
      },
    }
  );

  if (response.data.errors.length > 0)
    throw Error(response.data.errors.requests);
  const playMatchList = response.data.response;

  console.log(response.data, 'fdsfsdf');
  return playMatchList;
};

export const getBaseballlMatchList = async () => {
  const date = new Date();
  const formattedDate = date.toISOString().split('T')[0];

  const response = await axios.get('https://v1.baseball.api-sports.io/games', {
    params: {
      date: formattedDate,
    }, // 원하는 날짜
    headers: {
      'x-apisports-key': process.env.NEXT_PUBLIC_SPORTS_API_KEY,
    },
  });

  if (response.data.errors.length > 0)
    throw Error(response.data.errors.requests);

  const playMatchList = response.data.response;

  return playMatchList;
};

export const getBasketballMatchList = async () => {
  const date = new Date();
  const formattedDate = date.toISOString().split('T')[0];

  const response = await axios.get(
    'https://v1.basketball.api-sports.io/games',
    {
      params: {
        date: formattedDate,
      }, // 원하는 날짜
      headers: {
        'x-apisports-key': process.env.NEXT_PUBLIC_SPORTS_API_KEY,
      },
    }
  );

  if (response.data.errors.length > 0)
    throw Error(response.data.errors.requests);

  const playMatchList = response.data.response;

  return playMatchList;
};

export const getIceHockeyMatchList = async () => {
  const date = new Date();
  const formattedDate = date.toISOString().split('T')[0];

  const response = await axios.get('https://v1.hockey.api-sports.io/games', {
    params: {
      date: formattedDate,
    }, // 원하는 날짜
    headers: {
      'x-apisports-key': process.env.NEXT_PUBLIC_SPORTS_API_KEY,
    },
  });

  console.log('응답확인', response);

  if (response.data.errors.length > 0)
    throw Error(response.data.errors.requests);

  const playMatchList = response.data.response;

  return playMatchList;
};
