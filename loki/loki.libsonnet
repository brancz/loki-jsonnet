{
  local loki = self,

  config:: {
    name: error 'must provide name',
    namespace: error 'must provide namespace',
    image: error 'must provide image',
    version: error 'must provide version',

    commonLabels:: {
      'app.kubernetes.io/name': 'loki',
      'app.kubernetes.io/instance': loki.config.name,
      'app.kubernetes.io/version': loki.config.version,
      'app.kubernetes.io/component': 'storage',
      'app.kubernetes.io/part-of': 'loki',
    },

    podLabelSelector:: {
      [labelName]: loki.config.commonLabels[labelName]
      for labelName in std.objectFields(loki.config.commonLabels)
      if !std.setMember(labelName, ['app.kubernetes.io/version'])
    },
  },

  datasource:: {
    access: 'proxy',
    name: loki.config.name,
    type: 'loki',
    url: 'http://%s.%s.svc:3100' % [loki.config.name, loki.config.namespace],
    version: 1,
    editable: false,
  },

  podsecuritypolicy: {
    apiVersion: 'policy/v1beta1',
    kind: 'PodSecurityPolicy',
    metadata: {
      name: loki.config.name,
    },
    spec: {
      allowPrivilegeEscalation: false,
      fsGroup: {
        ranges: [
          {
            max: 65535,
            min: 1,
          },
        ],
        rule: 'MustRunAs',
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
        rule: 'MustRunAsNonRoot',
      },
      seLinux: {
        rule: 'RunAsAny',
      },
      supplementalGroups: {
        ranges: [
          {
            max: 65535,
            min: 1,
          },
        ],
        rule: 'MustRunAs',
      },
      volumes: [
        'configMap',
        'emptyDir',
        'persistentVolumeClaim',
        'secret',
      ],
    },
  },
  rolebinding: {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'RoleBinding',
    metadata: {
      name: loki.config.name,
      namespace: loki.config.namespace,
    },
    roleRef: {
      apiGroup: 'rbac.authorization.k8s.io',
      kind: 'Role',
      name: loki.role.metadata.name,
    },
    subjects: [
      {
        kind: 'ServiceAccount',
        name: loki.serviceaccount.metadata.name,
      },
    ],
  },
  role: {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'Role',
    metadata: {
      name: loki.config.name,
      namespace: loki.config.namespace,
    },
    rules: [
      {
        apiGroups: [
          'extensions',
        ],
        resourceNames: [
          loki.podsecuritypolicy.metadata.name,
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
  secret: {
    local secret = self,

    config:: {
      auth_enabled: false,
      chunk_store_config: {
        max_look_back_period: 0,
      },
      ingester: {
        chunk_block_size: 262144,
        chunk_idle_period: '3m',
        chunk_retain_period: '1m',
        lifecycler: {
          ring: {
            kvstore: {
              store: 'inmemory',
            },
            replication_factor: 1,
          },
        },
        max_transfer_retries: 0,
      },
      limits_config: {
        enforce_metric_name: false,
        reject_old_samples: true,
        reject_old_samples_max_age: '168h',
      },
      schema_config: {
        configs: [
          {
            from: '2018-04-15',
            index: {
              period: '168h',
              prefix: 'index_',
            },
            object_store: 'filesystem',
            schema: 'v9',
            store: 'boltdb',
          },
        ],
      },
      server: {
        http_listen_port: 3100,
      },
      storage_config: {
        boltdb: {
          directory: '/data/loki/index',
        },
        filesystem: {
          directory: '/data/loki/chunks',
        },
      },
      table_manager: {
        retention_deletes_enabled: false,
        retention_period: 0,
      },
    },

    apiVersion: 'v1',
    stringData: {
      'loki.yaml': std.manifestJsonEx(secret.config, '    '),
    },
    kind: 'Secret',
    metadata: {
      name: loki.config.name,
      namespace: loki.config.namespace,
    },
  },
  serviceaccount: {
    apiVersion: 'v1',
    kind: 'ServiceAccount',
    metadata: {
      name: loki.config.name,
      namespace: loki.config.namespace,
    },
  },
  service: {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: loki.config.name,
      namespace: loki.config.namespace,
      labels: loki.config.commonLabels,
    },
    spec: {
      ports: [
        {
          name: 'http-metrics',
          port: 3100,
          protocol: 'TCP',
          targetPort: 'http-metrics',
        },
      ],
      selector: loki.config.podLabelSelector,
      sessionAffinity: 'ClientIP',
      type: 'ClusterIP',
    },
  },
  statefulset: {
    apiVersion: 'apps/v1',
    kind: 'StatefulSet',
    metadata: {
      name: loki.config.name,
      namespace: loki.config.namespace,
    },
    spec: {
      podManagementPolicy: 'OrderedReady',
      replicas: 2,
      selector: {
        matchLabels: loki.config.podLabelSelector,
      },
      serviceName: loki.service.metadata.name,
      template: {
        metadata: {
          annotations: {
            'checksum/config': '55afb5b69f885f3b5401e2dc407a800cb71f9521ff62a07630e2f8473c101116',
          },
          labels: loki.config.commonLabels,
        },
        spec: {
          containers: [
            {
              args: [
                '-config.file=/etc/loki/loki.yaml',
              ],
              image: loki.config.image,
              imagePullPolicy: 'IfNotPresent',
              livenessProbe: {
                httpGet: {
                  path: '/ready',
                  port: 'http-metrics',
                },
                initialDelaySeconds: 45,
              },
              name: 'loki',
              ports: [
                {
                  containerPort: 3100,
                  name: 'http-metrics',
                  protocol: 'TCP',
                },
              ],
              readinessProbe: {
                httpGet: {
                  path: '/ready',
                  port: 'http-metrics',
                },
                initialDelaySeconds: 45,
              },
              securityContext: {
                readOnlyRootFilesystem: true,
              },
              volumeMounts: [
                {
                  mountPath: '/etc/loki',
                  name: 'config',
                },
                {
                  mountPath: '/data',
                  name: 'storage',
                },
              ],
            },
          ],
          securityContext: {
            fsGroup: 10001,
            runAsGroup: 10001,
            runAsNonRoot: true,
            runAsUser: 10001,
          },
          serviceAccountName: loki.serviceaccount.metadata.name,
          terminationGracePeriodSeconds: 4800,
          volumes: [
            {
              name: 'config',
              secret: {
                secretName: loki.secret.metadata.name,
              },
            },
            {
              emptyDir: {},
              name: 'storage',
            },
          ],
        },
      },
      updateStrategy: {
        type: 'RollingUpdate',
      },
    },
  },

  withVolumeClaimTemplate:: {
    local l = self,
    config+:: {
      volumeClaimTemplate: error 'must provide volumeClaimTemplate',
    },
    statefulset+: {
      spec+: {
        template+: {
          spec+: {
            volumes: std.filter(function(v) v.name != 'storage', super.volumes),
          },
        },
        volumeClaimTemplates: [l.config.volumeClaimTemplate {
          metadata+: {
            name: 'storage',
          },
        }],
      },
    },
  },
}
