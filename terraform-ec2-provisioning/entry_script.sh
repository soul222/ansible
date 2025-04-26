#!/bin/bash
yum update -y
yum install -y docker
service docker start
usermod -aG docker ec2-user
docker run -d -p 8080:80 nginx