#!/usr/bin/env bash

find . -path '*/.git*' -prune -o -print |
	sed -e 's;[^/]*/;|___;g;s;___|; |;g'
