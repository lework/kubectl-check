FROM lework/kubectl:latest
LABEL maintainer "Lework <lework@yeah.net>"

ENV TIMEZONE=Asia/Shanghai

COPY kubectl-check /usr/local/bin/kubectl-check
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN apk --no-cache add tzdata bash jq \
    && ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" > /etc/timezone \
    && chmod +x /usr/local/bin/*

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["kubectl", "help"]
