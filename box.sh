#!/bin/bash

function start() {
	echo "📦 starting box at $(pwd)..."
	docker run --rm -it -P -v $(pwd):/app -w /app -e COLUMNS=$COLUMNS -e LINES=$LINES box tmux -u
}

