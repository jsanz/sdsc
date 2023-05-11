FROM python:slim

COPY requirements.txt /tmp/requirements.txt

RUN pip install -r /tmp/requirements.txt

RUN useradd -m -d /sdsc -s /bin/bash sdsc
USER sdsc

COPY . /sdsc

WORKDIR /sdsc

CMD jupyter notebook --ip 0.0.0.0 --no-browser --NotebookApp.token='sdsc' --NotebookApp.password=''
