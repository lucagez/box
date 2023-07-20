#!/bin/bash

function start() {
	echo "📦 starting devbox at $(pwd)..."
	docker run --rm -it -P -v $(pwd):/app -w /app -e COLUMNS=$COLUMNS -e LINES=$LINES devbox tmux -u
}
