FROM python:3.6.6

RUN python -m pip install pip --upgrade

COPY setup.py /job/
COPY requirements.txt /job/
COPY src/ /job/src/
COPY test/ /job/test/

# temporaly
COPY resources/train.csv /job/resources/
COPY resources/test.csv /job/resources/

WORKDIR job/

RUN find . | grep -E "(__pycache__|\.pyc$)" | xargs rm -rf
RUN pip install -U -r requirements.txt
RUN pip install .
