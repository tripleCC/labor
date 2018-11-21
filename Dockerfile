FROM ruby:alpine

LABEL maintainer="Zhuohui <shupian@2dfire.com>" \
      run='bundle exec rake deploy'


RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
  && apk update \
  && apk upgrade \
  && apk add --update --no-cache git openssl tzdata postgresql-dev make build-base autoconf automake zlib libstdc++ openssh-client\
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone


ENV APP_ROOT=/opt/app-root
ENV PATH=${APP_ROOT}/bin:${PATH} HOME=${APP_ROOT}

COPY ssh ${HOME}/.ssh

ADD ./ ${APP_ROOT}

RUN chgrp -R 0 ${APP_ROOT} \
  && chmod 600 ${HOME}/.ssh/id_rsa \
  && chmod -R g=u ${APP_ROOT} /etc/passwd

USER 1001

WORKDIR ${APP_ROOT}

RUN bundle config mirror.https://rubygems.org https://gems.ruby-china.com \
  && bundle install \
  && bundle exec pod repo add 2dfire git@git.2dfire-inc.com:ios/cocoapods-spec.git

EXPOSE 1080

ENTRYPOINT ["ud-entrypoint"]

CMD run