#!/bin/bash
if [ $# -lt 1 ]; then
    cat <<EOF
cli.sh
runvol <name> : run data cotainer
run <name> <port> : run data/wp container
EOF
  exit 0
fi
if [ $1 == "runvol" ]; then
    if [ $# -lt 2 ]; then 
      echo -e "Syntax Error, ex: cli.sh runvol <name>"
      exit 0
    fi
    echo sudo docker run --name $2-data -v /var/lib/mysql -v /var/www/wordpress/wp-content busybox /bin/true
fi
if [ $1 == "run" ]; then
    if [ $# -lt 3 ]; then 
      echo -e "Syntax Error, ex: cli.sh run <name> <port>"
      exit 0
    fi
    cat <<EOF
docker run --name $2-data -v /var/lib/mysql -v /var/www/wordpress/wp-content busybox /bin/true && 
docker run -d -P $3:80 --name $2 --volumes-from $2-data dk-wptw
EOF
fi
if [ $1 == "psip" ]; then
    cat <<EOF
docker ps && docker ps -q | xargs -n 1 docker inspect --format "{{ .Name }} {{ .NetworkSettings.IPAddress }}"
EOF
   fi
if [ $1 == "rm" ]; then 
   echo 'docker rm $(docker ps -a -q)'
fi
if [ $1 == "stopall" ]; then 
   echo 'docker stop $(docker ps -q)'
fi
if [ $1 == "rmi" ]; then
    cat <<EOF
docker rmi \$(docker images | grep "^<none>" | awk "{print $3}")
EOF
fi
if [ $1 == "enablessl" ]; then
    SUBJ="/C=TW/ST=Taichung/L=Xitun/OU=Y12STUDIO/O=WordPressDev/CN=dev.y12.tw"
    echo "-----> enable SSL $SUBJ"
    mkdir -p /etc/apache2/ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt -subj $SUBJ
    sed -i "s/define('WP_DEBUG', false);/define('WP_DEBUG', false);\r\ndefine('FORCE_SSL_ADMIN', true);/g" /var/www/wp-config.php
    a2enmod ssl 
    a2ensite default-ssl.conf
fi
if [ $1 == "cmdssl" ]; then
    if [ $# -lt 2 ]; then 
      echo -e "Syntax Error, ex: cli.sh cmdssl <img_name>"
      exit 0
    fi
    cat <<EOF
id=\$(docker run -d $2 /bin/bash -c "/cli.sh enablessl")
test \$(docker wait \$id) -eq 0
docker commit --run='{"Cmd": ["/bin/bash", "/start.sh"]}' \$id $2:ssl > /dev/null
echo "-----> Injected SSL with images: $2:ssl"
docker images | grep $2
EOF
fi





