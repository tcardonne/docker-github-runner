#!/bin/bash

# Ensure Docker socket
if [[ -e "/var/run/docker.sock" ]]; then
    sudo chgrp docker /var/run/docker.sock
fi

if [[ "$@" == "bash" ]]; then
    exec $@
fi

if [[ -z $RUNNER_NAME ]]; then
    echo "RUNNER_NAME environment variable is not set, using '${HOSTNAME}'."
    export RUNNER_NAME=${HOSTNAME}
fi

if [[ -z $RUNNER_WORK_DIRECTORY ]]; then
    echo "RUNNER_WORK_DIRECTORY environment variable is not set, using '_work'."
    export RUNNER_WORK_DIRECTORY="_work"
fi

if [[ -z $RUNNER_TOKEN ]]; then
    echo "Error : You need to set the RUNNER_TOKEN environment variable."
    exit 1
fi

if [[ -z $RUNNER_REPOSITORY_URL ]]; then
    echo "Error : You need to set the RUNNER_REPOSITORY_URL environment variable."
    exit 1
fi

if [[ -f ".runner" ]]; then
    echo "Runner already configured. Skipping config."
else
    ./config.sh \
        --url $RUNNER_REPOSITORY_URL \
        --token $RUNNER_TOKEN \
        --agent $RUNNER_NAME \
        --work $RUNNER_WORK_DIRECTORY
fi

exec "$@"