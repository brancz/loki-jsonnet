#!/usr/bin/env bash

jsonnet -J vendor -y main.jsonnet | kubectl create --dry-run --validate -f -
