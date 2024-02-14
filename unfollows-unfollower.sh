#!/bin/sh
cat twitter-api-client-boilerplate.py
cut -d':' -f1 | while read line; do
	echo "account.unfollow($line)"
done
