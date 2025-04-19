import axios from 'axios';
import { useRouter } from 'next/router';

export function useDecodeToken() {
  const router = useRouter();

  const getDecodedToken = async (token: string) => {
    // const response = await axios.get('http://52.78.153.99/api/users/me', {
    //   headers: {
    //     'Content-Type': 'application/json',
    //     Authorization: `Bearer ${token}`,
    //   },
    // });
    // return response;
  };

  return { getDecodedToken };
}

// {
//     "id": "user123",
//     "type": "soccer",
//     "gameDate": "2025-04-20T19:00:00",
//     "home": "ManCity",
//     "away": "Liverpool",
//     "wdl": "win",
//     "odds": 1.85,
//     "price": 10000,
//     "status": "active"
//   }
