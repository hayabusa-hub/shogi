#RUBY
FROM ruby:2.6.6 as builder
RUN apt-get update                          && \
    apt-get install -y build-essential      && \
    apt-get install -y libpq-dev            && \
    apt-get install -y default-mysql-client &&\
    apt-get install -y vim                  && \
    mkdir /myapp

# install nodejs(LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt-get install -y nodejs
# install yarn
RUN npm install --global yarn

# コピー
WORKDIR /myapp
COPY . /myapp

# packageのインストール
RUN bundle install

# DOCKERにて、rails server実行時に、yarn package が古いというエラーが発生するため、その対策
RUN yarn install --check-files

# データベースの初期化
RUN rails db:migrate && rails db:seed

# DOCKERにて、rails server実行時に、下記エラーが発生する
#　「webpacker can't find application in manifest.json」
# その際に、opensslerrorstackエラーが発生するため、事前に処理を実施
ENV NODE_OPTIONS --openssl-legacy-provider
RUN rails webpacker:compile