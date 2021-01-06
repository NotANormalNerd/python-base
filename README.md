# Docker Base Image for mecodia GmbH Django Projects

This image was specifically crafted to be as small as possible while also giving a good basic packaging.
We are trying to follow the best practices of Docker and Kubernetes with this image to improve speed and security.

## Features

This image is based on alpine:3.12 and provides the following features:

- Python 3.8
- uwsgi with python3, spooler and cache plugin loaded and sane default settings
- pyscop2 and pyscop2-binary
- wait-for-postgres command (wait for the DB defined in \$POSTGRES_HOST)
- Possibility to add additional packages and build-only packages

## How to use

This images is intended to be used with a standard python3.8 and django2.2 project.

The project structure should look roughly like this:

    .
    ├── .dockerignore
    ├── .git/
    ├── .gitignore
    ├── Makefile
    ├── README.md
    ├── docker-compose.yml
    └── project
        ├── .build
        │   └── runtime-packackes.txt
        │   └── build-packages.txt
        ├── myproject
        │   ├── __init__.py
        │   ├── apps
        │   ├── settings
        │   ├── static
        │   ├── templates
        │   ├── urls.py
        │   └── wsgi.py
        ├── Dockerfile
        ├── init.sh
        ├── test.sh
        └── setup.py

The corresponding dockerfile in the subproject using this base image can be as close to zero as:

    FROM mecodia/python-base:latest

    ENV POSTGRES_HOST db.example.com
    RUN mkdir -p var/static

The image should be ran with the following command as the bare minimum:

    uwsgi --http-socket 0.0.0.0:8000 --module myproject.wsgi:application --show-config

or if we use a prerun script:

    sh ./init.sh uwsgi --http-socket 0.0.0.0:8000 --module myproject.wsgi:application --show-config

## Release Process

- For a new release and autobuild tag a commit with e.g. `v1.2`
- For building public test images, `v1.2-rc1` is also possible.
