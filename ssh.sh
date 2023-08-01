#!/bin/bash

set -e

if [ -z "$1" ]
then
	echo "No password provided"
	exit 1
fi

echo "root:$1" | chpasswd

FILE="/etc/ssh/sshd_config"
grep -qxF '    PasswordAuthentication yes' "$FILE" || echo '    PasswordAuthentication yes' | tee -a "$FILE" > /dev/null
grep -qxF '    PermitRootLogin yes' "$FILE" || echo '    PermitRootLogin yes' | tee -a "$FILE" > /dev/null

/usr/sbin/sshd -D
