## -*- docker-image-name: starvz -*-

FROM debian:10

RUN apt update \
    && apt install -y \
    build-essential wget curl tar unzip ca-certificates libtool-bin \
    pajeng libboost-all-dev r-base-core git procps python gawk \
    libxml2-dev libssl-dev libcurl4-openssl-dev libgit2-dev \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN git clone https://github.com/llnl/spack.git --depth=1 \
    && git clone https://gitlab.inria.fr/solverstack/spack-repo.git spack-solverstack \
    && /spack/bin/spack repo add spack-solverstack/ \
    && /spack/bin/spack install starpu@git-1.3+poti+fxt+mpi~examples~openmp \
    && /spack/bin/spack view -d yes hard -i / starpu \
    && rm -rf /spack /spack-solverstack

RUN echo "install.packages(c('tidyverse', 'devtools'), repos = 'http://cran.us.r-project.org')" | R --vanilla \
    && echo "library(devtools); devtools::install_github('schnorr/starvz', subdir='R_package')" | R --vanilla

RUN git clone https://github.com/schnorr/starvz \
    && cp /starvz/src/* /starvz/R/* /usr/bin/ \
    && rm -rf /starvz

RUN apt -y remove \
    procps libboost-all-dev libtool-bin \
    && apt -y autoremove \
    && apt clean

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

RUN useradd -s /bin/bash --create-home user
USER user
WORKDIR /home/user

ENTRYPOINT ["/entrypoint.sh"]
