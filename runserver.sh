#!/bin/bash

#set compute region/zone
gcloud config set compute/region us-west4
gcloud config set compute/zone us-west4-b

# creat compute resource 
gcloud compute instances create --machine-type=f1-micro nucleus-jumphost-918

#create compute clusters
gcloud container clusters create --machine-type=n1-standard-1 --zone=us-west4-b kub-cluster 


# Sleep for 5 minutes (300 seconds)
sleep 300

#authenticate kub server
gcloud container clusters get-credentials kub-cluster 


#sleep for 2 minutes (120 seconds)
sleep 120

#create deploy kuberntes server 
kubectl create deployment hello-server --image=gcr.io/google-samples/hello-app:2.0


#sleep for 1  minutes (60 seconds)


#create kub cluster port
kubectl expose deployment hello-server --type=LoadBalancer --port 8082
