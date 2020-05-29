#!/usr/bin/env bash

jsonnet -J vendor -y kube.jsonnet | kubectl create --dry-run=client --validate -f -
