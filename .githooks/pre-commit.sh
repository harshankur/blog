#!/bin/sh

# Generate static files
hugo

# Add all generated files to the commit
git update-index --add *
