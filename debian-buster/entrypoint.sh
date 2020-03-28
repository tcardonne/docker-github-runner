#!/bin/bash

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

if [[ -z $RUNNER_TOKEN && -z $GITHUB_ACCESS_TOKEN ]]; then
    echo "Error : You need to set RUNNER_TOKEN (or GITHUB_ACCESS_TOKEN) environment variable."
    exit 1
fi

if [[ -z $RUNNER_REPOSITORY_URL ]]; then
    echo "Error : You need to set the RUNNER_REPOSITORY_URL environment variable."
    exit 1
fi

if [[ -z $RUNNER_REPLACE_EXISTING ]]; then
    export RUNNER_REPLACE_EXISTING="true"
fi

CONFIG_OPTS=""
if [ "$(echo $RUNNER_REPLACE_EXISTING | tr '[:upper:]' '[:lower:]')" == "true" ]; then
	CONFIG_OPTS="--replace"
fi

if [[ -f ".runner" ]]; then
    echo "Runner already configured. Skipping config."
else
    if [[ -n $GITHUB_ACCESS_TOKEN ]]; then
        echo "Exchanging the GitHub Access Token with a Runner Token..."
        _PROTO="$(echo "${RUNNER_REPOSITORY_URL}" | grep :// | sed -e's,^\(.*://\).*,\1,g')"
        _URL="$(echo "${RUNNER_REPOSITORY_URL/${_PROTO}/}")"
        _PATH="$(echo "${_URL}" | grep / | cut -d/ -f2-)"
        _ACCOUNT="$(echo "${_PATH}" | cut -d/ -f1)"
        _REPO="$(echo "${_PATH}" | cut -d/ -f2)"

        RUNNER_TOKEN="$(curl -XPOST -fsSL \
            -H "Authorization: token ${GITHUB_ACCESS_TOKEN}" \
            -H "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/repos/${_ACCOUNT}/${_REPO}/actions/runners/registration-token" \
            | jq -r '.token')"
    fi

    ./config.sh \
        --url $RUNNER_REPOSITORY_URL \
        --token $RUNNER_TOKEN \
        --name $RUNNER_NAME \
        --work $RUNNER_WORK_DIRECTORY \
        $CONFIG_OPTS \
        --unattended
fi

exec "$@"