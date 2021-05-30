#!/bin/bash
# aks-acr-101.sh
#link01:https://roykim.ca/2020/12/27/az-cli-script-to-create-a-starter-aks-demo/
#link02:https://roykim.ca/2020/12/27/az-cli-script-to-create-a-starter-aks-demo/  
az account show -o table
az account list -o table
az account set -s 'Pay-As-You-Go'
az subscription -n 'Pay-As-You-Go'


# AKS
rgName='kzaksacr-rg' #'aks-solution'
aksName='kzaksacr-101'
location='eastus'


# create AKS cluster
####################
acrName='kzacr'
az group create -l $location -n $rgName #--subscription $appSubId

# Azure Container Registry
az acr create --resource-group $rgName  --name $acrName --sku Basic

acrResourceId=$(az acr show --name $acrName --resource-group $rgName --query "id" --output tsv)
az acr update -n $acrName --admin-enabled true
acr_userName=$(az acr credential show -n $acrName --query="username" -o tsv)
acr_pwd=$(az acr credential show -n $acrName --query="passwords[0].value" -o tsv)
echo $acr_userName $acr_pwd


az aks create --resource-group $rgName --name $aksName \
--node-count 1 \
 --enable-addons monitoring \
 --generate-ssh-keys \
 --attach-acr $acrResourceId \
  #--enable-addons monitoring --workspace-resource-id $logWorkspaceResourceId 

az aks get-credentials -n $aksName -g $rgName
 
az aks show  -n $aksName -g $rgName

# kubectl apply -f 'https://dev.azure.com/koomzo/azure%20consulting/_apis/sourceProviders/TfsGit/filecontents?repository=aksacr101&commitOrBranch=master&api-version=5.0-preview.1&path=%2Faksacr101%2Fdeployaks101.yaml'
#kubectl apply -f https://dev.azure.com/koomzo/azure%20consulting/_apis/sourceProviders/TfsGit/filecontents?repository=aksacr101&commitOrBranch=master&path=%2Faksacr101%2Fdeployaks101.yaml
kubectl apply -f https://raw.githubusercontent.com/glongchi/aksacr101/master/aksacr101/deployaks101.yaml
