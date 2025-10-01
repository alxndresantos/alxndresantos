#!/bin/bash
# Load fluig variables
. ./fluig.conf

# Rotate server.log - required to check when fluig is up and running
mv $JBOSS_SERVER/log/server.log $JBOSS_SERVER/log/server.log.$(date +%Y-%m-%d-%H-%M-%S)
