#!/bin/bash

echo "Starting the container..."

echo "Consider using Docker's bind mount system to operate on large amounts of data"
echo "Doing so you will prevent long write times and be overall more performant"
echo

echo "Example of usage:"
echo "    docker run -dit \\"
echo "        --name=<container_name> \\"
echo "        --mount type=bind,source=<host_directory>,target=<container_internal_path> \\"
echo "        starvz \\"

exec "$@"
