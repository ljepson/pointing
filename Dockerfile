FROM perl:5.26.1

COPY cpanfile /tmp/cpanfile

RUN cpan App::cpanminus && \
    cpanm `perl -ne '/^requires q\{([^}]+)};/ && print "$1 "' /tmp/cpanfile` && rm -f /tmp/cpanfile

ADD conf /code/conf
ADD lib /code/lib
ADD script /code/script

WORKDIR /code

CMD morbo -w lib -w conf script/server
