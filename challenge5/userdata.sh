#!/bin/bash
sudo dnf update -y
sudo dnf install -y docker
sudo usermod -aG docker ec2-user
sudo systemctl start docker
sudo docker run -p 80:80 --name tempo rajrishab/challenge2:1.4
echo "running"
