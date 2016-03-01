FROM frolvlad/alpine-python3
MAINTAINER Hypothes.is Project and contributors

# Install system build and runtime dependencies.
RUN apk add --update \
    nodejs \
  && rm -rf /var/cache/apk/*

# Create the bouncer user, group, home directory and package directory.
RUN addgroup -S bouncer \
  && adduser -S -G bouncer -h /var/lib/bouncer bouncer
WORKDIR /var/lib/bouncer

# Copy packaging
COPY README.rst package.json setup.* ./

RUN npm install --production \
  && npm cache clean

COPY gunicorn.conf.py ./

# Copy the rest of the application files
COPY bouncer ./bouncer/

RUN pip install --no-cache-dir -e .

# Persist the static directory.
VOLUME ["/var/lib/bouncer/bouncer/static"]

# Start the web server by default
USER bouncer
CMD ["gunicorn", "bouncer:app()"]
