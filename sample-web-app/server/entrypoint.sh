#!/bin/sh

# #export env vars for this app
export DB=%CONN_STRING%
export PORT=%PORT%

echo "DB=%CONN_STRING%" > .env
echo "PORT=%PORT%" >> .env
chmod +r .env

#start node
node ./bin/www