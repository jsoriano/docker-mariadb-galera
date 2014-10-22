FROM debian:wheezy

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y install python-software-properties
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
RUN add-apt-repository 'deb http://tedeco.fi.upm.es/mirror/mariadb/repo/10.0/debian wheezy main'
RUN apt-get update

RUN apt-get install -y --force-yes mariadb-galera-server galera

ADD conf.d /etc/mysql/conf.d

ADD entrypoint.sh /entrypoint.sh
CMD "/entrypoint.sh"

EXPOSE 3306
