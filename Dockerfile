FROM ruby:alpine

LABEL maintainer="Zhuohui <shupian@2dfire.com>"

ENV HOME=/home/labor

WORKDIR ${HOME}/labor

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
  && apk update \
  && apk upgrade \
  && apk add --update --no-cache git openssl tzdata postgresql-dev make build-base autoconf automake zlib libstdc++ openssh-client\
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone \
  && chmod g+w /etc/passwd

RUN adduser -u 10001 -S -D -G root labor -h ${HOME}


COPY ssh ${HOME}/.ssh

ADD ./ ${HOME}/labor

RUN chown -R labor:root ${HOME} \
  && chmod -R 0775 ${HOME} \
  && chmod 600 ${HOME}/.ssh/id_rsa

USER 10001

RUN bundle config mirror.https://rubygems.org https://gems.ruby-china.com && \
    bundle install

EXPOSE 1080

ENTRYPOINT ["sh", "uid-entrypoint"]
# CMD [ "bundle", "exec", "rake", "deploy" ]