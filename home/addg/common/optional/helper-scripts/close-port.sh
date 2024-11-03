#!/bin/bash

# Check if a port number is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 [port number]"
    exit 1
fi

PORT=$1

# Find processes using the port
PIDS=$(lsof -ti tcp:$PORT)

# Check if any process was found
if [ -z "$PIDS" ]; then
    echo "No process found running on port $PORT."
    exit 0
fi

# Display the processes
echo "Processes running on port $PORT:"
lsof -i tcp:$PORT

# Ask for confirmation
read -p "Are you sure you want to kill these processes? (y/n) " -n 1 -r
echo    # Move to a new line

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Kill the processes
    echo "Killing processes on port $PORT..."
    kill -9 $PIDS
    echo "Done."
else
    echo "Operation cancelled."
fi
