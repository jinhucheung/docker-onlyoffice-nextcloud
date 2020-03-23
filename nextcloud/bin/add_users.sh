#!/bin/bash

csv_file_path=$1
default_password=$2

IFS=","
while read username name email group || [[ -n $username ]]; do
  docker exec -u www-data -e "OC_PASS=$default_password" nextcloud-app php occ user:add $username --password-from-env --group="$group" --display-name="$name"
  docker exec -u www-data nextcloud-app php occ user:setting $username settings email "$email"
done < $csv_file_path