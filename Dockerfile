FROM ruby:2.6.3
WORKDIR /opt/archelon
COPY ./Gemfile ./Gemfile.lock /opt/archelon/
RUN bundle install --deployment
COPY . /opt/archelon
EXPOSE 3000
CMD ["bin/archelon.sh"]
