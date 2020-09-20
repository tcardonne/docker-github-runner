ARG FROM=debian:buster-slim
FROM ${FROM}

ARG DEBIAN_FRONTEND=noninteractive
ARG GIT_VERSION="2.26.2"
ARG GH_RUNNER_VERSION
ARG DOCKER_COMPOSE_VERSION="1.27.4"

ENV RUNNER_NAME=""
ENV RUNNER_WORK_DIRECTORY="_work"
ENV RUNNER_TOKEN=""
ENV RUNNER_REPOSITORY_URL=""
ENV RUNNER_LABELS=""
ENV RUNNER_ALLOW_RUNASROOT=true
ENV GITHUB_ACCESS_TOKEN=""
ENV AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache

# Labels.
LABEL maintainer="me@tcardonne.fr" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.name="tcardonne/github-runner" \
    org.label-schema.description="Dockerized GitHub Actions runner." \
    org.label-schema.url="https://github.com/tcardonne/docker-github-runner" \
    org.label-schema.vcs-url="https://github.com/tcardonne/docker-github-runner" \
    org.label-schema.vendor="Thomas Cardonne" \
    org.label-schema.docker.cmd="docker run -it tcardonne/github-runner:latest"

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y \
        curl \
        unzip \
        apt-transport-https \
        ca-certificates \
        software-properties-common \
        sudo \
        supervisor \
        jq \
        iputils-ping \
        build-essential \
        zlib1g-dev \
        gettext \
        liblttng-ust0 \
        libcurl4-openssl-dev && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod 644 /etc/supervisor/conf.d/supervisord.conf

# Install Docker CLI
RUN curl -fsSL https://get.docker.com -o- | sh && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Install Docker-Compose
RUN curl -L -o /usr/local/bin/docker-compose \
    "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" && \
    chmod +x /usr/local/bin/docker-compose

RUN cd /tmp && \
    curl -sL -o git.tgz \
    https://www.kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.gz && \
    tar zxf git.tgz  && \
    cd git-${GIT_VERSION}  && \
    ./configure --prefix=/usr  && \
    make && \
    make install && \
    rm -rf /tmp/*

RUN mkdir -p /home/runner ${AGENT_TOOLSDIRECTORY}

WORKDIR /home/runner

RUN GH_RUNNER_VERSION=${GH_RUNNER_VERSION:-$(curl --silent "https://api.github.com/repos/actions/runner/releases/latest" | grep tag_name | sed -E 's/.*"v([^"]+)".*/\1/')} \
    && curl -L -O https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
    && tar -zxf actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
    && rm -f actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
    && ./bin/installdependencies.sh \
    && chown -R root: /home/runner \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
