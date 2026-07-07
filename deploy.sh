#!/bin/bash

set -e

APP=/home/zkan/apps/helloProject

CURRENT=$(readlink -f "$APP/current")

if [ "$CURRENT" = "$APP/blue" ]; then
    TARGET="$APP/green"
    PREVIOUS="$APP/blue"
else
    TARGET="$APP/blue"
    PREVIOUS="$APP/green"
fi

echo "Current : $CURRENT"
echo "Target  : $TARGET"

rm -rf "$TARGET"/*
cp -r publish/* "$TARGET"/

ln -sfn "$TARGET" "$APP/current"

sudo systemctl restart helloapp

sleep 5

if curl -f http://localhost:5000 >/dev/null
then
    echo "Deployment successful."
else

    echo "Health check failed."

    ln -sfn "$PREVIOUS" "$APP/current"

    sudo systemctl restart helloapp

    exit 1

fi