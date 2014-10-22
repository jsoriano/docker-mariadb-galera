#!/bin/bash

{ 
	while ! mysql -uroot -e "status" > /dev/null 2>&1;do
		sleep 1
	done

	if [ "$MARIADB_PASSWORD" ]; then
		create_query="CREATE USER 'root'@'%' IDENTIFIED BY PASSWORD '$MARIADB_PASSWORD'"
		grant_query="GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION"
	
		mysql -uroot -e "SELECT PASSWORD('foobar');"
		mysql -uroot -e "$create_query;$grant_query;"
	fi
} &

/usr/bin/mysqld_safe
