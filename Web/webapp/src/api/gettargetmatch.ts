import axios from 'axios';

export const getTargetedMatchInfo = async (
  targetId: any,
  sportType: string
) => {
  try {
    if (sportType === 'FOOTBALL') {
      // 1. 지정된 경기 ID로 경기 정보 가져오기
      const leagueTeam = await axios.get(
        'https://v3.football.api-sports.io/fixtures',
        {
          params: { id: targetId },
          headers: {
            'x-apisports-key': process.env.NEXT_PUBLIC_SPORTS_API_KEY,
          },
        }
      );

      const game = leagueTeam?.data?.response?.[0];

      const leagueId = game?.league?.id;
      const homeId = game?.teams?.home?.id;
      const awayId = game?.teams?.away?.id;

      // 2. 홈팀 통계 정보 요청
      const homeStat = await axios.get(
        'https://v3.football.api-sports.io/teams/statistics',
        {
          params: {
            league: leagueId,
            season: 2023, // 무료 plan에서 제공 가능한 시즌
            team: homeId,
          },
          headers: {
            'x-apisports-key': process.env.NEXT_PUBLIC_SPORTS_API_KEY,
          },
        }
      );

      // 3. 어웨이팀 통계 정보 요청
      const awayStat = await axios.get(
        'https://v3.football.api-sports.io/teams/statistics',
        {
          params: {
            league: leagueId,
            season: 2023,
            team: awayId,
          },
          headers: {
            'x-apisports-key': process.env.NEXT_PUBLIC_SPORTS_API_KEY,
          },
        }
      );

      return {
        home: homeStat.data.response,
        away: awayStat.data.response,
      };
    }

    if (sportType === 'BASEBALL') {
      // 1. 지정된 경기 ID로 경기 정보 가져오기
      const leagueTeam = await axios.get(
        'https://v1.baseball.api-sports.io/games',
        {
          params: { id: targetId },
          headers: {
            'x-apisports-key': process.env.NEXT_PUBLIC_SPORTS_API_KEY,
          },
        }
      );

      const game = leagueTeam?.data?.response?.[0];

      const leagueId = game?.league?.id;
      const homeId = game?.teams?.home?.id;
      const awayId = game?.teams?.away?.id;

      console.log(leagueId, homeId, awayId, 1111);

      // 2. 홈팀 통계 정보 요청
      const homeStat = await axios.get(
        'https://v1.baseball.api-sports.io/teams/statistics',
        {
          params: {
            league: leagueId,
            season: 2023, // 무료 plan에서 제공 가능한 시즌
            team: homeId,
          },
          headers: {
            'x-apisports-key': process.env.NEXT_PUBLIC_SPORTS_API_KEY,
          },
        }
      );

      console.log(homeStat, 'homehomehome');

      // 3. 어웨이팀 통계 정보 요청
      const awayStat = await axios.get(
        'https://v1.baseball.api-sports.io/teams/statistics',
        {
          params: {
            league: leagueId,
            season: 2023,
            team: awayId,
          },
          headers: {
            'x-apisports-key': process.env.NEXT_PUBLIC_SPORTS_API_KEY,
          },
        }
      );

      console.log(awayStat, 'awayawayaway');

      return {
        home: homeStat.data.response,
        away: awayStat.data.response,
      };
    }

    if (sportType === 'BASKETBALL') {
      // 1. 지정된 경기 ID로 경기 정보 가져오기
      const leagueTeam = await axios.get(
        'https://v1.basketball.api-sports.io/games',
        {
          params: { id: targetId },
          headers: {
            'x-apisports-key': process.env.NEXT_PUBLIC_SPORTS_API_KEY,
          },
        }
      );

      const game = leagueTeam?.data?.response?.[0];

      const leagueId = game?.league?.id;
      const homeId = game?.teams?.home?.id;
      const awayId = game?.teams?.away?.id;

      // console.log(game, leagueId, homeId, awayId, '12321312321312312');

      // 2. 홈팀 통계 정보 요청
      const homeStat = await axios.get(
        'https://v1.basketball.api-sports.io/statistics',
        {
          params: {
            league: leagueId,
            season: '2022-2023', // 무료 plan에서 제공 가능한 시즌
            team: homeId,
          },
          headers: {
            'x-apisports-key': process.env.NEXT_PUBLIC_SPORTS_API_KEY,
          },
        }
      );

      // 3. 어웨이팀 통계 정보 요청
      const awayStat = await axios.get(
        'https://v1.basketball.api-sports.io/statistics',
        {
          params: {
            league: leagueId,
            season: '2022-2023',
            team: awayId,
          },
          headers: {
            'x-apisports-key': process.env.NEXT_PUBLIC_SPORTS_API_KEY,
          },
        }
      );

      return {
        home: homeStat.data.response,
        away: awayStat.data.response,
      };
    }

    if (sportType === 'ICEHOCKEY') {
      // 1. 경기 ID로부터 경기 정보 요청
      const leagueTeam = await axios.get(
        'https://v1.hockey.api-sports.io/games', // 경기 정보 API (football은 fixtures, hockey는 games로 추정)
        {
          params: { id: targetId },
          headers: {
            'x-apisports-key': process.env.NEXT_PUBLIC_SPORTS_API_KEY,
          },
        }
      );

      const game = leagueTeam?.data?.response?.[0];

      const leagueId = game?.league?.id;
      const homeId = game?.teams?.home?.id;
      const awayId = game?.teams?.away?.id;

      // 2. 홈팀 통계 정보 요청
      const homeStat = await axios.get(
        'https://v1.hockey.api-sports.io/teams/statistics',
        {
          params: {
            league: leagueId,
            season: 2023, // 무료 plan에서 허용되는 시즌
            team: homeId,
          },
          headers: {
            'x-apisports-key': process.env.NEXT_PUBLIC_SPORTS_API_KEY,
          },
        }
      );

      // 3. 어웨이팀 통계 정보 요청
      const awayStat = await axios.get(
        'https://v1.hockey.api-sports.io/teams/statistics',
        {
          params: {
            league: leagueId,
            season: 2023,
            team: awayId,
          },
          headers: {
            'x-apisports-key': process.env.NEXT_PUBLIC_SPORTS_API_KEY,
          },
        }
      );

      return {
        home: homeStat.data.response,
        away: awayStat.data.response,
      };
    }

    if (sportType === 'HANDBALL') {
      // 1. 경기 ID로부터 경기 정보 요청
      const leagueTeam = await axios.get(
        'https://v1.handball.api-sports.io/games', // 경기 정보 API (football은 fixtures, hockey는 games로 추정)
        {
          params: { id: targetId },
          headers: {
            'x-apisports-key': process.env.NEXT_PUBLIC_SPORTS_API_KEY,
          },
        }
      );

      const game = leagueTeam?.data?.response?.[0];

      const leagueId = game?.league?.id;
      const homeId = game?.teams?.home?.id;
      const awayId = game?.teams?.away?.id;

      // 2. 홈팀 통계 정보 요청
      const homeStat = await axios.get(
        'https://v1.handball.api-sports.io/teams/statistics',
        {
          params: {
            league: leagueId,
            season: 2023, // 무료 plan에서 허용되는 시즌
            team: homeId,
          },
          headers: {
            'x-apisports-key': process.env.NEXT_PUBLIC_SPORTS_API_KEY,
          },
        }
      );

      // 3. 어웨이팀 통계 정보 요청
      const awayStat = await axios.get(
        'https://v1.handball.api-sports.io/teams/statistics',
        {
          params: {
            league: leagueId,
            season: 2023,
            team: awayId,
          },
          headers: {
            'x-apisports-key': process.env.NEXT_PUBLIC_SPORTS_API_KEY,
          },
        }
      );

      return {
        home: homeStat.data.response,
        away: awayStat.data.response,
      };
    }
  } catch (error) {
    console.error('축구 데이터 요청 에러:', error);
  }
};
