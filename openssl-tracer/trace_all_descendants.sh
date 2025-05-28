#!/bin/bash
# Usage: ./trace_all_descendants.sh <PARENT_PID>
# Spawns openssl_tracer for all descendants of the given parent PID, logging output to files named by PID and command.

if [ -z "$1" ]; then
  echo "Usage: $0 <PARENT_PID>"
  exit 1
fi

PARENT_PID=$1
TRACER_PATH="$(dirname "$0")/openssl_tracer"

get_descendants() {
  local pid=$1
  for child in $(pgrep -P $pid); do
    echo $child
    get_descendants $child
  done
}

ALL_PIDS=$(get_descendants $PARENT_PID)

for pid in $ALL_PIDS; do
  cmd=$(ps -p $pid -o cmd= | tr -d ' ')
  if [ -z "$cmd" ]; then
    cmd="unknown"
  fi
  logfile="trace_${pid}_${cmd//\//_}.log"
  echo "Tracing PID $pid ($cmd), logging to $logfile"
  sudo "$TRACER_PATH" $pid > "$logfile" 2>&1 &
done

echo "Started tracing for all descendants of PID $PARENT_PID."
