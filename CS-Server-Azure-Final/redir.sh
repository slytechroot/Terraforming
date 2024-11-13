#!/bin/bash

# sleep until instance is ready
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done

echo "Start of Redir Script"

# Set important Vars
Uname="root"
Password=`openssl rand -hex 16`
MYDOMAIN=$1
PORT=$2

echo "Using $MYDOMAIN in script"

# Set SSH PUB keys
GREG='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDUAto/xQ2PO5L2t+FvwWWhcqVreQJ+MvRZcP3+Vrhfm gregory.hatcher@AMAC104.local'
STIGS='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ6ekCSzMgl3hYFomyfp7IHzyUOvF5qIMn8UiL6mlco6 john.stigerwalt'

#Changing Root Password
echo "Chaning Root account password"
echo ${Uname}:${Password} | sudo chpasswd

#Add SSH Keys to Root
echo "Adding SSH keys to root account"
echo $GREG | sudo tee /root/.ssh/authorized_keys
echo $STIGS | sudo tee -a /root/.ssh/authorized_keys

# Setup SSH
echo "Configure SSH for Tunnel access"
sudo echo -e "\nPermitTunnel yes" >> /etc/ssh/sshd_config
sudo service ssh reload

# Update box
echo "Updating box.."
sudo apt update && sudo apt upgrade -y && sudo apt install openjdk-11-jdk -y && sudo apt install net-tools nmap -y

# Apache Install and setup config
echo "Setting up Apache"
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo apt install certbot python3-certbot-apache -y
sudo apt install libapache2-mod-security2 -y
sudo a2dissite 000-default.conf
sudo a2enmod proxy proxy_ajp proxy_http rewrite deflate headers proxy_balancer proxy_connect proxy_html
sudo a2dismod autoindex -f
sudo a2enmod security2
sudo sed -i "s/ServerSignature On/ServerSignature Off/g" /etc/apache2/conf-available/security.conf
echo "SecServerSignature Microsoft-IIS/10.0" | sudo tee -a /etc/apache2/conf-available/security.conf
sudo sed -i "s/ServerTokens OS/ServerTokens Full/g" /etc/apache2/conf-available/security.conf
sudo systemctl restart apache2


# Start Domain Setup:
echo "Creating $MYDOMAIN dirs now.."
sudo mkdir /var/www/$MYDOMAIN
sudo chown -R root:root /var/www/$MYDOMAIN
sudo chmod -R 755 /var/www/$MYDOMAIN
sudo mkdir /var/www/$MYDOMAIN/logs

#Setup Virtual Host file
echo "Setting up First Virtual Host file.."
sudo echo -e "<VirtualHost *:80>    \n\tServerAdmin webmaster@localhost    \n\tServerName $MYDOMAIN    \n\tServerAlias www.$MYDOMAIN     \n\tDocumentRoot /var/www/$MYDOMAIN    \n\tErrorLog ${APACHE_LOG_DIR}/error.log    \n\tCustomLog ${APACHE_LOG_DIR}/access.log combined\n</VirtualHost>" >> /etc/apache2/sites-available/$MYDOMAIN.conf
sudo a2ensite $MYDOMAIN.conf
sudo systemctl restart apache2

# Check for domain to resolve:
while true; do
    nc $MYDOMAIN 80 < /dev/null
    if [ $? -eq 0 ]; then
        break
    fi
    echo "Sleeping 2.5 mins for DNS resolve"
    sleep 150
done
echo "Looks like we might have some DNS updates. Its possible I am wrong!"
echo "If I fail run: sudo certbot --apache --email admin@$MYDOMAIN --agree-tos --no-eff-email -d $MYDOMAIN --redirect --hsts --uir"

# Final Domain Setup
sudo certbot --apache --email admin@$MYDOMAIN --agree-tos --no-eff-email -d $MYDOMAIN --redirect --hsts --uir
echo "Certbot should be done now.."
sudo systemctl restart apache2

# Add to final Virutal hosts file
echo "Setting up final VirtualHost file for SSL"
#sudo sed '/^<VirtualHost \*:443>/a \\nSSLProxyEngine on \nSSLProxyVerify none \nSSLProxyCheckPeerCN off \nSSLProxyCheckPeerName off \n\nProxyPreserveHost On \n\nProxyPass / http://172.31.22.251:8000/ \nProxyPassReverse / http://172.31.22.251:8000/ \n' > /etc/apache2/sites-available/$MYDOMAIN-le-ssl.conf
#sudo sed '/^<\/VirtualHost>/i Header always set X-XSS-Protection "1; mode=block" \n Header always set X-Frame-Options "SAMEORIGIN" \n Header always set X-Content-Type-Options "nosniff" \n Header always set Referrer-Policy "strict-origin" \n Header set Content-Type "text/html; charset=utf-8" \n\nErrorDocument 404 /error.html \n' > /etc/apache2/sites-available/$MYDOMAIN-le-ssl.conf

#sudo sed '/^<VirtualHost \*:443>/a \\nSSLProxyEngine on \nSSLProxyVerify none \nSSLProxyCheckPeerCN off \nSSLProxyCheckPeerName off \n\nProxyPreserveHost On \n\nProxyPass / http://172.31.22.251:8000/ \nProxyPassReverse / http://172.31.22.251:8000/ \n' /etc/apache2/sites-available/$MYDOMAIN-le-ssl.conf > /tmp/$MYDOMAIN-le-ssl.conf
#sudo sed '/^<\/VirtualHost>/i Header always set X-XSS-Protection "1; mode=block" \n Header always set X-Frame-Options "SAMEORIGIN" \n Header always set X-Content-Type-Options "nosniff" \n Header always set Referrer-Policy "strict-origin" \n Header set Content-Type "text/html; charset=utf-8" \n\nErrorDocument 404 /error.html \n' /tmp/$MYDOMAIN-le-ssl.conf > /tmp/$MYDOMAIN-le-ssl.conf.tmp

sed '/^<VirtualHost \*:443>/a \\nSSLProxyEngine on \nSSLProxyVerify none \nSSLProxyCheckPeerCN off \nSSLProxyCheckPeerName off \nProxyPreserveHost On \nRewriteEngine on \n\n# First We do a useragent check \nRewriteCond %{HTTP_USER_AGENT} (google|yandex|bingbot|Googlebot|bot|spider|simple|BBBike|wget|cloudfront|curl|Python|Wget|crawl|baidu|Lynx|xforce|HTTrack|Slackbot|netcraft|NetcraftSurveyAgent|Netcraft) [NC] \nRewriteRule . - [R=403,L,P] \n\n# next we check for keyname parameter \nRewriteCond %{QUERY_STRING} (^|&)keyname=[A-Z0-9a-z]+(&|$) \nRewriteRule "^/(.*)" "http://10.10.0.205:REPLACE_PORT/$1" [P] \nProxyPassReverse / http://10.10.0.205:REPLACE_PORT/' /etc/apache2/sites-available/$MYDOMAIN-le-ssl.conf | sed 's/ErrorLog \/error.log/#ErrorLog \/error.log/g' | sed 's/CustomLog \/access.log combined/#CustomLog \/access.log combined/g' > /tmp/$MYDOMAIN-le-ssl.conf
sed '/^<\/VirtualHost>/i Header always set X-XSS-Protection "1; mode=block" \n Header always set X-Frame-Options "SAMEORIGIN" \n Header always set X-Content-Type-Options "nosniff" \n Header always set Referrer-Policy "strict-origin" \n Header set Content-Type "text/html; charset=utf-8" \n\nErrorDocument 404 /error.html \n\nErrorLog /var/www/CHANGEME/logs/error.log \nCustomLog /var/www/CHANGEME/logs/access.log combined \n\n<Directory /var/www/CHANGEME/logs> \n\tOrder deny,allow \n\tDeny from all \n</Directory>\n' /tmp/$MYDOMAIN-le-ssl.conf | sed "s/CHANGEME/$MYDOMAIN/g" > /tmp/$MYDOMAIN-le-ssl.conf.tmp
sudo cat /tmp/$MYDOMAIN-le-ssl.conf.tmp | sed "s/REPLACE_PORT/$PORT/g" > /tmp/$MYDOMAIN-le-ssl.conf-01.tmp


echo "Moving tmp config file to final location.."
sudo mv /tmp/$MYDOMAIN-le-ssl.conf-01.tmp /etc/apache2/sites-available/$MYDOMAIN-le-ssl.conf

# Creat 404.html webpage
echo "Setting up final error.html page in $MYDOMAIN dir"
sudo echo -e '<!DOCTYPE html>\n<html>\n<body>\n\n<style>\n*{\n    transition: all 0.6s;\n}\n\nhtml {\n    height: 100%;\n}\n\nbody{\n    font-family: 'Lato', sans-serif;\n    color: #888;\n    margin: 0;\n}\n\n#main{\n    display: table;\n    width: 100%;\n    height: 100vh;\n    text-align: center;\n}\n\n.fof{\n        display: table-cell;\n        vertical-align: middle;\n}\n\n.fof h1{\n        font-size: 50px;\n        display: inline-block;\n        padding-right: 12px;\n        animation: type .5s alternate infinite;\n}\n\n@keyframes type{\n        from{box-shadow: inset -3px 0px 0px #888;}\n        to{box-shadow: inset -3px 0px 0px transparent;}\n}\n</style>\n\n<div id="main">\n      <div class="fof">\n            <h1>Error 404</h1>\n      </div>\n</div>\n</body>\n</html>\n' > /var/www/$MYDOMAIN/error.html

#Final Apache restart
echo "Final Apache restart"
sudo systemctl restart apache2

echo "Killing Script"
exit 0


