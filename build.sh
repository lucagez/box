#!/bin/bash

set -e

echo "📦 building box..."

docker build -t box .

