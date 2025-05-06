import axios from 'axios';

export interface LogEntry {
  eventSource: string;
  awsRegion: string;
  eventTime: string;
  eventName: string;
  requestParameters: {
    httpMethod: string;
    requestPath: string;
    queryString: string;
    statusCode: number;
  };
  sourceIPAddress: string;
  userAgent: string;
}

export async function sendLog(logEntry: LogEntry) {
  try {
    await axios.post('/api/log', logEntry);
  } catch (err) {
    console.warn('[sendLog] 로그 전송 실패:', err);
  }
}
