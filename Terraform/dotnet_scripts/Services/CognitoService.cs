using Amazon;
using Amazon.CognitoIdentityProvider;
using Amazon.CognitoIdentityProvider.Model;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MyApi.Services
{
    public class CognitoService
    {
        private readonly AmazonCognitoIdentityProviderClient _cognitoClient;
        private readonly string _userPoolId;
        private readonly string _userPoolClientId;

        private const int ConfirmationCheckLimit = 36;
        private const int DelayMilliseconds = 5000;

        public CognitoService(IConfiguration configuration)
        {
            _cognitoClient = new AmazonCognitoIdentityProviderClient(RegionEndpoint.APNortheast2);
            _userPoolId = Environment.GetEnvironmentVariable("COGNITO_USER_POOL") ?? configuration["Cognito:UserPoolId"];
            _userPoolClientId = Environment.GetEnvironmentVariable("COGNITO_APP_CLIENT") ?? configuration["Cognito:AppClientId"];
        }

        // 1. 회원가입(SignUp)
        public async Task<string> SignUpAsync(string id, string password, string email)
        {
            try
            {
                Console.WriteLine($"[Cognito] 회원가입 요청: {id}");

                var request = new SignUpRequest
                {
                    ClientId = _userPoolClientId,
                    Username = id,
                    Password = password,
                    UserAttributes = new List<AttributeType>
                    {
                        new AttributeType { Name = "email", Value = email }
                    }
                };

                var response = await _cognitoClient.SignUpAsync(request);
                Console.WriteLine($"[Cognito] 회원가입 완료. 인증 여부: {response.UserConfirmed}");

                return response.UserSub;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Cognito 오류] 회원가입 실패: {ex.Message}");
                throw;
            }
        }

        // 2. 인증 메일 재발송
        public async Task ResendConfirmationEmailAsync(string id)
        {
            try
            {
                var request = new ResendConfirmationCodeRequest
                {
                    ClientId = _userPoolClientId,
                    Username = id
                };

                var response = await _cognitoClient.ResendConfirmationCodeAsync(request);
                Console.WriteLine($"[Cognito] 인증 메일 재발송 완료. 수신 위치: {response.CodeDeliveryDetails.Destination}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Cognito 오류] 인증 메일 재발송 실패: {ex.Message}");
                throw;
            }
        }

        // 3. 인증 완료 확인 (관리자 권한 필요)
        public async Task WaitForUserConfirmationAsync(string id)
        {
            for (int i = 0; i < ConfirmationCheckLimit; i++)
            {
                try
                {
                    var response = await _cognitoClient.AdminGetUserAsync(new AdminGetUserRequest
                    {
                        UserPoolId = _userPoolId,
                        Username = id
                    });

                    var isEmailVerified = response.UserAttributes.Any(attr =>
                        attr.Name == "email_verified" && attr.Value == "true");

                    Console.WriteLine($"[Cognito] 상태: {response.UserStatus}, 이메일 인증: {isEmailVerified}");

                    if (response.UserStatus == UserStatusType.CONFIRMED && isEmailVerified)
                    {
                        Console.WriteLine("[Cognito] 사용자 인증 완료");
                        return;
                    }
                }
                catch (UserNotFoundException)
                {
                    Console.WriteLine("[Cognito] 사용자 아직 없음, 재시도...");
                }

                await Task.Delay(DelayMilliseconds);
            }

            Console.WriteLine("[Cognito] 사용자 인증 대기 시간 초과");
        }
        
        //이메일 인증번호 확인
        public async Task ConfirmCodeAsync(string id, string code)
        {
            var request = new ConfirmSignUpRequest
            {
                ClientId = _userPoolClientId,
                Username = id,
                ConfirmationCode = code
            };

            var response = await _cognitoClient.ConfirmSignUpAsync(request);
            Console.WriteLine("[Cognito] 이메일 인증 성공");
        }

        //로그인 확인 및 토큰 발급
        public async Task<(string IdToken, string RefreshToken)> LoginAsync(string id, string password)
        {
            var request = new InitiateAuthRequest
            {
                AuthFlow = AuthFlowType.USER_PASSWORD_AUTH,
                ClientId = _userPoolClientId,
                AuthParameters = new Dictionary<string, string>
                {
                    { "USERNAME", id },
                    { "PASSWORD", password }
                }
            };

            var response = await _cognitoClient.InitiateAuthAsync(request);
            var authResult = response.AuthenticationResult;

            if (authResult == null)
                throw new Exception("로그인 실패: Cognito에서 토큰을 반환하지 않았습니다.");

            return (
                IdToken: authResult.IdToken,
                RefreshToken: authResult.RefreshToken
            );
        }


        //관리자 권한!!!!!!!!!
        public async Task DeleteUserAsync(string username)
        {
            var request = new AdminDeleteUserRequest
            {
                Username = username,
                UserPoolId = _userPoolId
            };

            await _cognitoClient.AdminDeleteUserAsync(request);
        }

    }
}
