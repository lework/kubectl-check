FROM lework/kubectl:latest
LABEL maintainer "Lework <lework@yeah.net>"

ENV TIMEZONE=Asia/Shanghai

COPY kubectl-check entrypoint.sh /usr/local/bin/

RUN apk --no-cache add tzdata bash jq ncurses \
    && ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" > /etc/timezone \
    && chmod +x /usr/local/bin/*

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
