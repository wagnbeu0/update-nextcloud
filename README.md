# update-nextcloud
This is a command line script to update an existing Nextcloud instance and all installed apps to latest version

To run the script the following prerequisites must be set:
- Nextcloud is running on a webserver using HTTPS
- The Document Root is /var/www/FQDN, that means that the Document Root folder has the same name like the Full Qualified Domain Name of the Server, like /var/www/intranet.my-own-domain.com
- Nextcloud is installed in an subfolder nextcloud, like /var/www/intranet.my-own-domain.com/nextcloud
- Setting this is important for configuring the Full Text Search after every Update


Copy the Script to a local folder, like /root/, and change the permissions to executable:
````
chmod +x update-nextcloud.sh
````

Create a file /etc/nc-updater.conf which has this entries:
````
# Please set here the URL how your nextcloud is available without HTTPS or HTTP
export NC_URL=intranet.mydomain.com
# Please set here the path of your local nextcloud root folder
export NC_ROOT=/var/www/$NC_URL/nextcloud

# Please set here the NextCloud Puplic URL:
export NC_PUPLIC_URL=https://$NC_URL/nextcloud
````
If you have **not** installed Nextcloud in a subfolder nextcloud, remove it from the variables NC_ROOT andd NC_PUPLIC_URL above

Run the script as user root:
````
/root/update-nextcloud.sh
````
If the update finds an update in the same main version, it will automatically update. If the update would lead to a bigger main version, then the update will skip the interactive mode, and ask for every step. You can then also abort the update if you like.
