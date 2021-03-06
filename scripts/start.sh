#!/bin/bash
if [ ! -f /var/lib/mysql/ibdata1 ]; then
    echo "=> initializing mysql tables"
    mysql_install_db > /dev/null 2>&1
fi
if [ ! -f /var/www/wp-config.php ]; then
# For data-container-mount issue.
# move wordpress into /var/www
#
cp -a /var/wp/. /var/www && rm -rf /var/wp
#
#mysql has to be started this way as it doesn't work to call from /etc/init.d
/usr/bin/mysqld_safe &
sleep 9s
# Here we generate random passwords (thank you pwgen!). The first two are for mysql users, the last batch for random keys in wp-config.php
WORDPRESS_DB="wordpress"
MYSQL_PASSWORD=`pwgen -c -n -1 12`
WORDPRESS_PASSWORD=`pwgen -c -n -1 12`
#This is so the passwords show up in logs. 
echo mysql root password: $MYSQL_PASSWORD
echo wordpress password: $WORDPRESS_PASSWORD
echo $MYSQL_PASSWORD > /var/lib/mysql/mysql-root-pw.txt
echo $WORDPRESS_PASSWORD > /var/lib/mysql/wordpress-db-pw.txt
#there used to be a huge ugly line of sed and cat and pipe and stuff below,
#but thanks to @djfiander's thing at https://gist.github.com/djfiander/6141138
#there isn't now.

sed -e "s/database_name_here/$WORDPRESS_DB/
s/username_here/$WORDPRESS_DB/
s/password_here/$WORDPRESS_PASSWORD/
/'AUTH_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
/'SECURE_AUTH_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
/'LOGGED_IN_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
/'NONCE_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
/'AUTH_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/
/'SECURE_AUTH_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/
/'LOGGED_IN_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/
/'NONCE_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/" /var/www/wp-config-sample.php > /var/www/wp-config.php

# mv /etc/php5/apache2/php.ini /etc/php5/apache2/php.ini.orig
# sed "s/upload_max_filesize = 2M/upload_max_filesize = 20M/" /etc/php5/apache2/php.ini.orig > /etc/php5/apache2/php.ini

# zh_TW version
sed -i "s/'WPLANG', ''/'WPLANG', 'zh_TW'/g" /var/www/wp-config.php 

# set permissions for plugin installation without ftp/ftps
chmod -R 777 /var/www/wp-content 
sed -i "s/define('WP_DEBUG.*/define('FS_METHOD','direct');\ndefine('FS_CHMOD_DIR', 0777);\ndefine('FS_CHMOD_FILE', 0777);\n&/" /var/www/wp-config.php

chown -R www-data:www-data /var/www
mysqladmin -u root password $MYSQL_PASSWORD 
mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE wordpress; GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost' IDENTIFIED BY '$WORDPRESS_PASSWORD'; FLUSH PRIVILEGES;"
killall mysqld
sleep 9s
fi
supervisord -n
