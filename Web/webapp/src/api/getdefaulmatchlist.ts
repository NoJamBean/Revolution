import axios from 'axios';
import { useModal } from '../components/commons/modal/modalprovider';

// 전체 경기 리스트 조회 (종목별)
export const getFootballMatchList = async () => {
  const date = new Date();
  const formattedDate = date.toISOString().split('T')[0];

  try {
    const response = await axios.get(
      'https://v3.football.api-sports.io/fixtures',
      {
        params: { date: formattedDate }, // 원하는 날짜
        headers: {
          'x-apisports-key': process.env.NEXT_PUBLIC_SPORTS_API_KEY,
        },
      }
    );

    // console.log(response, 32312);
    if (response.data.errors.length > 0) return [];

    // throw Error(response.data.errors.requests);
    const playMatchList = response.data.response;
    return playMatchList;
  } catch (err) {
    console.log(err, 'dsfsdfs');
  }
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

  console.log(response, '대기중');
  if (response.data.errors.length > 0) return [];
  // throw Error(response.data.errors.requests);

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

  if (response.data.errors.length > 0) return [];
  // throw Error(response.data.errors.requests);

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

  if (response.data.errors.length > 0) return [];
  // throw Error(response.data.errors.requests);

  const playMatchList = response.data.response;

  return playMatchList;
};

export const getHandBallMatchList = async () => {
  const date = new Date();
  const formattedDate = date.toISOString().split('T')[0];

  const response = await axios.get('https://v1.handball.api-sports.io/games', {
    params: {
      date: formattedDate,
    }, // 원하는 날짜
    headers: {
      'x-apisports-key': process.env.NEXT_PUBLIC_SPORTS_API_KEY,
    },
  });

  if (response.data.errors.length > 0) return [];
  // throw Error(response.data.errors.requests);

  const playMatchList = response.data.response;

  return playMatchList;
};

//
//
//
//
//
