user: {
    id:'adfs224k123jkb2jhj',
    name:'사용자이름',
    data: {
        bet: [
            {matchid:'1231dg34gvdw', play:'san vs fra', odd:1.5, amount:30000}
        ]
     point: 125000
    }
}

    game: {
        data: {
            matchid:'sdfsf124sdfsdf',
            schedule: '2024-03-25 18:20',
            isplaying: BEFORE, // ENUM 타입 - BEFORE, PLAYING, FINISH
            home: 'san', 
            away:'bous', 
            odd: {win:1.5, lose:2.3}
        }
    }

    gameresult: {
        data: {
            matchid:'123fdwfw241534ds', //matchid로 경기 조회해서 home, away 비교하여 누가 win, 누가 lose인지 구별
            playinfo : {
                win : 'home', //enum
                lose: 'away' //enum
            }
        }
    }

// export default function Test() {
//   const token =
//     'eyJraWQiOiJRTGRYQmQyeVJucWVwMnlUVTl6bGhvSmhCV1JPYXl0eGV6b1ZZbXJFUGdFPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiJmNDc4NmRlYy1iMDYxLTcwZjUtY2VkYy1jNzhjNjQ0Yzg5NmUiLCJpc3MiOiJodHRwczpcL1wvY29nbml0by1pZHAuYXAtbm9ydGhlYXN0LTIuYW1hem9uYXdzLmNvbVwvYXAtbm9ydGhlYXN0LTJfR1NtNzA5RTRZIiwiY29nbml0bzp1c2VybmFtZSI6ImR1bW15dXNlciIsIm9yaWdpbl9qdGkiOiI4NGI3OWU0Yy04YTAzLTQ4YTAtOTFhOS05ZTY4Njk5ZWFhODAiLCJhdWQiOiI3MG50ZHQwYXVuZWFyN29qb3JoazE1OW5zMiIsImV2ZW50X2lkIjoiMTA0NmQ3YjktYWYyYS00OTI0LTkxOTEtMGQ4YTJmZjJlY2EzIiwidG9rZW5fdXNlIjoiaWQiLCJhdXRoX3RpbWUiOjE3NDM3Mjg3MDgsImV4cCI6MTc0Mzc2NDcwOCwiaWF0IjoxNzQzNzI4NzA4LCJqdGkiOiJiNTIzNTI1NS04YmE2LTQ4MmQtYmYwZS1lZmM1MzMxMzMxNWIiLCJlbWFpbCI6ImR1bW15dXNlckBleGFtcGxlLmNvbSJ9.IYLoFALI2V7Lzh6ISlHpnUEVQsS3-AT-K1FTJYcPbMRw2LR-to05kMKz-_Fu_Lj4JhiWhTSlFCjONH4ToVV9t-g0jkyOQOAouWKlxXzdnV_KlXjBgYk57e16BitTBlwDgGts3rWaJw-bU0fBHO-Zl_VruOoGbzuDIzQWNfRoO1MUghzG89rXkPNmO9pXylIwhG3DRoJHAqgaTmDvGv4h9wxnL3O_EQ7_k3F5tOPfsoeQ8YYe_RQIKbvwuUDinitoRBtfzpHxRNw7NAQZUaexnWlEOMVrZW3_8MlfWKijscVhguIyqnB_KbpR2KwLIEBKakss3GvGCO1uHbMX5raYHw';
//   const testApi = async () => {
//     try {
//       const result = await fetch(
//         'https://23jhoe6ibb.execute-api.ap-northeast-2.amazonaws.com/prod/api/users/test',
//         {
//           method: 'GET',
//           // credentials: 'include',
//           headers: {
//             Authorization: `Bearer ${token}`,
//             'Content-Type': 'application/json',
//             Accept: 'application/json',
//             'X-Requested-With': 'XMLHttpRequest',
//           },
//         }
//       );

//       const data = await result.json();

//       console.log(data, '결과');
//     } catch (err) {
//       console.log(err.message);
//     }
//   };

//   testApi();

//   return <div>Hello</div>;
// }
