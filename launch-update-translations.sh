#!/usr/bin/env bash

"$(dirname "$0")/update-translations.sh" "$@" \
	> /tmp/update-translations.log \
	2>&1
