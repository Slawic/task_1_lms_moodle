#!/bin/bash
# DB Params >
DBNAME="moodle"
DBUSER="UserDB"
DBPASS="PassDB"
# <
# MOODLE Params >
MOODLEUSER="Moodle"
MOODLEPASS="Passw0rd"
# <
# install mc-commander >
# sudo yum -y install mc
# <
# packets update >
sudo yum clean all
sudo yum -y update
# <
# install Apache >
sudo yum -y install httpd
sudo systemctl start httpd
sudo systemctl enable httpd
# <
# install PHP7.0 >
sudo yum -y install epel-release
sudo rpm -Uhv https://rpms.remirepo.net/enterprise/remi-release-7.rpm
sudo yum -y install yum-utils
sudo yum-config-manager --enable remi-php70
sudo yum -y install php php-common php-intl php-zip php-soap php-xmlrpc php-opcache php-mbstring php-gd php-curl php-mysql php-xml
# <
# install MariaDB >
sudo yum -y install mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb
# creating MariaDB for MOODLE >
sudo mysql -e "SET GLOBAL character_set_server = 'utf8mb4';"
sudo mysql -e "SET GLOBAL innodb_file_format = 'BARRACUDA';"
sudo mysql -e "SET GLOBAL innodb_large_prefix = 'ON';"
sudo mysql -e "SET GLOBAL innodb_file_per_table = 'ON';"
sudo mysql -e "CREATE DATABASE ${DBNAME};"
sudo mysql -e "CREATE USER '${DBUSER}'@'localhost' IDENTIFIED BY '${DBPASS}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${DBNAME}.* to '${DBUSER}'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"
# <
################
# Install App >
curl https://download.moodle.org/download.php/direct/stable36/moodle-latest-36.tgz -o moodle-latest-36.tgz -s
sudo tar -xvzf moodle-latest-36.tgz -C /var/www/html/
#
sudo /usr/bin/php /var/www/html/moodle/admin/cli/install.php \
--lang=uk \
--chmod=2770 \
--wwwroot=http://localhost:8081/moodle \
--dataroot=/var/moodledata \
--dbtype=mariadb \
--dbhost=localhost \
--dbport=3306 \
--dbname=${DBNAME} \
--dbuser=${DBUSER} \
--dbpass=${DBPASS} \
--fullname=Moodle \
--shortname=ymd \
--summary=Moodle01 \
--adminuser=${MOODLEUSER} \
--adminpass=${MOODLEPASS} \
--non-interactive \
--agree-license
#
# <
# >
sudo chmod o+r /var/www/html/moodle/config.php
###sudo chown -R apache:apache /var/www/html/
sudo chcon -R -t httpd_sys_rw_content_t /var/moodledata
sudo chown -R apache:apache /var/moodledata
sudo chown -R apache:apache /var/www/
# <
# configuring Apache vhost>
sudo systemctl stop httpd
cd /etc/httpd/conf.d/
sudo touch moodle.conf
cat <<EOF | sudo tee -a /etc/httpd/conf.d/moodle.conf
<VirtualHost *:8081>
ServerAdmin admin@moodle.com
DocumentRoot /var/www/html/moodle
ServerName moodle.com
ServerAlias www.moodle.com
Alias /moodle "/var/www/html/moodle/"
<Directory /var/www/html/moodle/>
Options FollowSymLinks
AllowOverride All
</Directory>
ErrorLog /var/log/httpd/moodle-error_log
CustomLog /var/log/httpd/moodle-access_log common
</VirtualHost>
EOF
# <
# restart apache >
sudo systemctl restart httpd
# <
# firewall >
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --zone=publicweb --add-service=ssh
sudo firewall-cmd --permanent --zone=public --add-service=http 
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload
# <