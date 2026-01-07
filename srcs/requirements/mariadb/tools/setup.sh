#!/bin/sh

# Ensure socket and pid directories exist with proper permissions
mkdir -p /run/mysqld /run/mysql
chown -R mysql:mysql /run/mysqld /run/mysql

if [ ! -d /var/lib/mysql/mysql ]; then
    echo "Initializing MariaDB..."
    mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

    ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
    USER_PASSWORD=$(cat /run/secrets/db_user_password)

    # create a temporary file to store the SQL commands
    cat << EOF > /tmp/init.sql
USE mysql;
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;
CREATE USER IF NOT EXISTS \`$MYSQL_USER\`@'%' IDENTIFIED BY '$USER_PASSWORD';
GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO \`$MYSQL_USER\`@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROOT_PASSWORD';
FLUSH PRIVILEGES;
EOF

    # create a bootstrap script to execute the SQL commands
    /usr/bin/mysqld --user=mysql --bootstrap < /tmp/init.sql
    rm -f /tmp/init.sql

fi
# Start MariaDB server
exec /usr/bin/mariadbd --user=mysql --console
