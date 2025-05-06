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

  console.log('\n\n[📥 LOG ADD] 로그 추가됨 ------------------------');
  console.log('[📦 현재 logBuffer 상태]');
  console.dir(logBuffer, { depth: null });
  console.log('--------------------------------------------------\n\n');
}

export function flushLogs(): { Records: LogEntry[] } {
  console.log('\n\n[🚚 flushLogs] 로그 업로드 준비됨 ----------------');
  console.log(`[✅ Records 개수]: ${logBuffer.Records.length}`);
  console.dir(logBuffer.Records, { depth: null });

  const flushed = [...logBuffer.Records];
  logBuffer.Records.length = 0;

  console.log('[🧹 버퍼 초기화 완료]');
  console.log('--------------------------------------------------\n\n');

  return { Records: flushed };
}
