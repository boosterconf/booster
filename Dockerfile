FROM ruby:2.4.0
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /booster
WORKDIR /booster
COPY Gemfile /booster/Gemfile
COPY Gemfile.lock /booster/Gemfile.lock
RUN bundle install
EXPOSE 3000
ENV DATABASE_URL=postgres://boosterconf:boosterconf@host.docker.internal:5432/boosterconf
ENTRYPOINT ["bundle", "exec"]
CMD ["rails", "server", "-b", "0.0.0.0"]
COPY . /booster

