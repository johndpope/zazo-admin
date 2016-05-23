FROM zazo/rails

RUN rake assets:precompile RAILS_ENV=production

EXPOSE 80
CMD bin/start.sh
