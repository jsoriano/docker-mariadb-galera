#!/bin/bash

MARIADB_CLUSTER_ADDRESS=${MARIADB_CLUSTER_ADDRESS-gcomm://}
MARIADB_REPLICATION_USER=${MARIADB_REPLICATION_USER-replication}
MARIADB_SERVER_ID=${MARIADB_SERVER_ID-$(perl -e "print hex('$(hostname | md5sum | cut -c-8)')")}
MARIADB_SST_METHOD=${MARIADB_SST_METHOD-xtrabackup-v2}
MARIADB_NODE_ADDRESS=$(head -1 /etc/hosts | awk '{ print $1 }')
MARIADB_SST_RECEIVE_ADDRESS=${MARIADB_SST_RECEIVE_ADDRESS-$MARIADB_NODE_ADDRESS}

if [ "$MARIADB_CLUSTER_ADDRESS" = "gcomm://" ]; then
function create_user {
	local user=$1
	local password=$2
	local privileges=$3

	local create_query="CREATE USER '$user'@'%' IDENTIFIED BY '$password'"
	local grant_query="GRANT $privileges ON *.* TO '$user'@'%' WITH GRANT OPTION"
	mysql -uroot -e "$create_query;$grant_query;" > /dev/null 2>&1
}

{ 
	# Wait for mysql to be alive
	while ! mysql -uroot -e "status" > /dev/null 2>&1;do
		sleep 1
	done

	if [ "$MARIADB_PASSWORD" ]; then
		create_user root "$MARIADB_PASSWORD" "ALL PRIVILEGES"
	fi

	if [ "$MARIADB_REPLICATION_PASSWORD" ]; then
		create_user "$MARIADB_REPLICATION_USER" "$MARIADB_REPLICATION_PASSWORD" "RELOAD, LOCK TABLES, REPLICATION CLIENT"
	fi
} &
fi


cat <<EOF > /etc/mysql/conf.d/galera-node.cnf
[mysqld]
server-id=$MARIADB_SERVER_ID
wsrep_node_address="$MARIADB_NODE_ADDRESS"
wsrep_node_name="$(hostname)"

wsrep_cluster_name="$MARIADB_CLUSTER_NAME"
wsrep_cluster_address="$MARIADB_CLUSTER_ADDRESS"

wsrep_sst_receive_address="$MARIADB_SST_RECEIVE_ADDRESS"
wsrep_sst_auth=$MARIADB_REPLICATION_USER:$MARIADB_REPLICATION_PASSWORD
wsrep_sst_method="$MARIADB_SST_METHOD"
EOF

/usr/sbin/mysqld "$@"
