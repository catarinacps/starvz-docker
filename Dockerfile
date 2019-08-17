## -*- docker-image-name: starvz -*-

FROM debian:stretch

RUN apt update \
    && apt install -y \
    build-essential curl git libtool libtool-bin \
    pajeng libboost-dev r-base-core procps python gawk \
    libxml2-dev libssl-dev libcurl4-gnutls-dev libgit2-dev \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN git clone https://github.com/llnl/spack.git --depth=1 \
    && git clone https://gitlab.inria.fr/solverstack/spack-repo.git spack-solverstack \
    && /spack/bin/spack repo add spack-solverstack/ \
    && /spack/bin/spack install starpu@git-1.3+poti+fxt+mpi~examples~openmp \
    && /spack/bin/spack view -d yes hard -i / starpu \
    && rm -rf /spack /spack-solverstack

RUN echo "install.packages(c('tidyverse', 'devtools'), repos = 'https://cran.us.r-project.org')" | R --vanilla \
    && echo "library(devtools); devtools::install_github('schnorr/starvz', subdir='R_package')" | R --vanilla

RUN git clone https://github.com/schnorr/starvz \
    && cp /starvz/src/* /usr/bin/ \
    && mkdir /usr/R \
    && cp /starvz/R/* /usr/R/ \
    && rm -rf /starvz

RUN apt -y remove \
    procps libtool libtool-bin git python gawk curl build-essential \
    && apt -y autoremove \
    && apt clean

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

RUN useradd -s /bin/bash --create-home user
USER user
WORKDIR /home/user

ENTRYPOINT ["/entrypoint.sh"]
