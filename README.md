# update-nextcloud
Command Line Script to update an existing Nextcloud instance and its installed apps to latest version

To run the script the following prerequisites must be set:
- Nextcloud is running on a webserver using HTTPS
- The Document Root is /var/www/FQDN, that means that the Document Root folder has the same name like the Full Qualified Domain Name of the Server, like /var/www/intranet.my-own-domain.com
- Nextcloud is installed in an subfolder nextcloud, like /var/www/intranet.my-own-domain.com/nextcloud
- Setting this is important for configuring the Full Text Search after every Update


Copy the Script to a local folder, like /root/, and change the permissions to executable:
chmod +x update-nextcloud.sh

Run it as User root:
/root/update-nextcloud.sh

If the update finds an update in the same main version, it will automatically update. If the update would lead to a bigger main version, then the update will skip the interactive mode, and ask for every step. You can then also abort the update if you like.
