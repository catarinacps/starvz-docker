#!/bin/bash

docker run -dit \
       --name=trace_analysis \
       --mount type=bind,source=`pwd`/data,target=/scratch \
       starvz
