#!/bin/bash
# vi: ft=bash

curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | tee \
    /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian binary/ | tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null

# install java, nginx, and jenkins
apt update
apt-get -y upgrade

apt-get -y install \
    openjdk-11-jdk \
    nginx \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

apt-get -y install jenkins

# configure jenkins
echo "# $(date) Configure Jenkins..."

## skip the installation wizard at startup
echo "JAVA_ARGS=\"-Djenkins.install.runSetupWizard=false\"" >> /etc/default/jenkins

## download the list of plugins
wget https://raw.githubusercontent.com/jenkinsci/jenkins/master/core/src/main/resources/jenkins/install/platform-plugins.json

## get the suggested plugins
grep suggest platform-plugins.json | cut -d\" -f 4 | tee suggested-plugins.txt

## download the plugin installation tool
wget https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.3/jenkins-plugin-manager-2.12.3.jar

## run the plugin installation tool
/usr/bin/java -jar ./jenkins-plugin-manager-2.12.3.jar \
	--verbose \
    --plugin-download-directory=/var/lib/jenkins/plugins \
    --plugin-file=./suggested-plugins.txt >> /var/log/plugin-installation.log

## because the plugin installation tool runs as root, ownership on
## the plugin dir needs to be changed back to jenkins:jenkins
## otherwise, jenkins won't be able to install the plugins
chown -R jenkins:jenkins /var/lib/jenkins/plugins

echo "# $(date) Restart Jenkins..."
systemctl restart jenkins

echo "# $(date) Copy the initial admin password to the root user's home directory..."
cp /var/lib/jenkins/secrets/initialAdminPassword ~

clear
echo "Installation is complete."

echo "# Open the URL for this server in a browser and log in with the following credentials:"
echo
echo
echo "    Username: admin"
echo "    Password: $(cat /var/lib/jenkins/secrets/initialAdminPassword)"
echo
echo
