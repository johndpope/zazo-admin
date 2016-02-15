FROM zazo/rails

COPY . /usr/src/app
COPY config/Gemfile /usr/src/app/
RUN bundle install --jobs 8
RUN rake assets:precompile
RUN chown www-data:www-data -R /usr/src/app

EXPOSE 80
CMD bin/start.sh
