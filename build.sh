#!/bin/bash

# Define the Dockerfile contents
DOCKERFILE=$(cat <<EOF
# syntax=docker/dockerfile:1

FROM python:3

WORKDIR /HW2_part2

COPY map.py reduce.py titles.tar.gz ./

RUN tar -xzf titles.tar.gz
RUN mkdir counts

EOF
)

# Write the Dockerfile to the current directory
echo "$DOCKERFILE" > Dockerfile

echo "Dockerfile created. Now building the image..."

# Build the image
docker build -t map-reduce .

