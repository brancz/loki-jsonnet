{
  local promtail = self,

  config:: {
    name: error 'must provide name',
    namespace: error 'must provide namespace',
    image: error 'must provide image',
    version: error 'must provide version',

    loki: {
      replicas: error 'must provide loki replicas',
    },

    commonLabels:: {
      'app.kubernetes.io/name': 'promtail',
      'app.kubernetes.io/instance': promtail.config.name,
      'app.kubernetes.io/version': promtail.config.version,
      'app.kubernetes.io/component': 'log-collector',
      'app.kubernetes.io/part-of': 'loki',
    },

    podLabelSelector:: {
      [labelName]: promtail.config.commonLabels[labelName]
      for labelName in std.objectFields(promtail.config.commonLabels)
      if !std.setMember(labelName, ['app.kubernetes.io/version'])
    },
  },

  clusterrolebinding: {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'ClusterRoleBinding',
    metadata: {
      name: promtail.config.name,
    },
    roleRef: {
      apiGroup: 'rbac.authorization.k8s.io',
      kind: 'ClusterRole',
      name: promtail.clusterrole.metadata.name,
    },
    subjects: [
      {
        kind: 'ServiceAccount',
        name: promtail.serviceaccount.metadata.name,
        namespace: promtail.serviceaccount.metadata.namespace,
      },
    ],
  },
  clusterrole: {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'ClusterRole',
    metadata: {
      name: promtail.config.name,
    },
    rules: [
      {
        apiGroups: [
          '',
        ],
        resources: [
          'nodes',
          'nodes/proxy',
          'services',
          'endpoints',
          'pods',
        ],
        verbs: [
          'get',
          'watch',
          'list',
        ],
      },
    ],
  },
  configmap: {
    local configmap = self,

    config:: {
      positions: {
        filename: '/run/promtail/positions.yaml',
      },
      scrape_configs: [
        {
          job_name: 'kubernetes-pods-name',
          kubernetes_sd_configs: [
            {
              role: 'pod',
            },
          ],
          pipeline_stages: [
            {
              docker: {},
            },
          ],
          relabel_configs: [
            {
              source_labels: [
                '__meta_kubernetes_pod_label_name',
              ],
              target_label: '__service__',
            },
            {
              source_labels: [
                '__meta_kubernetes_pod_node_name',
              ],
              target_label: '__host__',
            },
            {
              action: 'drop',
              regex: '',
              source_labels: [
                '__service__',
              ],
            },
            {
              action: 'labelmap',
              regex: '__meta_kubernetes_pod_label_(.+)',
            },
            {
              action: 'replace',
              replacement: null,
              separator: '/',
              source_labels: [
                '__meta_kubernetes_namespace',
                '__service__',
              ],
              target_label: 'job',
            },
            {
              action: 'replace',
              source_labels: [
                '__meta_kubernetes_namespace',
              ],
              target_label: 'namespace',
            },
            {
              action: 'replace',
              source_labels: [
                '__meta_kubernetes_pod_name',
              ],
              target_label: 'instance',
            },
            {
              action: 'replace',
              source_labels: [
                '__meta_kubernetes_pod_container_name',
              ],
              target_label: 'container_name',
            },
            {
              replacement: '/var/log/pods/*$1/*.log',
              separator: '/',
              source_labels: [
                '__meta_kubernetes_pod_uid',
                '__meta_kubernetes_pod_container_name',
              ],
              target_label: '__path__',
            },
          ],
        },
        {
          job_name: 'kubernetes-pods-app',
          kubernetes_sd_configs: [
            {
              role: 'pod',
            },
          ],
          pipeline_stages: [
            {
              docker: {},
            },
          ],
          relabel_configs: [
            {
              action: 'drop',
              regex: '.+',
              source_labels: [
                '__meta_kubernetes_pod_label_name',
              ],
            },
            {
              source_labels: [
                '__meta_kubernetes_pod_label_app',
              ],
              target_label: '__service__',
            },
            {
              source_labels: [
                '__meta_kubernetes_pod_node_name',
              ],
              target_label: '__host__',
            },
            {
              action: 'drop',
              regex: '',
              source_labels: [
                '__service__',
              ],
            },
            {
              action: 'labelmap',
              regex: '__meta_kubernetes_pod_label_(.+)',
            },
            {
              action: 'replace',
              replacement: null,
              separator: '/',
              source_labels: [
                '__meta_kubernetes_namespace',
                '__service__',
              ],
              target_label: 'job',
            },
            {
              action: 'replace',
              source_labels: [
                '__meta_kubernetes_namespace',
              ],
              target_label: 'namespace',
            },
            {
              action: 'replace',
              source_labels: [
                '__meta_kubernetes_pod_name',
              ],
              target_label: 'instance',
            },
            {
              action: 'replace',
              source_labels: [
                '__meta_kubernetes_pod_container_name',
              ],
              target_label: 'container_name',
            },
            {
              replacement: '/var/log/pods/*$1/*.log',
              separator: '/',
              source_labels: [
                '__meta_kubernetes_pod_uid',
                '__meta_kubernetes_pod_container_name',
              ],
              target_label: '__path__',
            },
          ],
        },
        {
          job_name: 'kubernetes-pods-direct-controllers',
          kubernetes_sd_configs: [
            {
              role: 'pod',
            },
          ],
          pipeline_stages: [
            {
              docker: {},
            },
          ],
          relabel_configs: [
            {
              action: 'drop',
              regex: '.+',
              separator: '',
              source_labels: [
                '__meta_kubernetes_pod_label_name',
                '__meta_kubernetes_pod_label_app',
              ],
            },
            {
              action: 'drop',
              regex: '[0-9a-z-.]+-[0-9a-f]{8,10}',
              source_labels: [
                '__meta_kubernetes_pod_controller_name',
              ],
            },
            {
              source_labels: [
                '__meta_kubernetes_pod_controller_name',
              ],
              target_label: '__service__',
            },
            {
              source_labels: [
                '__meta_kubernetes_pod_node_name',
              ],
              target_label: '__host__',
            },
            {
              action: 'drop',
              regex: '',
              source_labels: [
                '__service__',
              ],
            },
            {
              action: 'labelmap',
              regex: '__meta_kubernetes_pod_label_(.+)',
            },
            {
              action: 'replace',
              replacement: null,
              separator: '/',
              source_labels: [
                '__meta_kubernetes_namespace',
                '__service__',
              ],
              target_label: 'job',
            },
            {
              action: 'replace',
              source_labels: [
                '__meta_kubernetes_namespace',
              ],
              target_label: 'namespace',
            },
            {
              action: 'replace',
              source_labels: [
                '__meta_kubernetes_pod_name',
              ],
              target_label: 'instance',
            },
            {
              action: 'replace',
              source_labels: [
                '__meta_kubernetes_pod_container_name',
              ],
              target_label: 'container_name',
            },
            {
              replacement: '/var/log/pods/*$1/*.log',
              separator: '/',
              source_labels: [
                '__meta_kubernetes_pod_uid',
                '__meta_kubernetes_pod_container_name',
              ],
              target_label: '__path__',
            },
          ],
        },
        {
          job_name: 'kubernetes-pods-indirect-controller',
          kubernetes_sd_configs: [
            {
              role: 'pod',
            },
          ],
          pipeline_stages: [
            {
              docker: {},
            },
          ],
          relabel_configs: [
            {
              action: 'drop',
              regex: '.+',
              separator: '',
              source_labels: [
                '__meta_kubernetes_pod_label_name',
                '__meta_kubernetes_pod_label_app',
              ],
            },
            {
              action: 'keep',
              regex: '[0-9a-z-.]+-[0-9a-f]{8,10}',
              source_labels: [
                '__meta_kubernetes_pod_controller_name',
              ],
            },
            {
              action: 'replace',
              regex: '([0-9a-z-.]+)-[0-9a-f]{8,10}',
              source_labels: [
                '__meta_kubernetes_pod_controller_name',
              ],
              target_label: '__service__',
            },
            {
              source_labels: [
                '__meta_kubernetes_pod_node_name',
              ],
              target_label: '__host__',
            },
            {
              action: 'drop',
              regex: '',
              source_labels: [
                '__service__',
              ],
            },
            {
              action: 'labelmap',
              regex: '__meta_kubernetes_pod_label_(.+)',
            },
            {
              action: 'replace',
              replacement: null,
              separator: '/',
              source_labels: [
                '__meta_kubernetes_namespace',
                '__service__',
              ],
              target_label: 'job',
            },
            {
              action: 'replace',
              source_labels: [
                '__meta_kubernetes_namespace',
              ],
              target_label: 'namespace',
            },
            {
              action: 'replace',
              source_labels: [
                '__meta_kubernetes_pod_name',
              ],
              target_label: 'instance',
            },
            {
              action: 'replace',
              source_labels: [
                '__meta_kubernetes_pod_container_name',
              ],
              target_label: 'container_name',
            },
            {
              replacement: '/var/log/pods/*$1/*.log',
              separator: '/',
              source_labels: [
                '__meta_kubernetes_pod_uid',
                '__meta_kubernetes_pod_container_name',
              ],
              target_label: '__path__',
            },
          ],
        },
        {
          job_name: 'kubernetes-pods-static',
          kubernetes_sd_configs: [
            {
              role: 'pod',
            },
          ],
          pipeline_stages: [
            {
              docker: {},
            },
          ],
          relabel_configs: [
            {
              action: 'drop',
              regex: '',
              source_labels: [
                '__meta_kubernetes_pod_annotation_kubernetes_io_config_mirror',
              ],
            },
            {
              action: 'replace',
              source_labels: [
                '__meta_kubernetes_pod_label_component',
              ],
              target_label: '__service__',
            },
            {
              source_labels: [
                '__meta_kubernetes_pod_node_name',
              ],
              target_label: '__host__',
            },
            {
              action: 'drop',
              regex: '',
              source_labels: [
                '__service__',
              ],
            },
            {
              action: 'labelmap',
              regex: '__meta_kubernetes_pod_label_(.+)',
            },
            {
              action: 'replace',
              replacement: null,
              separator: '/',
              source_labels: [
                '__meta_kubernetes_namespace',
                '__service__',
              ],
              target_label: 'job',
            },
            {
              action: 'replace',
              source_labels: [
                '__meta_kubernetes_namespace',
              ],
              target_label: 'namespace',
            },
            {
              action: 'replace',
              source_labels: [
                '__meta_kubernetes_pod_name',
              ],
              target_label: 'instance',
            },
            {
              action: 'replace',
              source_labels: [
                '__meta_kubernetes_pod_container_name',
              ],
              target_label: 'container_name',
            },
            {
              replacement: '/var/log/pods/*$1/*.log',
              separator: '/',
              source_labels: [
                '__meta_kubernetes_pod_annotation_kubernetes_io_config_mirror',
                '__meta_kubernetes_pod_container_name',
              ],
              target_label: '__path__',
            },
          ],
        },
      ],
      server: {
        http_listen_port: 3101,
      },
      clients: [
        {
          url: 'http://%s-%d.%s:3100/loki/api/v1/push' % [promtail.config.loki.statefulSetName, i, promtail.config.loki.serviceName],
          backoff_config: {
            maxbackoff: '5s',
            maxretries: 20,
            minbackoff: '100ms',
          },
          batchsize: 102400,
          batchwait: '1s',
          external_labels: {},
          timeout: '10s',
        }
        for i in std.range(0, promtail.config.loki.replicas - 1)
      ],
      target_config: {
        sync_period: '10s',
      },
    },

    apiVersion: 'v1',
    data: {
      'promtail.yaml': std.manifestJsonEx(configmap.config, '    '),
    },
    kind: 'ConfigMap',
    metadata: {
      name: promtail.config.name,
      namespace: promtail.config.namespace,
    },
  },
  daemonset: {
    apiVersion: 'apps/v1',
    kind: 'DaemonSet',
    metadata: {
      name: promtail.config.name,
      namespace: promtail.config.namespace,
    },
    spec: {
      selector: {
        matchLabels: promtail.config.podLabelSelector,
      },
      template: {
        metadata: {
          annotations: {
            'checksum/config': std.md5(promtail.configmap.data['promtail.yaml']),
          },
          labels: promtail.config.commonLabels,
        },
        spec: {
          containers: [
            {
              args: [
                '-config.file=/etc/promtail/promtail.yaml',
              ],
              env: [
                {
                  name: 'HOSTNAME',
                  valueFrom: {
                    fieldRef: {
                      fieldPath: 'spec.nodeName',
                    },
                  },
                },
              ],
              image: promtail.config.image,
              imagePullPolicy: 'IfNotPresent',
              name: 'promtail',
              ports: [
                {
                  containerPort: 3101,
                  name: 'http-metrics',
                },
              ],
              readinessProbe: {
                failureThreshold: 5,
                httpGet: {
                  path: '/ready',
                  port: 'http-metrics',
                },
                initialDelaySeconds: 10,
                periodSeconds: 10,
                successThreshold: 1,
                timeoutSeconds: 1,
              },
              securityContext: {
                readOnlyRootFilesystem: true,
                runAsGroup: 0,
                runAsUser: 0,
              },
              volumeMounts: [
                {
                  mountPath: '/etc/promtail',
                  name: 'config',
                },
                {
                  mountPath: '/run/promtail',
                  name: 'run',
                },
                {
                  mountPath: '/var/lib/docker/containers',
                  name: 'docker',
                  readOnly: true,
                },
                {
                  mountPath: '/var/log/pods',
                  name: 'pods',
                  readOnly: true,
                },
              ],
            },
          ],
          serviceAccountName: promtail.serviceaccount.metadata.name,
          tolerations: [
            {
              effect: 'NoSchedule',
              key: 'node-role.kubernetes.io/master',
              operator: 'Exists',
            },
          ],
          volumes: [
            {
              configMap: {
                name: promtail.configmap.metadata.name,
              },
              name: 'config',
            },
            {
              hostPath: {
                path: '/run/promtail',
              },
              name: 'run',
            },
            {
              hostPath: {
                path: '/var/lib/docker/containers',
              },
              name: 'docker',
            },
            {
              hostPath: {
                path: '/var/log/pods',
              },
              name: 'pods',
            },
          ],
        },
      },
      updateStrategy: {
        type: 'RollingUpdate',
      },
    },
  },
  podsecuritypolicy: {
    apiVersion: 'policy/v1beta1',
    kind: 'PodSecurityPolicy',
    metadata: {
      name: promtail.config.name,
    },
    spec: {
      allowPrivilegeEscalation: false,
      fsGroup: {
        rule: 'RunAsAny',
      },
      hostIPC: false,
      hostNetwork: false,
      hostPID: false,
      privileged: false,
      readOnlyRootFilesystem: true,
      requiredDropCapabilities: [
        'ALL',
      ],
      runAsUser: {
        rule: 'RunAsAny',
      },
      seLinux: {
        rule: 'RunAsAny',
      },
      supplementalGroups: {
        rule: 'RunAsAny',
      },
      volumes: [
        'secret',
        'configMap',
        'hostPath',
      ],
    },
  },
  rolebinding: {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'RoleBinding',
    metadata: {
      name: promtail.config.name,
      namespace: promtail.config.namespace,
    },
    roleRef: {
      apiGroup: 'rbac.authorization.k8s.io',
      kind: 'Role',
      name: promtail.role.metadata.name,
    },
    subjects: [
      {
        kind: 'ServiceAccount',
        name: promtail.serviceaccount.metadata.name,
      },
    ],
  },
  role: {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'Role',
    metadata: {
      name: promtail.config.name,
      namespace: promtail.config.namespace,
    },
    rules: [
      {
        apiGroups: [
          'extensions',
        ],
        resourceNames: [
          promtail.podsecuritypolicy.metadata.name,
        ],
        resources: [
          'podsecuritypolicies',
        ],
        verbs: [
          'use',
        ],
      },
    ],
  },
  serviceaccount: {
    apiVersion: 'v1',
    kind: 'ServiceAccount',
    metadata: {
      name: promtail.config.name,
      namespace: promtail.config.namespace,
    },
  },
}
