FROM ruby:alpine

LABEL maintainer="Zhuohui <shupian@2dfire.com>"

ENV HOME=/app

WORKDIR ${HOME}/labor

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
  && apk update \
  && apk upgrade \
  && apk add --update --no-cache git openssl tzdata postgresql-dev make build-base autoconf automake zlib libstdc++ openssh-client\
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone 

RUN addgroup -g 10001 -S labor && \
    adduser -u 10001 -S -D -G labor labor -h ${HOME}


COPY ssh ${HOME}/.ssh

ADD ./ ${HOME}/labor

RUN chown -R labor:root ${HOME} \
  && chmod -R 0775 ${HOME} \
  && chmod 600 ${HOME}/.ssh/id_rsa

USER 10001

RUN bundle config mirror.https://rubygems.org https://gems.ruby-china.com && \
    bundle install && \
    bundle exec pod repo add 2dfire git@git.2dfire-inc.com:ios/cocoapods-spec.git

EXPOSE 1080

# ENTRYPOINT ["sh", "./entrypoint.sh"]
CMD [ "bundle", "exec", "rake", "deploy" ]