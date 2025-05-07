using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;

namespace MyApi.Services
{
    public class LowercaseNamingStrategy : NamingStrategy
    {
        protected override string ResolvePropertyName(string name)
        {
            return name.ToLowerInvariant();
        }
    }
}
