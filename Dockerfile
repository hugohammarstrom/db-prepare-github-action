FROM node:12.10.0-alpine

RUN npm i -g @hugohammarstrom/db-prepare

RUN apk update \
  && apk upgrade \
  && apk --no-cache add --update software-properties-common
RUN add-apt-repository ppa:rmescandon/yq
RUN apk update
RUN apk add yq

COPY LICENSE README.md /

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]