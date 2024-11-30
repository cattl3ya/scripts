#!/bin/bash
#resolves a vhost name of a 301 reply and adds it to /etc/hosts
host=($(curl -I -s $1 | sed -n 's|.*http://||p'))
echo -e "$1\t$host" | sudo tee -a /etc/hosts
