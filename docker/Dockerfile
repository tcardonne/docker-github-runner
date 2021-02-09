ARG FROM=phpdockerio/php74-cli:latest
FROM ${FROM}

ARG DEBIAN_FRONTEND=noninteractive
# ARG GIT_VERSION="2.30.1"
ARG GH_RUNNER_VERSION="2.276.1"

ENV RUNNER_NAME=""
ENV RUNNER_WORK_DIRECTORY="_work"
ENV RUNNER_TOKEN=""
ENV RUNNER_REPOSITORY_URL=""
ENV RUNNER_LABELS=""
ENV RUNNER_ALLOW_RUNASROOT=true
ENV GITHUB_ACCESS_TOKEN=""
ENV AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache

# Labels.
LABEL maintainer="Dario Palladino <dario.pad@gmail.com" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.name="dariopad/github-agent-php" \
    org.label-schema.description="Dockerized GitHub Actions runner with Composer and PHP7. Forked from https://github.com/tcardonne/docker-github-runner" \
    org.label-schema.url="https://github.com/dariopalladino/docker-github-runner" \
    org.label-schema.vcs-url="https://github.com/dariopalladino/docker-github-runner" \
    org.label-schema.vendor="Dario Palladino" \
    org.label-schema.docker.cmd="docker run -it dariopad/github-agent-php:latest"

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# RUN cd /tmp && \
#     curl -sL -o git.tgz \
#     https://www.kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.gz && \
#     tar zxf git.tgz  && \
#     cd git-${GIT_VERSION}  && \
#     ./configure --prefix=/usr  && \
#     make && \
#     make install && \
#     rm -rf /tmp/*

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

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod 644 /etc/supervisor/conf.d/supervisord.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
