#/usr/bin/env bash

jsonnet -y test.jsonnet | kubectl create --dry-run --validate -f -
