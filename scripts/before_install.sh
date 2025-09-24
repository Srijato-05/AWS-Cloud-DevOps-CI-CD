#!/bin/bash
# This script runs before the Install hook.
# It cleans out the contents of the web directory to ensure a clean deployment.
# It will not fail if the directory is already empty.
rm -rf /var/www/html/*