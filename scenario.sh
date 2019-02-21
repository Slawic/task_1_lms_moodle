  sudo yum clean all
  sudo yum -y update
  sudo rpm -Uvh  http://download.moodle.org/releases/latest/
  sudo yum -y install httpd
  sudo firewall-cmd --permanent --add-port=80/tcp
  sudo firewall-cmd --permanent --add-port=443/tcp
  sudo firewall-cmd --reload
  sudo systemctl start httpd.service
  sudo systemctl enable httpd
  ##  sudo systemctl status httpd
  ##  sudo systemctl stop httpd
  ##  sudo yum -y install apache2

