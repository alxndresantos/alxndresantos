#!/bin/bash
# Load fluig variables
/volume/CloudFluig/fluig.conf

# Clear temporary folders. 
if [ -d  $JBOSS_SERVER/data/ ]; then   # Check if folder exists
    echo "Removing $JBOSS_SERVER/data/"
    rm -rf $JBOSS_SERVER/data/
    echo "Done"
else
    echo "data folder not found. Nothing happened."
fi

if [ -d  $JBOSS_SERVER/tmp/ ]; then   # Check if folder exists
    echo "Removing $JBOSS_SERVER/tmp/"
    rm -rf $JBOSS_SERVER/tmp/
    echo "Done"
else
    echo "tmp Folder not found. Nothing happened."
fi
