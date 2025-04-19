export const useGetDateandTime = () => {
  const getDate = (timezone: string) => {
    const date = new Date(timezone);

    const koreaDate = new Date(date.getTime() + 9 * 60 * 60 * 1000);

    const month = String(koreaDate.getMonth() + 1).padStart(2, '0');
    const day = String(koreaDate.getDate()).padStart(2, '0');

    return `${month}-${day}`;
  };

  const getTime = (timezone: string) => {
    const date = new Date(timezone);

    const koreaDate = new Date(
      date.toLocaleString('en-US', { timeZone: 'Asia/Seoul' })
    );

    const hour = String(koreaDate.getHours()).padStart(2, '0');
    const minute = String(koreaDate.getMinutes()).padStart(2, '0');

    return `${hour}:${minute}`;
  };

  return { getDate, getTime };
};
