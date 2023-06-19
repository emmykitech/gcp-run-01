#!/bin/bash

#set compute region/zone
gcloud config set compute/region us-west4
gcloud config set compute/zone us-west4-a

# creat compute resource 
gcloud compute instances create --machine-type=f1-micro nucleus-jumphost-217

#create compute clusters
gcloud container clusters create --machine-type=n1-standard-1 --zone=us-west4-a kub-cluster 

#authenticate kub server
gcloud container clusters get-credentials kub-cluster 

#create deploy kuberntes server 
kubectl create deployment hello-server --image=gcr.io/google-samples/hello-app:2.0

#create kub cluster port
kubectl expose deployment hello-server --type=LoadBalancer --port 8080
