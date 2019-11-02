#!/bin/bash

apt-get update -y &&
apt-get install nginx -y &&
echo "It works!" > /var/www/html/index.html