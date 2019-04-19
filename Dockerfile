FROM ruby:2.6.3
COPY . /opt/archelon
WORKDIR /opt/archelon
RUN bundle install --deployment && bundle exec rake db:migrate
EXPOSE 3000
CMD ["bin/rails", "server", "--binding", "0.0.0.0"]
