# GitHub Runner - DEPRECATED

**This repository is deprecated and unmaintained.**

Consider using:
- [myoung34/docker-github-actions-runner](https://github.com/myoung34/docker-github-actions-runner)
- [actions/actions-runner-controller](https://github.com/actions/actions-runner-controller)

-----------

[![Docker Pulls](https://img.shields.io/docker/pulls/tcardonne/github-runner)](https://hub.docker.com/r/tcardonne/github-runner)

-----------
GitHub allows developers to run GitHub Actions workflows on your own runners.
This Docker image allows you to create your own runners on Docker.

For now, there are only Debian Buster (tagged with `latest` and `vX.Y.Z`) and Ubuntu Focal (tagged with `ubuntu-20.04` and `vX.Y.Z-ubuntu-20.04`) images, but I may add more variants in the future. Feel free to create an issue if you want another base image.

## Important notes

* GitHub [recommends](https://help.github.com/en/github/automating-your-workflow-with-github-actions/about-self-hosted-runners#self-hosted-runner-security-with-public-repositories) that you do **NOT** use self-hosted runners with public repositories, for security reasons.
* Organization level self-hosted runners are supported (see environment variables), but be advised that the GitHub API for organization level runners is still in public beta and subject to changes.

## Usage

### Basic usage
Use the following command to start listening for jobs:
```shell
docker run -it --name my-runner \
    -e RUNNER_NAME=my-runner \
    -e GITHUB_ACCESS_TOKEN=token \
    -e RUNNER_REPOSITORY_URL=https://github.com/... \
    tcardonne/github-runner
```

### Using Docker inside your Actions

If you want to use Docker inside your runner (ie, build images in a workflow), you can enable Docker siblings by binding the host Docker daemon socket. Please keep in mind that doing this gives your actions full control on the Docker daemon.

```shell
docker run -it --name my-runner \
    -e RUNNER_NAME=my-runner \
    -e GITHUB_ACCESS_TOKEN=token \
    -e RUNNER_REPOSITORY_URL=https://github.com/... \
    -v /var/run/docker.sock:/var/run/docker.sock \
    tcardonne/github-runner
```

### Using docker-compose.yml

In `docker-compose.yml` :
```yaml
version: "3.7"

services:
    runner:
      image: tcardonne/github-runner:latest
      environment:
        RUNNER_NAME: "my-runner"
        RUNNER_REPOSITORY_URL: ${RUNNER_REPOSITORY_URL}
        #RUNNER_ORGANIZATION_URL: ${RUNNER_ORGANIZATION_URL}
        GITHUB_ACCESS_TOKEN: ${GITHUB_ACCESS_TOKEN}
      volumes:
        - /var/run/docker.sock:/var/run/docker.sock
```

You can create a `.env` to provide environment variables when using docker-compose :
```
RUNNER_REPOSITORY_URL=https://github.com/your_url/your_repo
# or RUNNER_ORGANIZATION_URL=https://github.com/your-organization
GITHUB_ACCESS_TOKEN=the_runner_token
```

## Environment variables

The following environment variables allows you to control the configuration parameters.

| Name | Description | Required/Default value |
|------|---------------|-------------|
| RUNNER_REPOSITORY_URL | The runner will be linked to this repository URL | Required if `RUNNER_ORGANIZATION_URL` is not provided |
| RUNNER_ORGANIZATION_URL | The runner will be linked to this organization URL. *(Self-hosted runners API for organizations is currently in public beta and subject to changes)* | Required if `RUNNER_REPOSITORY_URL` is not provided |
| GITHUB_ACCESS_TOKEN | Personal Access Token. Used to dynamically fetch a new runner token (recommended, see below). | Required if `RUNNER_TOKEN` is not provided.
| RUNNER_TOKEN | Runner token provided by GitHub in the Actions page. These tokens are valid for a short period. | Required if `GITHUB_ACCESS_TOKEN` is not provided
| RUNNER_WORK_DIRECTORY | Runner's work directory | `"_work"`
| RUNNER_NAME | Name of the runner displayed in the GitHub UI | Hostname of the container
| RUNNER_LABELS | Extra labels in addition to the default: 'self-hosted,Linux,X64' (based on your OS and architecture) | `""`
| RUNNER_REPLACE_EXISTING | `"true"` will replace existing runner with the same name, `"false"` will use a random name if there is conflict | `"true"`

## Runner Token

In order to link your runner to your repository/organization, you need to provide a token. There is two way of passing the token :

* via `GITHUB_ACCESS_TOKEN` (recommended), containing a [Personnal Access Token](https://github.com/settings/tokens). This token will be used to dynamically fetch a new runner token, as runner tokens are valid for a short period of time.
  * For a single-repository runner, your PAT should have `repo` scopes.
  * For an organization runner, your PAT should have `admin:org` scopes.
* via `RUNNER_TOKEN`. This token is displayed in the Actions settings page of your organization/repository, when opening the "Add Runner" page.

## Runner auto-update behavior

The GitHub runner (the binary) will update itself when receiving a job, if a new release is available.
In order to allow the runner to exit and restart by itself, the binary is started by a supervisord process.
