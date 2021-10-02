FROM centos:7

RUN yum -y install httpd

EXPOSE 80

ADD webserver.tar.gz /var/www/html

ENTRYPOINT ["/usr/sbin/httpd","-D","FOREGROUND"]
