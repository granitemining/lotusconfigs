FROM ubuntu:20.04

RUN apt-get update -y
RUN apt-get install dialog -y

ENV TERM=xterm-256color

SHELL ["/usr/bin/bash", "-c"]

COPY bin/lotus-worker-manager /usr/local/bin/lotus-worker-manager

CMD ["lotus-worker-manager"]