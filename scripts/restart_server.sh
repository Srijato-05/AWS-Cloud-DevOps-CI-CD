#!/bin/bash

# This simple script checks if the Apache server (httpd) is active.
# If it's not (like on the very first deploy), it starts it.

systemctl is-active --quiet httpd
if [ $? -ne 0 ]; then
    systemctl start httpd
fi