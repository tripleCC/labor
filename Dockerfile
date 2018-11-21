FROM ruby:alpine

LABEL maintainer="Zhuohui <shupian@2dfire.com>"



RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
  && apk update \
  && apk upgrade \
  && apk add --update --no-cache git openssl tzdata postgresql-dev make build-base autoconf automake zlib libstdc++ openssh-client\
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone \
  && bundle config mirror.https://rubygems.org https://gems.ruby-china.com

RUN addgroup -g 10001 -S labor && adduser -u 10001 -S labor -G labor
  

WORKDIR /home/labor/app

COPY ssh /home/labor/.ssh

ADD ./ /home/labor/app

RUN bundle install \
  && chown -R labor:labor /home/labor \
  && chmod 600 /home/labor/.ssh/id_rsa

USER labor

RUN bundle exec pod repo add 2dfire git@git.2dfire-inc.com:ios/cocoapods-spec.git

EXPOSE 1080

ENTRYPOINT ["sh", "./entrypoint.sh"]