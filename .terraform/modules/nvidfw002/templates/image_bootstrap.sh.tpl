#!/bin/env bash

sed -i 's|search.*|search ${join(" ", dns_domains)}|g' /etc/resolv.conf
echo "DOMAIN=\"${join(" ", dns_domains)}\"" >> /etc/sysconfig/network-scripts/ifcfg-eth0
rm -f /root/image_bootstrap.sh
wget -P /root/ ${source}/Azure/bootstrap/${os}/image_bootstrap.sh
chmod +x /root/image_bootstrap.sh
curl -k --connect-timeout 3 --retry 3 -X PUT -H "Content-Type: text/pson" --data '{"desired_state":"revoked"}' https://puppet:8140/production/certificate_status/${vm_fqdn}
curl -k --connect-timeout 3 --retry 3 -X DELETE -H "Accept: pson" https://puppet:8140/production/certificate_status/${vm_fqdn}
/root/image_bootstrap.sh -p ${platform} -n > /root/image_bootstrap.log 2>&1 &
