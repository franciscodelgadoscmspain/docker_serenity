#!/usr/bin/env bash

env=`grep ^ENV /opt/sgm/vars | cut -d"=" -f2`
version=`grep ^VERSION /opt/sgm/vars | cut -d"=" -f2 | cut -d"." -f1-2`
sed -i 's/{{version}}/'"$version"'/' ./Dockerfile

serenity_master_id=0
serenity_admin_port=5654
serenity_http_port=5657

sed -i 's/{{serenity_admin_port}}/'"$serenity_admin_port"'/' ./Dockerfile
sed -i 's/{{serenity_http_port}}/'"$serenity_http_port"'/' ./Dockerfile

docker build --rm -t="serenity/${env}:${version}" . &&

docker run -d --name="serenity_master_${serenity_master_id}" --net=bridge -p $serenity_http_port:$serenity_http_port -p $serenity_http_port:$serenity_http_port serenity/$env:$version