FROM phusion/baseimage:0.9.9

MAINTAINER Mask Wang, mask.wang.cn@gmail.com

ENV HOME /root

RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

CMD ["/sbin/my_init"]

# Nginx-PHP Installation
RUN apt-get update
RUN apt-get install -y vim curl wget build-essential python-software-properties
RUN add-apt-repository -y ppa:ondrej/php5
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get update
RUN apt-get install -y php5-cli php5-fpm php5-mysql php5-pgsql php5-sqlite php5-curl\
		       php5-gd php5-mcrypt php5-intl php5-imap php5-tidy php5-memcache php5-xdebug\
					 php5-zmq php5-redis

RUN sed -i "s/;date.timezone =.*/date.timezone = Asia\/Shanghai/" /etc/php5/fpm/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = Asia\/Shanghai/" /etc/php5/cli/php.ini

RUN sed -i "s/display_errors = Off/display_errors = On/" /etc/php5/fpm/php.ini
RUN sed -i "s/display_errors = Off/display_errors = On/" /etc/php5/cli/php.ini

RUN apt-get install -y nginx

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini

RUN mkdir -p        /var/www
ADD build/default   /etc/nginx/sites-available/default
RUN mkdir -p        /etc/service/nginx
ADD build/nginx.sh  /etc/service/nginx/run
RUN chmod +x        /etc/service/nginx/run
RUN mkdir -p        /etc/service/phpfpm
ADD build/phpfpm.sh /etc/service/phpfpm/run
RUN chmod +x        /etc/service/phpfpm/run
RUN mkdir -p 				/var/log/xdebug
RUM chmod -R 777    /var/log/xdebug
ADD build/xdebug.ini /etc/php5/fpm/conf.d/20-xdebug.ini

EXPOSE 80
# End Nginx-PHP

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*