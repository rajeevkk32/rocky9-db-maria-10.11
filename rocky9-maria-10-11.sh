#!/bin/bash


# Disable firewalld
echo "Disabling firewalld..."
sudo systemctl stop firewalld
sudo systemctl disable firewalld



#selinux disable
sudo sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config 


#qemu-agent
dnf install qemu-guest-agent -y
systemctl start qemu-guest-agent
systemctl enable  qemu-guest-agent




# Update system
echo "Updating the system..."
sudo dnf update -y

# Install EPEL repository
echo "Installing EPEL repository..."
sudo dnf install epel-release -y



dnf upgrade --refresh -y
dnf config-manager --set-enabled crb


sudo dnf install \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
    https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-9.noarch.rpm -y

sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y


#basic tools
sudo dnf update -y
sudo dnf config-manager --set-enabled crb
sudo dnf install epel-release epel-next-release -y
dnf repolist
sudo dnf update -y
timedatectl set-timezone Asia/Kolkata
yum -y install epel-release
yum install bind-utils traceroute -y
yum update -y
dnf config-manager --set-enabled PowerTools
sudo dnf install epel-release -y
sudo dnf upgrade -y
yum install -y epel-release git nmap smartmontools telnet unzip wget yum-utils zip htop wget perl sendmail tcpdump bind-utils net-tools tcpdump tar chrony dnf tcpdump ntpstat   NetworkManager-tui nload
dnf -y install network-scripts -y
sudo yum -y install net-tools -y



#httpd
dnf install httpd -y
systemctl enable httpd
systemctl start httpd
rpm -qi httpd
sudo yum install mod_ssl openssl -y
netstat -tlpnu
systemctl restart httpd
#systemctl status httpd



# Add PHP repository (Remi's repository)
echo "Enabling Remi repository for PHP 8.3..."
sudo dnf install https://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
sudo dnf module reset php -y
sudo dnf module enable php:remi-8.3 -y

# Install PHP 8.3 and required extensions
echo "Installing PHP 8.3 and required extensions..."
sudo dnf install php php-mysqlnd php-fpm php-opcache php-gd php-xml php-mbstring php-json php-zip -y

# Start and enable PHP-FPM service
echo "Starting and enabling PHP-FPM service..."
sudo systemctl start php-fpm
sudo systemctl enable php-fpm

# Set timezone to Asia/Kolkata
echo "Setting timezone to Asia/Kolkata..."
sudo sed -i "s/;date.timezone =/date.timezone = 'Asia\/Kolkata'/" /etc/php.ini

#set upload size to 8MB
sudo sed -i 's/^upload_max_filesize = .*/upload_max_filesize = 8M/' /etc/php.ini && sudo sed -i 's/^post_max_size = .*/post_max_size = 8M/' /etc/php.ini
sudo systemctl restart httpd

echo "PHP 8.3  installed and configured."


# Enable MariaDB 10.11 repository
echo "Setting up MariaDB 10.11 repository..."


#Mariadb: server 10.11

rm -f /etc/yum.repos.d/MariaDB.repo
cat << 'EOF' | sudo tee /etc/yum.repos.d/MariaDB.repo
# MariaDB 10.11 CentOS repository list - created 2024-04-12 10:54 UTC
# https://mariadb.org/download/
[mariadb]
name = MariaDB
baseurl = "https://mariadb.gb.ssimn.org/yum/10.11/centos/$releasever/$basearch"
gpgkey = https://mariadb.gb.ssimn.org/yum/RPM-GPG-KEY-MariaDB
gpgcheck = 1
EOF


# Install MariaDB 10.11
echo "Installing MariaDB 10.11..."
sudo dnf install MariaDB-server MariaDB-client mariadb-backup  -y

# Start and enable MariaDB service
echo "Starting and enabling MariaDB service..."
systemctl start mariadb
systemctl enable mariadb
systemctl restart mariadb



echo "mariadb 10.11 installed"


# Install phpMyAdmin from ZIP
cd /usr/share
sudo wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-english.zip
unzip phpMyAdmin-5.2.1-english.zip 
mv phpMyAdmin-5.2.1-english phpmyadmin
cd phpmyadmin/
yum install -y wget php-pdo php-pecl-zip php-json php-common php-fpm php-mbstring php-cli php-mysqlnd
cp -pr /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php
mkdir /usr/share/phpmyadmin/tmp
chmod 777 /usr/share/phpmyadmin/tmp
chown -R apache:apache /usr/share/phpmyadmin
sudo systemctl restart httpd


sudo tee /etc/httpd/conf.d/phpmyadmin.conf  <<EOF
Alias /db-kdt /usr/share/phpmyadmin
<Directory /usr/share/phpmyadmin/>
    AddDefaultCharset UTF-8
    <IfModule mod_authz_core.c>
      # Apache 2.4
      <RequireAny>
        Require all granted
        Require ip 127.0.0.1
        Require ip ::1
      </RequireAny>
    </IfModule>
    <IfModule !mod_authz_core.c>
      # Apache 2.2
      Order Deny,Allow
      Deny from All
      Allow from 127.0.0.1
      Allow from ::1
    </IfModule>
</Directory>
<Directory /usr/share/phpmyadmin/setup/>
    <IfModule mod_authz_core.c>
      # Apache 2.4
      <RequireAny>
        Require ip 127.0.0.1
        Require ip ::1
      </RequireAny>
    </IfModule>
    <IfModule !mod_authz_core.c>
      # Apache 2.2
      Order Deny,Allow
      Deny from All
      Allow from 127.0.0.1
      Allow from ::1
    </IfModule>
</Directory>
# These directories do not require access over HTTP - taken from the original
# phpmyadmin upstream tarball
#
<Directory /usr/share/phpmyadmin/libraries/>
    Order Deny,Allow
    Deny from All
    Allow from None
</Directory>
<Directory /usr/share/phpmyadmin/setup/lib/>
    Order Deny,Allow
    Deny from All
    Allow from None
</Directory>
<Directory /usr/share/phpmyadmin/setup/frames/>
    Order Deny,Allow
    Deny from All
    Allow from None
</Directory>
EOF


sudo systemctl restart httpd

sudo systemctl restart php-fpm

echo "phpMyAdmin installed"

# Restart services
echo "Restarting services..."
sudo systemctl restart mariadb
sudo systemctl restart php-fpm
sudo systemctl restart httpd



#csf:
cd /tmp
yum install wget iptables -y
sudo dnf -y install @perl
wget https://download.configserver.com/csf.tgz
yum install perl-libwww-perl.noarch perl-LWP-Protocol-https.noarch perl-GDGraph -y
sudo tar -xvzf csf.tgz
cd csf
sudo sh install.sh
perl csftest.pl





# Generate a random 16-character root password
ROOT_PASSWORD=$(openssl rand -base64 12)
echo "Generated MariaDB Root Password: $ROOT_PASSWORD"

# Automate the secure installation
sudo mysql <<EOF
-- Set the root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROOT_PASSWORD';

-- Remove anonymous users
DELETE FROM mysql.user WHERE User='';

-- Disallow root login remotely
DELETE FROM mysql.user WHERE User='root' AND Host!='localhost';

-- Remove the test database
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Reload privilege tables
FLUSH PRIVILEGES;
EOF

echo "MariaDB secure installation completed."
echo "Root password: $ROOT_PASSWORD"

netstat -tlpn

echo "final script end"
