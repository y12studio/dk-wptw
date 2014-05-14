FROM ubuntu:14.04
MAINTAINER Y12STUDIO <y12studio@gmail.com>
RUN apt-get update && apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install nano zip curl git mysql-client mysql-server apache2 libapache2-mod-php5 pwgen python-setuptools php5-mysql openssh-server sudo php5-ldap php5-curl
#
#  download English/zh_TW version
# move en-version to /var/www for sed-safety
RUN rm -rf /var/www/ && wget -q http://wordpress.org/latest.tar.gz -O wordpress-en.tar.gz &&\
    wget -q http://tw.wordpress.org/latest-zh_TW.tar.gz -O wordpress.tar.gz &&\
	tar xvzf /wordpress.tar.gz && mv /wordpress /var/www/ &&\
	tar xvzf /wordpress-en.tar.gz && mv -f /wordpress/wp-config-sample.php /var/www/ &&\
    rm /wordpress.tar.gz && rm /wordpress-en.tar.gz && rm -rf /wordpress
RUN easy_install supervisor
ADD ./scripts/foreground.sh /etc/apache2/foreground.sh
ADD ./configs/supervisord.conf /etc/supervisord.conf
RUN chmod 755 /etc/apache2/foreground.sh
RUN mkdir /var/log/supervisor/ && mkdir /var/run/sshd
ADD ./configs/000-default.conf /etc/apache2/sites-available/000-default.conf 
RUN a2enmod headers
ADD ./scripts/start.sh /start.sh
RUN chmod 755 /start.sh
RUN chmod u+s /usr/bin/sudo
#
# add user
#
RUN mkdir -p /home/docker &&\
   useradd docker &&\
   echo "docker:dkwptw2014" | chpasswd &&\
   mkdir -p /home/docker/.ssh; chmod 700 /home/docker/.ssh &&\
   chown -R docker /home/docker &&\
   echo "docker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
#
# footer expose 80 http /22 ssh
EXPOSE 80
EXPOSE 22
CMD ["/bin/bash", "/start.sh"]
