#!/bin/bash
# put the following configuration variables to /etc/nc-updater.conf
# NC_URL
# NC_ROOT
# NC_PUPLIC_URL
# because in next version of the script it will not contain any user variables

# Please set here the URL how your nextcloud is available without HTTPS or HTTP
export NC_URL=intranet.mydoamin.com
# Please set here the path of your local nextcloud root folder
export NC_ROOT=/var/www/$NC_URL/nextcloud

# Please set here the NextCloud Puplic URL:
export NC_PUPLIC_URL=https://$NC_URL/nextcloud


if [[ -f "/etc/nc-updater.conf" ]]; then
        echo User specific file found, read variables
        source /etc/nc-updater.conf
else
        echo No Config file found, will create /etc/nc-updater.conf now:
        cat "$0" | head -n 15 | tail -8 >>/etc/nc-updater.conf
fi

echo Update all local Apps
sudo -u www-data php $NC_ROOT/occ app:update --all

echo Update Nextcloud Main Version
# Set Current Main version
export current_version=`cat $NC_ROOT/config/config.php | grep -w "version" | cut -c 17,18`
cd $NC_ROOT

# Check available Main version
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
echo Check if Elasticsearch is installed...
if [[ -f "/etc/init.d/elasticsearch" ]]; then
        echo ... Elasticsearch is installed. Restart service
        systemctl stop elasticsearch
        systemctl start elasticsearch
        /usr/share/elasticsearch/bin/elasticsearch-plugin remove ingest-attachment -s
        /usr/share/elasticsearch/bin/elasticsearch-plugin install ingest-attachment -s --batch
else
        echo ... Elasticsearch is not installed
fi

echo Check if RichDocumentsCode and Richdocuments are installed
if [[ -d "$NC_ROOT/apps/richdocuments" ]]; then
        echo ... RichDocuments is installed

        if [[ -d "$NC_ROOT/apps/richdocumentscode" ]]; then
                echo ... RichDocumentsCode is installed

                cd $NC_ROOT
                echo CURL status
                curl $NC_PUPLIC_URL/apps/richdocumentscode/proxy.php?status
                echo set puplic_wopi_url
                sudo -u www-data php --define apc.enable_cli=1 occ config:app:set richdocuments public_wopi_url --value $NC_PUPLIC_URL/apps/richdocumentscode/proxy.php?req= &
                echo set wopi_url
                sudo -u www-data php --define apc.enable_cli=1 occ config:app:set richdocuments wopi_url --value $NC_PUPLIC_URL/apps/richdocumentscode/proxy.php?req= &
                echo Active Config
                sudo -u www-data php --define apc.enable_cli=1 occ richdocuments:activate-config &
        else
                echo ... RichDocumentsCode is not installed
        fi
else
        echo ... RichDocuments is not installed
fi
