using Amazon;
using Amazon.CognitoIdentityProvider;
using Amazon.CognitoIdentityProvider.Model;
using Microsoft.Extensions.Configuration;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MyApi.Services
{
    public class CognitoService
    {
        private readonly AmazonCognitoIdentityProviderClient _cognitoClient;
        private readonly string _userPoolId;

        public CognitoService(IConfiguration configuration)
        {
            _cognitoClient = new AmazonCognitoIdentityProviderClient(RegionEndpoint.APNortheast2);
            _userPoolId = Environment.GetEnvironmentVariable("COGNITO_USER_POOL") ?? configuration["Cognito:UserPoolId"];
        }

        public async Task<string> CreateUserAsync(string id, string password, string email)
        {
            // 1. 사용자 생성 요청 (이메일 인증 메일 전송)
            AdminCreateUserRequest createUserRequest = new AdminCreateUserRequest
            {
                UserPoolId = _userPoolId,
                Username = id,
                TemporaryPassword = "YourTempPassword123!",
                UserAttributes = new List<AttributeType>
                {
                    new AttributeType { Name = "email", Value = email }
                },
                MessageAction = "RESEND", // 인증 이메일 자동 전송
            };

            var createUserResponse = await _cognitoClient.AdminCreateUserAsync(createUserRequest);

            // 2. 비밀번호 영구 설정 (임시 비밀번호 없이 바로 사용 가능하게)
            AdminSetUserPasswordRequest setPasswordRequest = new AdminSetUserPasswordRequest
            {
                UserPoolId = _userPoolId,
                Username = id,
                Password = password,
                Permanent = true // 영구 비밀번호 설정
            };

            await _cognitoClient.AdminSetUserPasswordAsync(setPasswordRequest);

            // 3. 이메일 인증은 사용자가 메일을 통해 직접 해야 함
            return createUserResponse.User.Username;
        }
    }
}