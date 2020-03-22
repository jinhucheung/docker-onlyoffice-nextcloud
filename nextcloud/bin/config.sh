#!/bin/bash

cd $(dirname $0)

docker exec -u www-data nextcloud-app php occ --no-warnings config:system:get trusted_domains >> trusted_domain.tmp
if ! grep -q "nginx-server" trusted_domain.tmp; then
    TRUSTED_INDEX=$(cat trusted_domain.tmp | wc -l);
    docker exec -u www-data nextcloud-app php occ --no-warnings config:system:set trusted_domains $TRUSTED_INDEX --value="nginx-server"
fi
rm trusted_domain.tmp

# install plugins
[ -d tmp ] && rm -rf tmp
mkdir tmp
for plugin in `ls ../plugins/*.tar.gz`; do (tar -xf $plugin -C tmp) done
for plugin in `ls tmp`
do
  docker cp tmp/$plugin nextcloud-app:/var/www/html/apps/
  docker exec -u www-data nextcloud-app php occ --no-warnings app:enable $plugin
done
rm -rf tmp
# docker exec -u www-data nextcloud-app php occ --no-warnings app:install onlyoffice

# set config
docker exec -u www-data nextcloud-app php occ --no-warnings config:system:set default_language --value="zh_CN"
docker exec -u www-data nextcloud-app php occ --no-warnings config:system:set default_locale --value="zh-cn"
docker exec -u www-data nextcloud-app php occ --no-warnings config:system:set logtimezone --value="Asia/Hong_Kong"

docker exec -u www-data nextcloud-app php occ --no-warnings config:system:set skeletondirectory --value="/var/www/html/_public/skeleton"

docker exec -u www-data nextcloud-app php occ --no-warnings config:system:set onlyoffice DocumentServerUrl --value="/ds-vpath/"
docker exec -u www-data nextcloud-app php occ --no-warnings config:system:set onlyoffice DocumentServerInternalUrl --value="http://onlyoffice-document-server/"
docker exec -u www-data nextcloud-app php occ --no-warnings config:system:set onlyoffice StorageUrl --value="http://nginx-server/"

cd -