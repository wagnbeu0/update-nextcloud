#!/bin/bash
# Please set here the URL how your nextcloud is available without HTTPS or HTTP. It is need later when configuring Fulltext Search
# I recommend to use under /var/www as document root the domain name, like /var/www/intranet.localhost, not the html default folder /var/www/html
# export NC_URL=html
export NC_URL=intranet.localhost

# Please set here the path of your local nextcloud root folder
export NC_ROOT=/var/www/$NC_URL/nextcloud

echo Update local Apps
sudo -u www-data php $NC_ROOT/occ app:update --all

echo Update Nextcloud Main Version
echo Set Current Main version
export current_version=`cat $NC_ROOT/config/config.php | grep -w "version" | cut -c 17,18`
cd $NC_ROOT
echo Check available Main version
echo n | sudo -u www-data php $NC_ROOT/updater/updater.phar -vvv | grep channel >/tmp/update-nc.txt
export available_version=`cat /tmp/update-nc.txt  | cut -c 21,22`
# if no update is available, no version will be displayed, so we will set the installed version as available
if [[ -z "$available_version" ]]; then
        export available_version=$current_version
fi

# if an update to a new major version is available, ask for update. if the same major version remains, do it automatically
if [ "$current_version" = "$available_version" ]; then
    echo "Installed Version $current_version and available version $available_version is equal. Continue with build in updater..."
        sudo -u www-data php $NC_ROOT/updater/updater.phar --no-interaction
else
    echo "Available version $available_version newer than installed version $current_version"
    echo "Please confirm update"
        sudo -u www-data php $NC_ROOT/updater/updater.phar
fi

echo Restart Services
/etc/init.d/elasticsearch stop
/etc/init.d/elasticsearch start
/usr/share/elasticsearch/bin/elasticsearch-plugin remove ingest-attachment -s
/usr/share/elasticsearch/bin/elasticsearch-plugin install ingest-attachment -s --batch

cd $NC_ROOT
echo CURL status
curl https://$NC_URL/nextcloud/apps/richdocumentscode/proxy.php?status
echo set puplic_wopi_url
sudo -u www-data php --define apc.enable_cli=1 occ config:app:set richdocuments public_wopi_url --value https://$NC_URL/nextcloud/apps/richdocumentscode/proxy.php?req= &
echo set wopi_url
sudo -u www-data php --define apc.enable_cli=1 occ config:app:set richdocuments wopi_url --value https://$NC_URL/nextcloud/apps/richdocumentscode/proxy.php?req= &
