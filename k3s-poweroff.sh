#!/bin/sh
kubectl cordon `hostname`
kubectl drain --ignore-daemonsets --delete-emptydir-data `hostname`
sudo sh ~/Sync/bin/k3s-killall.sh
sudo poweroff
