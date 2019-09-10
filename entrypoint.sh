#!/bin/sh -l

set -e

SSH_PATH="$HOME/.ssh"

config_file=$1
ssh_host=$2
ssh_user=$3
installation_path=$4

version=$(yq read $config_file version)
dumpfile=$(yq read $config_file dumpfile)

echo "\n"
echo "------------------------------------------------"

echo "config_file:" $config_file
echo "ssh_host:" $ssh_host
echo "ssh_user:" $ssh_user
echo "installation_path:" $installation_path
echo "version:" $version
echo "dumpfile:" $dumpfile

echo "------------------------------------------------"
echo "\n"

mkdir -p "$SSH_PATH"
touch "$SSH_PATH/known_hosts"

chmod 700 "$SSH_PATH"
chmod 600 "$SSH_PATH/known_hosts"

eval $(ssh-agent)

rm -f ssh_key
echo "$ssh_key" > ssh_key
chmod 600 ssh_key

ssh-add ssh_key
ssh-keyscan -t rsa ${ssh_host} -f ./ssh_key >> "$SSH_PATH/known_hosts"

rm -rf "$dumpfile" || true


ssh -i ./ssh_key -o StrictHostKeyChecking=no -A -tt -p ${PORT:-22} ${ssh_user}@${ssh_host} rm db-prepare-dump.sql || true
echo "Exporting database"
ssh -i ./ssh_key -o StrictHostKeyChecking=no -A -tt -p ${PORT:-22} ${ssh_user}@${ssh_host} wp db export --path=${installation_path} db-prepare-dump.sql --allow-root
echo "Downloading databasedump"
rsync -chavzP -e "ssh -i ./ssh_key -o StrictHostKeyChecking=no" --stats ${ssh_user}@${ssh_host}:db-prepare-dump.sql ./
ssh -i ./ssh_key -o StrictHostKeyChecking=no -A -tt -p ${PORT:-22} ${ssh_user}@${ssh_host} rm db-prepare-dump.sql || true

mv db-prepare-dump.sql "$dumpfile"

db-prepare --config $config_file