# Dockerfile may have following Arguments:
# tag - tag for the Base image, (e.g. 2.9.1 for tensorflow)
# branch - user repository branch to clone (default: master, another option: test)
# jlab - if to insall JupyterLab (true) or not (false)
#
# To build the image:
# $ docker build -t <dockerhub_user>/<dockerhub_repo> --build-arg arg=value .
# or using default args:
# $ docker build -t <dockerhub_user>/<dockerhub_repo> .
#
# [!] Note: For the Jenkins CI/CD pipeline, input args are defined inside the
# Jenkinsfile, not here!

ARG tag=2.9.1

# Base image, e.g. tensorflow/tensorflow:2.9.1
FROM tensorflow/tensorflow:${tag}

LABEL maintainer='Ignacio Heredia'
LABEL version='0.0.1'
# A toy application for demo and testint purposes. We just implement dummy inference, ie. we return the same inputs we are

# What user branch to clone [!]
ARG branch=master

# If to install JupyterLab
ARG jlab=true

# Install Ubuntu packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        wget \
        nano

# Link python3-->python, pip3-->pip (if needed) and update pip
#  [!] Remember: DEEP API V2 only works with python>=3.6
RUN if [ ! -e /usr/bin/pip ]; then \
       ln -s /usr/bin/pip3 /usr/bin/pip; \
    fi; \
    if [ ! -e /usr/bin/python ]; then \
       ln -s /usr/bin/python3 /usr/bin/python; \
    fi && \
    python --version && \
    pip --version && \
    pip install --upgrade pip "setuptools<60.0.0" wheel

# TODO: remove setuptools version requirement when [1] is fixed
# [1]: https://github.com/pypa/setuptools/issues/3301

# Set LANG environment
ENV LANG C.UTF-8

# Set the working directory
WORKDIR /srv

# Install rclone (needed if syncing with NextCloud for training; otherwise remove)
RUN wget https://downloads.rclone.org/rclone-current-linux-amd64.deb && \
    dpkg -i rclone-current-linux-amd64.deb && \
    apt install -f && \
    mkdir /srv/.rclone/ && touch /srv/.rclone/rclone.conf && \
    rm rclone-current-linux-amd64.deb

ENV RCLONE_CONFIG=/srv/.rclone/rclone.conf

# Install DEEPaaS from PyPi
#RUN pip install deepaas

# Install DEEPaaS from source until 2.1 release is made to PyPi
RUN pip install --upgrade git+https://github.com/indigo-dc/deepaas.git@master

# Initialization scripts
RUN git clone https://github.com/deephdc/deep-start /srv/.deep-start && \
    ln -s /srv/.deep-start/deep-start.sh /usr/local/bin/deep-start && \
    ln -s /srv/.deep-start/run_jupyter.sh /usr/local/bin/run_jupyter

# Install JupyterLab
ENV JUPYTER_CONFIG_DIR /srv/.deep-start/
ENV SHELL /bin/bash
RUN if [ "$jlab" = true ]; then \
       # by default has to work (1.2.0 wrongly required nodejs and npm)
       pip install jupyterlab ; \
    else echo "[INFO] Skip JupyterLab installation!"; fi

# Install user app
RUN git clone -b $branch https://github.com/deephdc/demo_app && \
    cd  demo_app && \
    pip install -e . && \
    cd ..

# Cleaning up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/*

# Open ports: DEEPaaS (5000), Monitoring (6006), Jupyter (8888)
EXPOSE 5000 6006 8888

# Run DEEPaaS as a default
CMD ["deepaas-run", "--listen-ip", "0.0.0.0", "--listen-port", "5000"]
