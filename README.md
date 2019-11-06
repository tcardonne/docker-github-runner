# GitHub Runner

GitHub allows developpers to run GitHub Actions workflows on your own runners.
This Docker image allows you to create your own runner on Docker.

Note : As stated in the [documentation](https://help.github.com/en/github/automating-your-workflow-with-github-actions/about-self-hosted-runners) :
> "GitHub Actions is currently in limited public beta and is subject to change. We strongly recommend that you do not use this feature for high-value workflows and content during the beta period".

## Usage

Use the following command to start listening for jobs:
```shell
docker run -it --name my-runner \
    -e RUNNER_NAME=my-runner \
    -e RUNNER_TOKEN=token \
    -e RUNNER_REPOSITORY_URL=https://github.com/... \
    tcardonne/github-runner
```

## Environment variables

The following environment variables allows you to control the configuration parameters.

| Name | Description | Default value |
|------|---------------|-------------|
| RUNNER_REPOSITORY_URL | The runner will be linked to this repository URL | Required |
| RUNNER_TOKEN | Personal Access Token provided by GitHub | Required
| RUNNER_WORK_DIRECTORY | Runner's work directory | `"_work"`
| RUNNER_NAME | Name of the runner displayed in the GitHub UI | Hostname of the container

## Using docker-compose.yml

```yaml
version: "3.6"

services:
    runner:
      image: tcardonne/github-runner:latest
      environment:
        RUNNER_NAME: "my-runner"
        RUNNER_REPOSITORY_URL: ${RUNNER_REPOSITORY_URL}
        RUNNER_TOKEN: ${RUNNER_TOKEN}
```