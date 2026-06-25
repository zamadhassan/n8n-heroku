FROM n8nio/n8n:latest

USER root

WORKDIR /home/node
ENTRYPOINT []

COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]
