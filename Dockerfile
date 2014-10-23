FROM debian:wheezy

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CBCB082A1BB943DB
RUN echo 'deb http://mirror.klaus-uwe.me/mariadb/repo/10.0/debian wheezy main' > /etc/apt/sources.list.d/mariadb.list
RUN apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
RUN echo 'deb http://repo.percona.com/apt wheezy main' > /etc/apt/sources.list.d/percona.list
RUN apt-get update

RUN apt-get install -y --force-yes mariadb-galera-server galera
RUN apt-get install -y --force-yes xtrabackup

# Needed for Galera and xtrabackup
RUN apt-get install -y --force-yes net-tools procps

ADD conf.d /etc/mysql/conf.d

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT "/entrypoint.sh"

EXPOSE 3306
