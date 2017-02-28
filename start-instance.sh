#!/bin/bash

set -x

IMAGE=jupyter-notebook:3.5

SERVICE=$1
NAME=$2

JUPYTERHUB_HOST_NAME=${JUPYTERHUB_HOST_NAME:-$SERVICE}
JUPYTERHUB_IMAGE_NAME=${JUPYTERHUB_IMAGE_NAME:-$IMAGE}

JUPYTERHUB_API_URL=http://$JUPYTERHUB_HOST_NAME:8080/hub/api

if [ x"$JUPYTERHUB_STORAGE_TYPE" == "persistent" ]; then
    PVC=pvc-$JUPYTER_NOTEBOOK_USER

    if oc get pvc/$PVC; then
        # pvc exists
    else
        oc process -f volume-claim.json \
            --value JUPYTER_NOTEBOOK_USER="$JUPYTER_NOTEBOOK_USER" | \
            oc create -f -
    fi

else
    oc new-app --file jupyter-ephemeral.json \
        --param JUPYTERHUB_IMAGE_NAME="$JUPYTERHUB_IMAGE_NAME" \
        --param JUPYTERHUB_HOST_NAME="$JUPYTERHUB_HOST_NAME" \
        --param JUPYTER_NOTEBOOK_USER="$JUPYTER_NOTEBOOK_USER" \
        --param JUPYTERHUB_API_TOKEN="$JUPYTERHUB_API_TOKEN" \
        --param JUPYTERHUB_API_URL="$JUPYTERHUB_API_URL" \
        --param JUPYTERHUB_SERVICE_PREFIX="$JUPYTERHUB_SERVICE_PREFIX" \
        --param JUPYTERHUB_SERVICE_NAME="$JUPYTERHUB_SERVICE_NAME" \
        --param JUPYTER_NOTEBOOK_PREFIX="$JUPYTER_NOTEBOOK_PREFIX" \
        --param JUPYTER_VOLUME_ROOTDIR="$JUPYTER_VOLUME_ROOTDIR" \
        --param JUPYTER_VOLUME_WORKSPACE="$JUPYTER_VOLUME_WORKSPACE"
fi
