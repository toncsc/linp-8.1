#!/usr/bin/env bash

if [ ! -z "${DOCKER_USER_ID}" ]; then
    usermod -u "${DOCKER_USER_ID}" "${DOCKER_USER}"
fi

if [ ${#} -gt 0 ]; then
    exec gosu "${DOCKER_USER_ID}" "${@}"
else
    chmod a+x /usr/bin/before-start
    /usr/bin/before-start 2>/dev/null
    /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
fi
