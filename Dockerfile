## -*- docker-image-name: starvz -*-

FROM debian:10

RUN apt update \
    && apt install -y \
    build-essential wget curl tar unzip ca-certificates libxml2-dev libssl-dev \
    pajeng r-base-core git procps python gawk autoconf perl m4 libcurl4-openssl-dev libgit2-dev\
    && apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN git clone https://github.com/llnl/spack.git --depth=1
RUN git clone https://gitlab.inria.fr/solverstack/spack-repo.git spack-solverstack
RUN /spack/bin/spack repo add spack-solverstack/
RUN /spack/bin/spack install starpu@git-1.3+poti+fxt+mpi~examples~openmp
RUN /spack/bin/spack view -d yes hard -i / starpu
RUN rm -rf /spack /spack-solverstack

RUN echo "install.packages(c('tidyverse', 'devtools'), repos = 'http://cran.us.r-project.org')" | R --vanilla
RUN echo "library(devtools); devtools::install_github('schnorr/starvz', subdir='R_package')" | R --vanilla

RUN git clone https://github.com/schnorr/starvz
RUN cp /starvz/src/* /starvz/R/* /usr/bin/
RUN rm -rf /starvz

# RUN apt -y remove wget curl unzip git

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

RUN useradd -s /bin/bash --create-home user
USER user
WORKDIR /home/user

ENTRYPOINT ["/entrypoint.sh"]
