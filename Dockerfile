FROM python:slim

RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive \
      apt-get -y -qq install \
        g++ \
        libgdal-dev && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/requirements.txt

RUN pip install -r /tmp/requirements.txt

RUN useradd -m -d /sdsc -s /bin/bash sdsc
USER sdsc

COPY img data /sdsc/
COPY 2023-foundations-of-geospatial.ipynb /sdsc

WORKDIR /sdsc

CMD jupyter notebook --ip 0.0.0.0 --no-browser --NotebookApp.token='sdsc' --NotebookApp.password=''
