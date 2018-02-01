FROM python:3.6-stretch

RUN echo "deb http://ftp.debian.org/debian stretch main contrib" > /etc/apt/sources.list

# todo: Revert this entire pull request when libcairo2 >= 1.14.2 is available from the debian
#       jessie repo.  This is a temporary fix for https://github.com/Kozea/WeasyPrint/issues/233

# reconfigure Debian to allow installs from both stretch (testing) repo and jessie (stable) repo
# install all the dependencies except libcairo2 from jessie, then install libcairo2 from stretch
RUN apt-get -y update \
    && apt-get install -y \
        fonts-font-awesome \
        libffi-dev \
        libgdk-pixbuf2.0-0 \
        python-dev \
        python-lxml \
        shared-mime-info \
    && apt-get install -y ttf-mscorefonts-installer \
    && apt-get install -y libpango1.0-0 \
    && apt-get install -y libcairo2=1.14.8-1 \
    && apt-get -y clean

ADD requirements.txt /requirements.txt

RUN pip install -r /requirements.txt

EXPOSE 5001

ENV NUM_WORKERS=3
ENV TIMEOUT=120

CMD gunicorn --bind 0.0.0.0:5001 --timeout $TIMEOUT --workers $NUM_WORKERS  wsgi:app
