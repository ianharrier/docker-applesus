#!/bin/sh
set -e

CONFIG_FILE='/etc/apache2/sites-available/000-default.conf'
if [ "$(cat $CONFIG_FILE | grep AUTH_INCOMPLETE)" ]; then
    if [ "$AUTH_TYPE" = 'ad' ]; then
        echo "[I] Enabling Active Directory authentication."
        sed -i '/BEGIN_NO_AUTH/,/END_NO_AUTH/d' $CONFIG_FILE
        sed -i '/BEGIN_AD_AUTH/d' $CONFIG_FILE
        sed -i '/END_AD_AUTH/d' $CONFIG_FILE
        sed -i "s|AUTH_AD_URL_CHANGE_ME|$AUTH_AD_URL|g" $CONFIG_FILE
        sed -i "s|AUTH_AD_BIND_USER_DN_CHANGE_ME|$AUTH_AD_BIND_USER_DN|g" $CONFIG_FILE
        sed -i "s|AUTH_AD_BIND_PASSWORD_CHANGE_ME|$AUTH_AD_BIND_PASSWORD|g" $CONFIG_FILE
        sed -i "s|AUTH_AD_ALLOWED_GROUP_DN_CHANGE_ME|$AUTH_AD_ALLOWED_GROUP_DN|g" $CONFIG_FILE
    else
        echo "[I] Disabling authentication."
        sed -i '/BEGIN_AD_AUTH/,/END_AD_AUTH/d' $CONFIG_FILE
        sed -i '/BEGIN_NO_AUTH/d' $CONFIG_FILE
        sed -i '/END_NO_AUTH/d' $CONFIG_FILE
    fi
    sed -i '/AUTH_INCOMPLETE/d' $CONFIG_FILE
fi

if [ "$(cat ./preferences.plist | grep URL_BASE_CHANGE_ME)" ]; then
    if [ "$URL_BASE" ]; then
        echo "[I] Setting the URL base."
        sed -i "s/URL_BASE_CHANGE_ME/$URL_BASE/g" ./preferences.plist
    else
        echo "[I] Setting an empty URL base."
        sed -i "s/URL_BASE_CHANGE_ME//g" ./preferences.plist
    fi
fi

echo "[I] Entrypoint tasks complete. Starting Margarita."
exec "$@"
