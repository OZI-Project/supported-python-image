FROM debian:bullseye-slim AS builder
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    make \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncurses5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    git \
    ca-certificates \
    libffi-dev \
  && apt-get clean autoclean \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* \
  && rm -f /var/cache/apt/archives/*.deb

FROM builder as pyenv-builder
RUN git clone https://github.com/pyenv/pyenv /root/.pyenv
RUN for PYTHON_VERSION in 3.10.13 3.11.8 3.12.2; do \
  set -ex \
    && /root/.pyenv/bin/pyenv install ${PYTHON_VERSION} \
    && /root/.pyenv/versions/${PYTHON_VERSION}/bin/python -m pip install --upgrade pip setuptools \
  ; done
RUN apt-get remove -y make git wget llvm gcc-10 build-essential curl libnss3 libexpat1 \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* \
  && rm -f /var/cache/apt/archives/*.deb

FROM scratch
COPY --from=pyenv-builder / /
ENV PATH /root/.pyenv/versions/3.10.13/bin:${PATH}
ENV PATH /root/.pyenv/versions/3.11.8/bin:${PATH}
ENV PATH /root/.pyenv/versions/3.12.2/bin:${PATH}
ARG username=user
USER ${username}
WORKDIR /opt
CMD ["bash"]
