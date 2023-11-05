#!/bin/bash
cd ~/git/UniFi-API-client || exit
#grep dhcp-host ~/Sync/Config/k8s/services/infra/dnsmasq.yml | cut -f2 -d, | while read -r I; do
cut -f3 -d" " /k8s/default/dnsmasq/dhcp.leases | while read -r I; do
	if ! ping -c 1 -W 1 "$I" >/dev/null; then
		#M=$(grep dhcp-host ~/Sync/Config/k8s/services/infra/dnsmasq.yml | grep "$I" | cut -f1 -d, | cut -f2 -d=)
		M=$(grep "$I" /k8s/default/dnsmasq/dhcp.leases | cut -f2 -d" ")
		echo "$I" "$M"
		php ./reconnect.php "$M"
		echo
	fi
done
