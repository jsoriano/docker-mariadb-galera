#!/bin/bash

{ 
	while ! mysql -uroot -e "status" > /dev/null 2>&1;do
		sleep 1
	done

	if [ "$MARIADB_PASSWORD" ]; then
		create_query="CREATE USER 'root'@'%' IDENTIFIED BY PASSWORD '$MARIADB_PASSWORD'"
		grant_query="GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION"
		mysql -uroot -e "$create_query;$grant_query;"
	fi
} &

cat <<EOF > /etc/mysql/conf.d/galera-node.cnf
[mysqld]
wsrep_node_address="$(head -1 /etc/hosts | awk '{ print $1 }')"
wsrep_node_name="$(hostname)"
EOF

/usr/bin/mysqld_safe "$@"
