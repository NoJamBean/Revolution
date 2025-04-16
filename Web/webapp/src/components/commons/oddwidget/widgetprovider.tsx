import { createContext, useContext, useState } from 'react';

type MatchInfoContextType = {
  homeAwayInfo: any;
  setIsLimit: React.Dispatch<React.SetStateAction<boolean>>;
  isLimit: boolean;
  setDefaultApiData: (data: any, type: string) => any;
  setHomeAwayData: (data: any, type: string) => void;
  apiData: any[];
  setSelectSport: React.Dispatch<React.SetStateAction<string | null>>;
  selectSport: string | null;
};

const MatchInfoContext = createContext<MatchInfoContextType | null>(null);

export const MatchInfoProvider = ({ children }: { children: any }) => {
  const [isLimit, setIsLimit] = useState(true);
  const [apiData, setApiData] = useState([]);
  const [homeAwayInfo, setHomeAwayInfo] = useState({});
  const [selectSport, setSelectSport] = useState<string | null>('FOOTBALL');

  const setDefaultApiData = (data: any, type: string) => {
    // 들어온 데이터 입맛에 맞게 객체형식으로 따로 저장 (전체경기 조회 API 데이터 정제용)

    const modified = data.map((el: any) => {
      if (type === 'FOOTBALL') {
        return {
          id: el.fixture.id,
          date: el.fixture.date,
          league: {
            id: el.league.id,
            name: el.league.name,
            logo: el.league.logo,
            season: el.league.season,
            country: el.league.country,
            flag: el.league.flag,
          },
          home: {
            id: el.teams.home.id,
            logo: el.teams.home.logo,
            name: el.teams.home.name,
          },
          away: {
            id: el.teams.away.id,
            logo: el.teams.away.logo,
            name: el.teams.away.name,
          },
          scores: {
            home: el.goals.home,
            away: el.goals.away,
          },
        };
      }

      if (type === 'BASEBALL') {
        return {
          id: el.id,
          date: el.date,
          league: {
            id: el.league.id,
            name: el.league.name,
            logo: el.league.logo,
            season: el.league.season,
            country: el.country.name,
            flag: el.country.flag,
          },
          home: {
            id: el.teams.home.id,
            logo: el.teams.home.logo,
            name: el.teams.home.name,
          },
          away: {
            id: el.teams.away.id,
            logo: el.teams.away.logo,
            name: el.teams.away.name,
          },
          scores: {
            home: el.scores.home.total,
            away: el.scores.away.total,
          },
        };
      }

      if (type === 'BASKETBALL') {
        return {
          id: el.id,
          date: el.date,
          league: {
            id: el.league.id,
            name: el.league.name,
            logo: el.league.logo,
            season: el.league.season,
            country: el.country.name,
            flag: el.country.flag,
          },
          home: {
            id: el.teams.home.id,
            logo: el.teams.home.logo,
            name: el.teams.home.name,
          },
          away: {
            id: el.teams.away.id,
            logo: el.teams.away.logo,
            name: el.teams.away.name,
          },
          scores: {
            home: el.scores.home.total,
            away: el.scores.away.total,
          },
        };
      }

      if (type === 'ICE HOCKEY') {
        return {
          id: el.id,
          date: el.date,
          league: {
            id: el.league.id,
            name: el.league.name,
            logo: el.league.logo,
            season: el.league.season,
            country: el.country.name,
            flag: el.country.flag,
          },
          home: {
            id: el.teams.home.id,
            logo: el.teams.home.logo,
            name: el.teams.home.name,
          },
          away: {
            id: el.teams.away.id,
            logo: el.teams.away.logo,
            name: el.teams.away.name,
          },
          scores: {
            home: el.scores.home,
            away: el.scores.away,
          },
        };
      }
    });

    setApiData(modified);

    return modified;
  };

  // home, away 각각의 상세정보에 대한 값을 정제하기 위한 API 데이터 정제 메서드
  const setHomeAwayData = (data: any, type: any) => {
    if (type === 'FOOTBALL') {
      const modified = {
        home: {
          league: {
            id: data?.home?.league?.id,
            name: data?.home?.league?.name,
            country: data?.home?.league?.country,
            flag: data?.home?.league?.flag,
            logo: data?.home?.league?.logo,
          },
          team: {
            id: data?.home?.team?.id,
            logo: data?.home?.team?.logo,
            name: data?.home?.team?.name,
          },
          info: {
            total: data?.home?.fixtures?.played?.total,
            win: data?.home?.fixtures?.wins?.total,
            winhome: data?.home?.fixtures?.wins?.home,
            winaway: data?.home?.fixtures?.wins?.away,
            loses: data?.home?.fixtures?.loses?.total,
            loseshome: data?.home?.fixtures?.loses?.home,
            losesaway: data?.home?.fixtures?.loses?.away,

            fortotal: data?.home?.goals?.for?.total?.total,
            forhome: data?.home?.goals?.for?.total?.home,
            foraway: data?.home?.goals?.for?.total?.away,
            againsttotal: data?.home?.goals?.against?.total?.total,
            againsthome: data?.home?.goals?.against?.total?.home,
            againstaway: data?.home?.goals?.against?.total?.away,
          },
        },

        away: {
          league: {
            id: data?.away?.league?.id,
            name: data?.away?.league?.name,
            country: data?.away?.league?.country,
            flag: data?.away?.league?.flag,
            logo: data?.away?.league?.logo,
          },
          team: {
            id: data?.away?.team?.id,
            logo: data?.away?.team?.logo,
            name: data?.away?.team?.name,
          },
          info: {
            total: data?.away?.fixtures?.played?.total,
            win: data?.away?.fixtures?.wins?.total,
            winhome: data?.away?.fixtures?.wins?.home,
            winaway: data?.away?.fixtures?.wins?.away,
            loses: data?.away?.fixtures?.loses?.total,
            loseshome: data?.away?.fixtures?.loses?.home,
            losesaway: data?.away?.fixtures?.loses?.away,

            fortotal: data?.away?.goals?.for?.total?.total,
            forhome: data?.away?.goals?.for?.total?.home,
            foraway: data?.away?.goals?.for?.total?.away,
            againsttotal: data?.away?.goals?.against?.total?.total,
            againsthome: data?.away?.goals?.against?.total?.home,
            againstaway: data?.away?.goals?.against?.total?.away,
          },
        },
      };

      setHomeAwayInfo(modified);
      return;
    }

    if (type === 'BASEBALL') {
      const modified = {
        home: {
          league: {
            id: data?.home?.league?.id,
            name: data?.home?.league?.name,
            country: data?.home?.league?.country,
            flag: data?.home?.league?.flag,
            logo: data?.home?.league?.logo,
          },
          team: {
            id: data?.home?.team?.id,
            logo: data?.home?.team?.logo,
            name: data?.home?.team?.name,
          },
          info: {
            total: data?.home?.fixtures?.played?.total,
            win: data?.home?.fixtures?.wins?.total,
            winhome: data?.home?.fixtures?.wins?.home,
            winaway: data?.home?.fixtures?.wins?.away,
            loses: data?.home?.fixtures?.loses?.total,
            loseshome: data?.home?.fixtures?.loses?.home,
            losesaway: data?.home?.fixtures?.loses?.away,

            fortotal: data?.home?.goals?.for?.total?.total,
            forhome: data?.home?.goals?.for?.total?.home,
            foraway: data?.home?.goals?.for?.total?.away,
            againsttotal: data?.home?.goals?.against?.total?.total,
            againsthome: data?.home?.goals?.against?.total?.home,
            againstaway: data?.home?.goals?.against?.total?.away,
          },
        },

        away: {
          league: {
            id: data?.away?.league?.id,
            name: data?.away?.league?.name,
            country: data?.away?.league?.country,
            flag: data?.away?.league?.flag,
            logo: data?.away?.league?.logo,
          },
          team: {
            id: data?.away?.team?.id,
            logo: data?.away?.team?.logo,
            name: data?.away?.team?.name,
          },
          info: {
            total: data?.away?.fixtures?.played?.total,
            win: data?.away?.fixtures?.wins?.total,
            winhome: data?.away?.fixtures?.wins?.home,
            winaway: data?.away?.fixtures?.wins?.away,
            loses: data?.away?.fixtures?.loses?.total,
            loseshome: data?.away?.fixtures?.loses?.home,
            losesaway: data?.away?.fixtures?.loses?.away,

            fortotal: data?.away?.goals?.for?.total?.total,
            forhome: data?.away?.goals?.for?.total?.home,
            foraway: data?.away?.goals?.for?.total?.away,
            againsttotal: data?.away?.goals?.against?.total?.total,
            againsthome: data?.away?.goals?.against?.total?.home,
            againstaway: data?.away?.goals?.against?.total?.away,
          },
        },
      };

      setHomeAwayInfo(modified);
      return;
    }

    if (type === 'BASKETBALL') {
      const modified = {
        home: {
          league: {
            id: data?.home?.league?.id,
            country: data?.home?.country?.name,
            flag: data?.home?.country?.flag,
            logo: data?.home?.league?.logo,
            name: data?.home?.league?.name,
          },
          team: {
            id: data?.home?.team?.id,
            logo: data?.home?.team?.logo,
            name: data?.home?.team?.name,
          },
          info: {
            total: data?.home?.games?.played?.all,
            win: data?.home?.games?.wins?.all?.total,
            winhome: data?.home?.games?.wins?.home?.total,
            winaway: data?.home?.games?.wins?.away?.total,
            loses: data?.home?.games?.loses?.all?.total,
            loseshome: data?.home?.games?.loses?.home?.total,
            losesaway: data?.home?.games?.loses?.away?.total,

            fortotal: data?.home?.points?.for?.total?.all,
            forhome: data?.home?.points?.for?.total?.home,
            foraway: data?.home?.points?.for?.total?.away,
            againsttotal: data?.home?.points?.against?.total?.all,
            againsthome: data?.home?.points?.against?.total?.home,
            againstaway: data?.home?.points?.against?.total?.away,
          },
        },

        away: {
          league: {
            id: data?.away?.league?.id,
            country: data?.away?.country?.name,
            flag: data?.away?.country?.flag,
            logo: data?.away?.league?.logo,
            name: data?.away?.league?.name,
          },
          team: {
            id: data?.away?.team?.id,
            logo: data?.away?.team?.logo,
            name: data?.away?.team?.name,
          },
          info: {
            total: data?.away?.games?.played?.all,
            win: data?.away?.games?.wins?.all?.total,
            winhome: data?.away?.games?.wins?.home?.total,
            winaway: data?.away?.games?.wins?.away?.total,
            loses: data?.away?.games?.loses?.all?.total,
            loseshome: data?.away?.games?.loses?.home?.total,
            losesaway: data?.away?.games?.loses?.away?.total,

            fortotal: data?.away?.points?.for?.total?.all,
            forhome: data?.away?.points?.for?.total?.home,
            foraway: data?.away?.points?.for?.total?.away,
            againsttotal: data?.away?.points?.against?.total?.all,
            againsthome: data?.away?.points?.against?.total?.home,
            againstaway: data?.away?.points?.against?.total?.away,
          },
        },
      };

      if (type === 'ICE HOCKEY') {
        console.log('trigger!!');
        const modified = {
          home: {
            league: {
              id: data?.home?.league?.id,
              country: data?.home?.country?.name,
              flag: data?.home?.country?.flag,
              logo: data?.home?.league?.logo,
              name: data?.home?.league?.name,
            },
            team: {
              id: data?.home?.team?.id,
              logo: data?.home?.team?.logo,
              name: data?.home?.team?.name,
            },
            info: {
              total: data?.home?.games?.played?.all,
              win: data?.home?.games?.wins?.all?.total,
              winhome: data?.home?.games?.wins?.home?.total,
              winaway: data?.home?.games?.wins?.away?.total,
              loses: data?.home?.games?.loses?.all?.total,
              loseshome: data?.home?.games?.loses?.home?.total,
              losesaway: data?.home?.games?.loses?.away?.total,

              fortotal: data?.home?.goals?.for?.total?.all,
              forhome: data?.home?.goals?.for?.total?.home,
              foraway: data?.home?.goals?.for?.total?.away,
              againsttotal: data?.home?.goals?.against?.total?.all,
              againsthome: data?.home?.goals?.against?.total?.home,
              againstaway: data?.home?.goals?.against?.total?.away,
            },
          },

          away: {
            league: {
              id: data?.away?.league?.id,
              country: data?.away?.country?.name,
              flag: data?.away?.country?.flag,
              logo: data?.away?.league?.logo,
              name: data?.away?.league?.name,
            },
            team: {
              id: data?.away?.team?.id,
              logo: data?.away?.team?.logo,
              name: data?.away?.team?.name,
            },
            info: {
              total: data?.away?.games?.played?.all,
              win: data?.away?.games?.wins?.all?.total,
              winhome: data?.away?.games?.wins?.home?.total,
              winaway: data?.away?.games?.wins?.away?.total,
              loses: data?.away?.games?.loses?.all?.total,
              loseshome: data?.away?.games?.loses?.home?.total,
              losesaway: data?.away?.games?.loses?.away?.total,

              fortotal: data?.away?.goals?.for?.total?.all,
              forhome: data?.away?.goals?.for?.total?.home,
              foraway: data?.away?.goals?.for?.total?.away,
              againsttotal: data?.away?.goals?.against?.total?.all,
              againsthome: data?.away?.goals?.against?.total?.home,
              againstaway: data?.away?.goals?.against?.total?.away,
            },
          },
        };

        setHomeAwayInfo(modified);
        return;
      }
    }
  };

  return (
    <MatchInfoContext.Provider
      value={{
        homeAwayInfo,
        setDefaultApiData,
        setHomeAwayData,
        apiData,
        setSelectSport,
        selectSport,
        isLimit,
        setIsLimit,
      }}
    >
      {children}
    </MatchInfoContext.Provider>
  );
};

export const useMatchInfo = () => {
  const context = useContext(MatchInfoContext);
  if (!context) {
    throw new Error('useMatchInfo must be used within a MatchInfoProvider');
  }
  return context;
};
