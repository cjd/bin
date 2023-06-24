#!/usr/bin/sh
#cd /home/cjd/Docker-Data/gameservers
#docker compose --file docker-compose.yml-games $@
if [ "$1" = "stop" ]
then REPS=0
else REPS=1
fi

kubectl scale --replicas=$REPS deploy/minecraft-creative -n default
kubectl scale --replicas=$REPS deploy/minecraft-survival -n default
