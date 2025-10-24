#!/bin/bash
cat pat.txt | docker login -u <USERNAME> --password-stdin
cd /home/raj/Documents/terraform/challenge5/docker
version=$(curl -L --fail "https://hub.docker.com/v2/repositories/rajrishab/challenge2/tags/?page_size=1000" |     jq '.results | .[] | .name' -r |     sed 's/latest//' |      sort --version-sort |   tail -n 1)
major_version=$(echo "$version" | awk -F '.' '{print $1}')
minor_version=$(echo "$version" | awk -F '.' '{print $2 + 1}')

if [ $minor_version -le 8 ]; then
    minor_version=$(echo "$minor_version" | awk '{$1 = $1 + 1; print $1}')
else
    major_version=$(echo "$major_version" | awk '{$1 = $1 + 1; print $1}')
    minor_version=0
fi
new_tag=$(echo "rajrishab/challenge2:$major_version.$minor_version")
echo $new_tag
docker build -t $new_tag .
docker stop temp
docker rm temp
docker run -dit --name temp -p 80:80 $new_tag
# curl -I -w "%{http_code}\n" http://localhost
if [ $(curl -o /dev/null -s -w "%{http_code}\n" http://localhost) -eq 200 ]; then
    if [ $(curl -o /dev/null -s -w "%{http_code}\n" http://localhost/health/) -eq 200 ]; then
        # docker push $new_tag
        echo "endpoints are working fine"
    else
        echo "endpoint /health/ are not working fine"
    fi
else
echo "endpoint / are not working fine"
fi

