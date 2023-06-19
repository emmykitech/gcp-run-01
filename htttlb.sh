#!/bin/bash

gcloud compute instance-templates create lb-backend-template \
   --region= \
   --network=default \
   --subnet=default \
   --tags=allow-health-check \
   --machine-type=f1-micro \
   --image-family=debian-11 \
   --image-project=debian-cloud 

cat << EOF > startup.sh
#! /bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
EOF


gcloud compute instance-groups managed create lb-backend-group \
   --template=lb-backend-template --size=2 --zone=us-west4-a


gcloud compute firewall-rules create fw-allow-health-check \
  --network=default \
  --action=allow \
  --direction=ingress \
  --source-ranges=130.211.0.0/22,35.191.0.0/16 \
  --target-tags=allow-health-check \
  --rules=tcp:80


gcloud compute health-checks create http http-basic-check --port 80



gcloud compute backend-services create web-backend-service \
  --protocol=HTTP \
  --port-name=http \
  --health-checks=http-basic-check \
  --global


gcloud compute backend-services add-backend web-backend-service \
  --instance-group=lb-backend-group \
  --instance-group-zone= \
  --global
  

gcloud compute url-maps create web-map-http \
    --default-service web-backend-service


gcloud compute target-http-proxies create http-lb-proxy \
    --url-map web-map-http


gcloud compute forwarding-rules create http-content-rule \
    --address=lb-ipv4-1\
    --global \
    --target-http-proxy=http-lb-proxy \
    --ports=80