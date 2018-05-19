FROM ruby:2.4.0
ENV APPDIR=/booster
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs && \ 
groupadd -g 999 boosterconf && useradd -r -u 999 -g boosterconf boosterconf && \
mkdir /booster && mkdir /temp && mkdir /home/boosterconf && chown boosterconf:boosterconf /home/boosterconf
WORKDIR $APPDIR
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install
EXPOSE 3000
ENV DATABASE_URL=postgres://boosterconf:boosterconf@host.docker.internal:5432/boosterconf
ENTRYPOINT ["bundle", "exec"]
CMD ["rails", "server", "-b", "0.0.0.0"]
COPY . .
RUN chown -R boosterconf:boosterconf $APPDIR
USER boosterconf
