#!/usr/bin/env bash

jsonnet -J vendor -J ../../ -y kube.jsonnet | kubectl create --dry-run=client --validate -f -
