// utils/logger.ts

interface LogEntry {
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

export const logBuffer: { Records: LogEntry[] } = {
  Records: [],
};

export function addLog(entry: LogEntry) {
  logBuffer.Records.push(entry);

  console.log('[api/log] 최종 로그:', JSON.stringify(logBuffer, null, 2));
}

export function flushLogs(): { Records: LogEntry[] } {
  console.trace('[flushLogs] 호출됨');

  const copy = [...logBuffer.Records];
  logBuffer.Records.length = 0;

  console.log('얼마들어있음 지금??', logBuffer);
  return { Records: copy };
}
