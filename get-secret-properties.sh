#!/bin/sh

# vault login

echo "Credentials Script ENV=${ENV}"

NS_CREDS=netsuite
WD_CREDS=workday
ODS_CREDS=ods
AWS_CREDS=aws
AP_CREDS=anypoint
SUMO_CREDS=sumo
DB_CREDS=db/app

COMMON=common


CLUSTER=srv02
ROLE=dataengineering-jenkins-udx
TOKEN=`cat /var/run/secrets/kubernetes.io/serviceaccount/token`

export VAULT_TOKEN=`vault write -field=token auth/$CLUSTER/login role=$ROLE jwt=$TOKEN`

getValueFromVault () {
    key=$1
    file=$2
    env=$3
    proj=$4
    echo $(vault kv get -field=${key} secret-v2/${proj}/${env}/${file} 2>/dev/null)
}


## Export variable
export ANYPOINT_USERNAME=$(getValueFromVault 'anypoint.username' ${AP_CREDS}  ${ENV}  udx)
export ANYPOINT_PASSWORD=$(getValueFromVault 'anypoint.password'  ${AP_CREDS}  ${ENV}  udx)

export ANYPOINT_BUSINESS_GROUP_ID=$(getValueFromVault 'anypoint.business.group.id' ${AP_CREDS} ${ENV} udx)
export ANYPOINT_CLIENT_SECRET=$(getValueFromVault 'anypoint.platform.client_secret' ${AP_CREDS} ${ENV} udx) 
export ANYPOINT_CLIENT_ID=$(getValueFromVault 'anypoint.platform.client_id' ${AP_CREDS} ${ENV} udx)

export NS_ACCOUNT=$(getValueFromVault 'account' ${NS_CREDS} ${ENV} enterprise)
export NS_CONSUMER_KEY=$(getValueFromVault 'consumer.key' ${NS_CREDS} ${ENV} enterprise)
export NS_CONSUMER_SECRET=$(getValueFromVault 'customer.secret' ${NS_CREDS} ${ENV} enterprise)

export NS_TOKEN_ID=$(getValueFromVault 'token.id' ${NS_CREDS} ${ENV} enterprise)
export NS_TOKEN_SECRET=$(getValueFromVault 'token.secret' ${NS_CREDS} ${ENV} enterprise)

export WD_USERNAME=$(getValueFromVault 'username' ${WD_CREDS} ${ENV} enterprise)
export WD_PASSWORD=$(getValueFromVault 'password' ${WD_CREDS} ${ENV} enterprise)
export WD_TENANT_NAME=$(getValueFromVault 'tenant' ${WD_CREDS} ${ENV} enterprise)
export WD_HOST_NAME=$(getValueFromVault 'host' ${WD_CREDS} ${ENV} enterprise)

export DB_PASSWORD=$(getValueFromVault 'password' ${DB_CREDS} ${ENV} enterprise)





