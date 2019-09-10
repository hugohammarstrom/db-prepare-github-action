#!/bin/sh -l

config_file=$1
host=$2
installation_path=$3

echo "config_file:" $config_file
echo "host:" $host
echo "installation_path:" $installation_path

version=$(yq read $config_file version)
dumpfile=$(yq read $config_file dumpfile)

ssh_key=$(echo $ssh_key | openssl enc -base64 -d)

echo $ssh_key > ssh_key

ssh -i ./ssh_key $host wp db export --path=${installation_path} db-prepare-dump.sql --allow-root
scp -i ./ssh_key $host:db-prepare-dump.sql $dumpfile
ssh -i ./ssh_key $host rm db-prepare-dump.sql || true

db-prepare --config $config_file