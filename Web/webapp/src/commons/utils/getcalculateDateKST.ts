// Intl API로 한국시간 (Asia/Seoul) 기준 포맷

export const getCaluclateUTCToKST = (utcDate: Date) => {
  const formatter = new Intl.DateTimeFormat('ko-KR', {
    timeZone: 'Asia/Seoul',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: false,
  });

  const parts = formatter.formatToParts(utcDate).reduce((acc, part) => {
    if (part.type !== 'literal') acc[part.type] = part.value;
    return acc;
  }, {} as Record<string, string>);

  // 경기 시간대
  const timestamp = `${parts.year}-${parts.month}-${parts.day}${'T'}${
    parts.hour
  }:${parts.minute}:${parts.second}`;

  return timestamp;
};
