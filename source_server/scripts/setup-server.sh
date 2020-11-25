#!/bin/bash

cd /home/ubuntu

sudo apt update

# Clone the repo with django setup
git clone https://github.com/andrekwr/tasks.git

# Change configuration TODO: deixar mais dinamico ((placeholder))
cd tasks/portfolio/

DBCONIG="DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': '${dbName}',
            'USER': '${dbUser}',
            'PASSWORD': '${dbPass}',
            'HOST': '${dbHost}',
            'PORT': '${dbPort}',

        }
    }"
    echo $DBCONIG >> settings.py

#Install config from django
cd ..

chmod a+x install.sh

./install.sh