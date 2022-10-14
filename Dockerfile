FROM ubuntu

RUN apt-get update -y
RUN apt-get install -y git gource ffmpeg xvfb

WORKDIR /src
ADD scripts/* /src/

ENTRYPOINT ["/bin/bash", "./create-all-videos.sh"]

