#!/usr/bin/env bash

jsonnet -J vendor -J ../../ -y main.jsonnet | kubectl create --dry-run --validate -f -
