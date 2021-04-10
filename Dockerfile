FROM alpine:3.13 as base

# Add generic wait-for-postgres command
COPY wait-for-postgres.sh /usr/local/bin/wait-for-postgres

# Add default uwsgi configuration
COPY uwsgi.ini /etc/uwsgi_defaults.ini

# Add up to date uwsgidecorators to python
# ADD https://raw.githubusercontent.com/unbit/uwsgi/2.0.18/uwsgidecorators.py /usr/lib/python3.8/uwsgidecorators.py

# Install uwsgi and needed plugins
RUN apk add --no-cache uwsgi=~2.0 uwsgi-python3 uwsgi-spooler uwsgi-cache \
    # Install python3.8 and pip from the alpine repository, since they provide it in alpine 3.13
    # This is good enough for us and enables us to install precompiled packages from apk
    python3=~3.8 py3-pip \
    # Install postgres client for the wait-for-postgres script
    py3-psycopg2 postgresql-client=~13 && \
    # Link some python3 and pip3 to default pythond and pip
    ln -fs /usr/bin/python3.8 /usr/bin/python && ln -fs /usr/bin/pip3 /usr/bin/pip && \
    # Make the copied files execuable and readable for all
    chmod 755 /usr/local/bin/wait-for-postgres && \
    # chmod 655 /usr/lib/python3.8/uwsgidecorators.py && \
    # Add a user and a group to use for execution so we follow best practices
    addgroup -S devops && adduser -S devops -G devops

# Tell uwsgi to load defaults
ENV UWSGI_INI=/etc/uwsgi_defaults.ini

WORKDIR /home/devops
CMD ["uwsgi"]

# Here the real magic happens
# This is run if somebody FROMs this image.
# Set a GIT_BUILD_VERSION so we can identify this image from within the container by setting a ENV Var
ONBUILD ARG GIT_BUILD_VERSION=unknown
ONBUILD ENV GIT_BUILD_VERSION=$GIT_BUILD_VERSION
# Copy everything in the Dockerfile folder into this image
# Use the .dockerignore to exclude files from being copied
ONBUILD COPY .build /home/devops/.build
ONBUILD COPY setup.py /home/devops
# Install additional packages we need, like image libaries
ONBUILD RUN apk add --no-cache $(cat .build/runtime-packages.txt | sed -e ':a;N;$!ba;s/\n/ /g') && \
            # Install packages we need to install a python packages that needs to be compiled. These will be deleted afterwards.
            apk add --no-cache --virtual build-deps gcc python3-dev musl-dev $(cat .build/build-packages.txt | sed -e ':a;N;$!ba;s/\n/ /g') && \
            # Install the current folder as editable so we have it on the pythonpath but don't need to actually package it
            pip install --no-cache-dir --upgrade pip && pip install --no-cache-dir -e . && \
            # Remove build packages and chown everything in here for our user
            apk del build-deps && chown -R devops:devops .
# Run everything afterwards as the devops user
ONBUILD COPY . /home/devops
ONBUILD USER devops
