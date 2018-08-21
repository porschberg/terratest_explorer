#!/bin/sh
docker stop -t 1 adoc-processor

set -e

# wechslen in das Script-Verzeichnis
cd $(dirname "$0")

docker run -d --rm -v ${PWD}/slides:/slides --name adoc-processor bledig2/adoc-revealjs-processor
sleep 3
cd slides/html5
google-chrome *.html &
