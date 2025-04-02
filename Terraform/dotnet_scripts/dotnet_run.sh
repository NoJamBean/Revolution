#! bin/bash

cd $LOCAL_PATH

sudo dotnet restore $LOCAL_PATH
sudo dotnet build $LOCAL_PATH
sudo dotnet publish -c Release -o $LOCAL_PATH/published
sudo systemctl restart dotnet-api
sudo systemctl restart nginx