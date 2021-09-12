#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
sudo systemctl start httpd.service
sudo systemctl enable httpd.service
echo " *--Салам дүйнө--* from $(hostname -f)" > /var/www/html/index.html