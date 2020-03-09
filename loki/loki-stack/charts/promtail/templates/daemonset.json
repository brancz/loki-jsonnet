{
  "apiVersion": "apps/v1",
  "kind": "DaemonSet",
  "metadata": {
    "annotations": {},
    "labels": {
      "app": "promtail",
      "chart": "promtail-0.19.2",
      "heritage": "Helm",
      "release": "loki"
    },
    "name": "loki-promtail",
    "namespace": "default"
  },
  "spec": {
    "selector": {
      "matchLabels": {
        "app": "promtail",
        "release": "loki"
      }
    },
    "template": {
      "metadata": {
        "annotations": {
          "checksum/config": "8ae5fa01003daef888febf4268f9f5f9bcf1825c4b63c8af3d0106f8253eb904",
          "prometheus.io/port": "http-metrics",
          "prometheus.io/scrape": "true"
        },
        "labels": {
          "app": "promtail",
          "release": "loki"
        }
      },
      "spec": {
        "affinity": {},
        "containers": [
          {
            "args": [
              "-config.file=/etc/promtail/promtail.yaml",
              "-client.url=http://loki:3100/loki/api/v1/push"
            ],
            "env": [
              {
                "name": "HOSTNAME",
                "valueFrom": {
                  "fieldRef": {
                    "fieldPath": "spec.nodeName"
                  }
                }
              }
            ],
            "image": "grafana/promtail:v1.3.0",
            "imagePullPolicy": "IfNotPresent",
            "name": "promtail",
            "ports": [
              {
                "containerPort": 3101,
                "name": "http-metrics"
              }
            ],
            "readinessProbe": {
              "failureThreshold": 5,
              "httpGet": {
                "path": "/ready",
                "port": "http-metrics"
              },
              "initialDelaySeconds": 10,
              "periodSeconds": 10,
              "successThreshold": 1,
              "timeoutSeconds": 1
            },
            "resources": {},
            "securityContext": {
              "readOnlyRootFilesystem": true,
              "runAsGroup": 0,
              "runAsUser": 0
            },
            "volumeMounts": [
              {
                "mountPath": "/etc/promtail",
                "name": "config"
              },
              {
                "mountPath": "/run/promtail",
                "name": "run"
              },
              {
                "mountPath": "/var/lib/docker/containers",
                "name": "docker",
                "readOnly": true
              },
              {
                "mountPath": "/var/log/pods",
                "name": "pods",
                "readOnly": true
              }
            ]
          }
        ],
        "nodeSelector": {},
        "serviceAccountName": "loki-promtail",
        "tolerations": [
          {
            "effect": "NoSchedule",
            "key": "node-role.kubernetes.io/master",
            "operator": "Exists"
          }
        ],
        "volumes": [
          {
            "configMap": {
              "name": "loki-promtail"
            },
            "name": "config"
          },
          {
            "hostPath": {
              "path": "/run/promtail"
            },
            "name": "run"
          },
          {
            "hostPath": {
              "path": "/var/lib/docker/containers"
            },
            "name": "docker"
          },
          {
            "hostPath": {
              "path": "/var/log/pods"
            },
            "name": "pods"
          }
        ]
      }
    },
    "updateStrategy": {
      "type": "RollingUpdate"
    }
  }
}
