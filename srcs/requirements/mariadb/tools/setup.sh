#!/bin/sh

if [ ! -d /var/lib/mysql/mysql ]; then
    echo "Initializing MariaDB..."
    mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
fi

# create a temporary file to store the SQL commands
cat << EOF > /temp/create_db.sql
USE mysql;
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;
CREATE USER IF NOT EXISTS \`$MYSQL_USER\`@'%' IDENTIFIED BY \`$MYSQL_PASSWORD\`;
GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO \`$MYSQL_USER\`@'%';
FLUSH PRIVILEGES;
EOF

# execute the SQL commands
exec /usr/bin/mysql --user=mysql --console
