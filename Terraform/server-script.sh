#!/bin/bash
echo "Performing OS Update"
echo
sudo yum update
echo "Installing httpd Update"
echo
sudo yum install -y httpd
echo "Starting and Enabling httpd Update"
echo
sudo systemctl start httpd
sudo systemctl enable httpd
echo "Hello from Terraform" | sudo tee /var/www/html/index.html