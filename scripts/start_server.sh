#!/bin/bash
# Start the Apache server if it's not already running.
# The service is called 'apache2' on Ubuntu.
systemctl is-active --quiet apache2
if [ $? -ne 0 ]; then
    systemctl start apache2
fi