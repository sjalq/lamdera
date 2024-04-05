#!/bin/bash

# Function to clean up before exiting
cleanup() {
  echo "Terminating both processes..."
  tmux send-keys -t mySession:0.0 C-c
  tmux send-keys -t mySession:0.1 C-c
  sleep 1 # Give some time for processes to terminate
  tmux kill-session -t mySession
  exit 0
}

# Set up SIGINT trap
trap 'cleanup' SIGINT

# Start a new tmux session in detached mode and name it 'mySession'
tmux new-session -d -s mySession "elm-land server; read"

# Split the window horizontally and start the second command
tmux split-window -h "lamdera live; read"

# To ensure the window stays open after the commands terminate
tmux bind-key -n C-c run-shell 'tmux send-keys C-c \; detach-client'

# Attach to the session
tmux attach-session -t mySession

# Wait here for the signal
wait
