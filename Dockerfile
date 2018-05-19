FROM alpine:latest
RUN apk add --update curl jq
RUN rm -rf /var/cache/apk/*
ADD script.sh /
RUN chmod +x /script.sh
RUN apk -Uuv add curl ca-certificates
CMD /script.sh
