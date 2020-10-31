#!/bin/sh

#export env vars for this app
export API_HOST=%EB_API_APP_URL%
export PORT=%PORT%

echo "API_HOST=%EB_API_APP_URL%" > .env
echo "PORT=%PORT%" >> .env
chmod +r .env

#start node
node ./bin/www