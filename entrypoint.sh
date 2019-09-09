#!/bin/sh -l

config_file=$1
host=$2
installation_path=$3
ssh_key=$4

version=$(yq read $config_file version)
dumpfile=$(yq read $config_file dumpfile)

ssh_key=$(echo $ssh_key | base64 -D)



echo $ssh_key | ssh -i /dev/stdin $host wp db export --path=${installation_path} db-prepare-dump.sql --allow-root
echo $ssh_key | scp -i /dev/stdin $host:db-prepare-dump.sql $dumpfile
echo $ssh_key | ssh -i /dev/stdin $host rm db-prepare-dump.sql || true

db-prepare --config $config_file