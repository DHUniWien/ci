#!/bin/sh

CONFIG_FILE=$1

. ${CONFIG_FILE}

/bin/chmod 600 ${SSH_KEY}

SSH="/usr/bin/ssh \
    -o StrictHostKeyChecking=no \
    -i ${SSH_KEY} \
    ci@${DEPLOY_HOST}"

EXTRA_OPTIONS=''

INSTANCE_RUNNING=`$SSH  /usr/bin/docker ps --format "{{.Names}}" | grep -e "${INSTANCE_NAME}"`
if [ "${INSTANCE_RUNNING}" ] ; then
    echo "stop running instance <${INSTANCE_NAME}> ..."
    $SSH  /usr/bin/docker stop ${INSTANCE_NAME}
fi

INSTANCE_EXISTS=`$SSH  /usr/bin/docker ps -a --format "{{.Names}}" | grep -e "${INSTANCE_NAME}"`
if [ "${INSTANCE_EXISTS}" ] && [ "${REMOVE_OLD_INSTANCE}" = "yes" ] ; then
    echo "remove instance <${INSTANCE_NAME}> ..."
    echo "please note, that only inline volumes will be removed with it"
    $SSH  /usr/bin/docker rm ${INSTANCE_NAME}
fi

echo "pull latest of <${REGISTRY}/${IMAGE}:${TAG}>"
$SSH  /usr/bin/docker pull ${REGISTRY}/${IMAGE}:${TAG}

# sh:   -n ... True if the length of string is nonzero.
# bash: -v ... True if the shell variable varname is set (has been assigned a value).
if [ -n "${VOLUME}" ] ; then
    VOLUME_EXISTS=`$SSH  /usr/bin/docker volume ls | awk "{print $2}" | grep -e "${VOLUME}"`
    if [ ! "${VOLUME_EXISTS}" ] ; then
        echo "create volume <${VOLUME}> ..."
        echo "/usr/bin/docker volume create --name ${VOLUME}"
        $SSH  /usr/bin/docker volume create --name ${VOLUME}
    # remove already existing volumes of the same name as ${VOLUME}
    # elif [ "${VOLUME_EXISTS}" ] && [ "${REMOVE_OLD_VOLUME}" = "yes" ] ; then
    #     echo "remove volume <${VOLUME_NAME}> ..."
    #     $SSH  /usr/bin/docker volume rm ${VOLUME_NAME}
    #     echo "create volume <${VOLUME}> ..."
    #     echo "/usr/bin/docker volume create --name ${VOLUME}"
    #     $SSH  /usr/bin/docker volume create --name ${VOLUME}
    fi

    if [ -n "${VOLUME_MOUNT_AT}" ] ; then
        EXTRA_OPTIONS=${EXTRA_OPTIONS}" --volume ${VOLUME}:${VOLUME_MOUNT_AT}"
    else
        # legacy default
        EXTRA_OPTIONS=${EXTRA_OPTIONS}" --volume ${VOLUME}:/var/lib/stemmarest/"
    fi
fi

if [ -n "${HOST_PORT}" ] && [ -n "${CONTAINER_PORT}" ]; then
    EXTRA_OPTIONS=${EXTRA_OPTIONS}" --publish ${HOST}:${HOST_PORT}:${CONTAINER_PORT}"
fi

if [ -n "${CONTAINER_USER}" ]; then
    EXTRA_OPTIONS=${EXTRA_OPTIONS}" --user ${CONTAINER_USER}"
fi

if [ -n "${CONTAINER_ENV}" ]; then
    EXTRA_OPTIONS=${EXTRA_OPTIONS}" --env ${CONTAINER_ENV}"
fi

if [ -n "${TTY}" ] && [ "${TTY}" = "yes" ] ; then
    EXTRA_OPTIONS=${EXTRA_OPTIONS}" --tty"
fi

if [ -n "${LINK}" ] ; then
    EXTRA_OPTIONS=${EXTRA_OPTIONS}" --link ${LINK}"
fi

echo "create new container"
echo "/usr/bin/docker create \
  --name    ${INSTANCE_NAME} \
  --memory  ${MEMORY} \
  --cpu-period=100000 \
  --cpu-quota=100000 \
  --restart always \
  $EXTRA_OPTIONS \
${REGISTRY}/${IMAGE}:${TAG}"

$SSH  /usr/bin/docker create \
  --name    ${INSTANCE_NAME} \
  --memory  ${MEMORY} \
  --cpu-period=100000 \
  --cpu-quota=100000 \
  --restart always \
  $EXTRA_OPTIONS \
${REGISTRY}/${IMAGE}:${TAG}

$SSH  /usr/bin/docker start ${INSTANCE_NAME}
