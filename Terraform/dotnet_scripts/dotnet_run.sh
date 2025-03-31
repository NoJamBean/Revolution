#! bin/bash

sudo dotnet restore /var/www/dotnet-api/MyApi
sudo dotnet build /var/www/dotnet-api/MyApi
sudo dotnet publish -c Release -o /var/www/dotnet-api/MyApi/published
sudo systemctl restart dotnet-api
sudo systemctl restart nginx