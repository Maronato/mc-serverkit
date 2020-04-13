#! /usr/bin/env bash

# Exit in case of error
set -e

source 'prod.env'
source '.env'

function join_by { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }

separator=' -f compose/'

deploy=$(join_by "$separator" $(ls ./compose | grep docker-compose.deploy))
extra=$(join_by "$separator" $(ls ./compose | grep docker-compose.extra))
shared=$(join_by "$separator" $(ls ./compose | grep docker-compose.shared))
server='./server-settings.yml'

joined="$separator$(join_by "$separator" "$shared" "$deploy") -f "$server""


if [ "$TAG" != "latest" ]; then
    DOMAIN=$DOMAIN \
    EMAIL=$EMAIL \
    GRAFANA_PASSWORD=$GRAFANA_PASSWORD \
    TAG=$TAG \
    IMAGE_DOMAIN=$IMAGE_DOMAIN \
    SERVER_NAME=$SERVER_NAME \
    TRAEFIK_USER_PASSWORD=$TRAEFIK_USER_PASSWORD \
    docker-compose $joined config > docker-stack-${TAG}.yml
fi

DOMAIN=$DOMAIN \
EMAIL=$EMAIL \
GRAFANA_PASSWORD=$GRAFANA_PASSWORD \
TAG=latest \
IMAGE_DOMAIN=$IMAGE_DOMAIN \
SERVER_NAME=$SERVER_NAME \
TRAEFIK_USER_PASSWORD=$TRAEFIK_USER_PASSWORD \
docker-compose $joined config > docker-stack-latest.yml
