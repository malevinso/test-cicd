#!/bin/sh

# vault login

export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=s.7BxQTGp7AK3NePvlW3OB1Rlc

NS_CREDS=netsuite
WD_CREDS=workday
ODS_CREDS=ods
AWS_CREDS=common
AP_CREDS=common
SUMO_CREDS=sumo
DB_CREDS=db/app

COMMON=common

getValueFromVault () {
    key=$1
    file=$2
    echo $(vault kv get -field=${key} secret/${file} )
}



## Export variable
export ANYPOINT_USERNAME=$(getValueFromVault 'anypoint.username' ${AP_CREDS}  )
export ANYPOINT_PASSWORD=$(getValueFromVault 'anypoint.password'  ${AP_CREDS} )

echo "ANYPOINT_USERNAME: ${ANYPOINT_USERNAME}"

#export ANYPOINT_BUSINESS_GROUP_ID=$(getValueFromVault 'anypoint.business.group.id' ${AP_CREDS} ${ENV} udx)
#export ANYPOINT_CLIENT_SECRET=$(getValueFromVault 'anypoint.platform.client_secret' ${AP_CREDS} ${ENV} udx) 
#export ANYPOINT_CLIENT_ID=$(getValueFromVault 'anypoint.platform.client_id' ${AP_CREDS} ${ENV} udx)

echo "Made it to secret-properties"






