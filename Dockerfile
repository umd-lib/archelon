FROM ruby:2.6.3
WORKDIR /opt/archelon
COPY ./Gemfile* /opt/archelon/
RUN bundle install --deployment
COPY . /opt/archelon
RUN bundle exec rake db:migrate
EXPOSE 3000
CMD ["bin/rails", "server", "--binding", "0.0.0.0"]
