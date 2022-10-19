FROM ubuntu

RUN apt-get update -y
RUN apt-get install -y git gource ffmpeg xvfb
RUN apt-get install -y q-text-as-data

WORKDIR /src
ADD scripts/* /src/

ENTRYPOINT ["/bin/bash", "./create-all-videos.sh"]

