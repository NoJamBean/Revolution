import { useRouter } from 'next/router';
import axios from 'axios';
import { useEffect, useState } from 'react';

// user: {
//     id:'adfs224k123jkb2jhj',
//     name:'사용자이름',
//     data: {
//         bet: [
//             {matchid:'1231dg34gvdw'}
//         ]
//      point: 125000
//     }
// }

//     game: {
//         data: {
//             matchid:'sdfsf124sdfsdf',
//             schedule: '2024-03-25 18:20',
//             isplaying: BEFORE, // ENUM 타입 - BEFORE, PLAYING, FINISH
//             home: 'san',
//             away:'bous',
//             odd: {win:1.5, lose:2.3}
//         }
//     }

//     gameresult: {
//         data: {
//             matchid:'123fdwfw241534ds', //matchid로 경기 조회해서 home, away 비교하여 누가 win, 누가 lose인지 구별
//             playinfo : {
//                 win : 'home', //enum
//                 lose: 'away' //enum
//             }
//         }
//     }

export default function FaqPage() {
  const router = useRouter();

  const [data, setData] = useState({});

  return <div></div>;
}
