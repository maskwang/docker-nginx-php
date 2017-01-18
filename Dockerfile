FROM phusion/baseimage:0.9.19

MAINTAINER Mask Wang, mask.wang.cn@gmail.com

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

ENV HOME /root

# enable ssh
RUN rm -f /etc/service/sshd/down
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Enabling the insecure key permanently
RUN /usr/sbin/enable_insecure_key

CMD ["/sbin/my_init"]

# Replace APT Source
ADD build/sources.list /tmp/sources.list
RUN mv /tmp/sources.list /etc/apt/sources.list

# Nginx-PHP Installation
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y vim curl wget build-essential python-software-properties\
               telnet nmap
RUN add-apt-repository -y ppa:ondrej/php
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y php5.6  php5.6-fpm php5.6-mcrypt php5.6-mbstring php5.6-curl\
          php5.6-cli php5.6-mysql php5.6-gd php5.6-intl php5.6-xsl php5.6-zip php5.6-memcached php5.6-redis php5.6-xdebug

RUN sed -i "s/;date.timezone =.*/date.timezone = Asia\/Shanghai/" /etc/php/5.6/fpm/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = Asia\/Shanghai/" /etc/php/5.6/cli/php.ini

RUN sed -i "s/display_errors = Off/display_errors = On/" /etc/php/5.6/fpm/php.ini
RUN sed -i "s/display_errors = Off/display_errors = On/" /etc/php/5.6/cli/php.ini

RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y nginx

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/5.6/fpm/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/5.6/fpm/php.ini

RUN mkdir -p        /var/www
ADD build/default   /etc/nginx/sites-available/default
RUN mkdir -p        /etc/service/nginx
ADD build/nginx.sh  /etc/service/nginx/run
RUN chmod +x        /etc/service/nginx/run
RUN mkdir -p        /etc/service/phpfpm
ADD build/phpfpm.sh /etc/service/phpfpm/run
RUN chmod +x        /etc/service/phpfpm/run
RUN mkdir -p 		/var/log/xdebug
RUN chmod -R 777    /var/log/xdebug
ADD build/xdebug.ini /etc/php/5.6/fpm/conf.d/20-xdebug.ini

EXPOSE 80
# End Nginx-PHP

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
