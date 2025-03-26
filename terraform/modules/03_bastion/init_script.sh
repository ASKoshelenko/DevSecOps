#!/bin/bash
set -e

# Wait for apt lock to be released
wait_for_apt() {
  while sudo fuser /var/lib/apt/lists/lock >/dev/null 2>&1 ; do
    echo "Waiting for other apt-get instances to finish..."
    sleep 1
  done
}

wait_for_apt

# Update and install necessary packages
sudo apt-get update
sudo apt-get install -y mc htop default-mysql-client wget

# Download DigiCert Global Root CA certificate
sudo wget https://dl.cacerts.digicert.com/DigiCertGlobalRootCA.crt.pem -O /home/${admin_username}/DigiCertGlobalRootCA.crt.pem
sudo chown ${admin_username}:${admin_username} /home/${admin_username}/DigiCertGlobalRootCA.crt.pem
sudo chmod 644 /home/${admin_username}/DigiCertGlobalRootCA.crt.pem

# Create a MySQL configuration file with SSL settings
sudo tee /home/${admin_username}/.my.cnf << EOF
[client]
ssl-ca=/home/${admin_username}/DigiCertGlobalRootCA.crt.pem
ssl=1
EOF

# Set correct permissions for the MySQL configuration file
sudo chown ${admin_username}:${admin_username} /home/${admin_username}/.my.cnf
sudo chmod 600 /home/${admin_username}/.my.cnf

echo "MySQL client installed and configured with SSL certificate for user ${admin_username}."
