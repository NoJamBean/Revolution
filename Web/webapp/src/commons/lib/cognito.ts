import { CognitoUserPool } from 'amazon-cognito-identity-js';

const poolData = {
  UserPoolId: 'ap-northeast-2_8GSNTHJjT',
  ClientId: '27q05duara0ufor8u44eje2oof',
};

export const userPool = new CognitoUserPool(poolData);
