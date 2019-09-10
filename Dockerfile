FROM node:12.10.0-alpine

RUN npm i -g @hugohammarstrom/db-prepare

RUN wget -O /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/2.4.0/yq_linux_amd64"
RUN chmod +x /usr/local/bin/yq

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh


ENTRYPOINT ["/entrypoint.sh"]