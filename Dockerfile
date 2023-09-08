# syntax=docker/dockerfile:1

FROM python:3

WORKDIR /HW2_part2

COPY map.py reduce.py titles.tar.gz ./

RUN tar -xzf titles.tar.gz
RUN mkdir counts
