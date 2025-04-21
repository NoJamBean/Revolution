import axios from 'axios';
import { useRouter } from 'next/router';

export function useDecodeToken() {
  const router = useRouter();

  const getDecodedToken = async (token: string) => {
    console.log('tokentoken', token);

    try {
      const response = await axios.get(
        `${process.env.NEXT_PUBLIC_BACKEND_API_ENDPOINT}/api/users/me`,
        {
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${token}`,
          },
        }
      );

      return response;
    } catch (err) {
      console.log('에러요', err);
    }
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
