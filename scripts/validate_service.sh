#!/bin/bash
# This script tests if the website is running and accessible.

# Use curl to request the home page from the local web server.
# The '-f' or '--fail' flag causes curl to exit with an error code (22)
# if the HTTP server returns an error (4xx or 5xx).
curl -f http://localhost/