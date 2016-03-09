#!/bin/bash

openssl req -x509 -nodes -days 360 -newkey rsa:2048 \
   -subj /CN=localhost \
   -keyout nginx.key -out nginx.crt