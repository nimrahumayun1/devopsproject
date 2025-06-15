#!/bin/bash
set -ex

yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

docker run -d -p 3000:3000 --name metabase \
  -e MB_DB_TYPE="${mysql_DB_TYPE}" \
  -e MB_DB_DBNAME="${mysql_DB_NAME}" \
  -e MB_DB_PORT="${mysql_DB_PORT}" \
  -e MB_DB_USER="${mysql_DB_USER}" \
  -e MB_DB_PASS="${mysql_DB_PASS}" \
  -e MB_DB_HOST="${mysql_DB_HOST}" \
  metabase/metabase