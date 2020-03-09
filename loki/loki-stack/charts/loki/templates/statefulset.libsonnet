{
  apiVersion: 'apps/v1',
  kind: 'StatefulSet',
  metadata: {
    annotations: {},
    labels: {
      app: 'loki',
      chart: 'loki-0.25.1',
      heritage: 'Helm',
      release: 'loki',
    },
    name: 'loki',
    namespace: 'default',
  },
  spec: {
    podManagementPolicy: 'OrderedReady',
    replicas: 1,
    selector: {
      matchLabels: {
        app: 'loki',
        release: 'loki',
      },
    },
    serviceName: 'loki-headless',
    template: {
      metadata: {
        annotations: {
          'checksum/config': '55afb5b69f885f3b5401e2dc407a800cb71f9521ff62a07630e2f8473c101116',
          'prometheus.io/port': 'http-metrics',
          'prometheus.io/scrape': 'true',
        },
        labels: {
          app: 'loki',
          name: 'loki',
          release: 'loki',
        },
      },
      spec: {
        affinity: {},
        containers: [
          {
            args: [
              '-config.file=/etc/loki/loki.yaml',
            ],
            env: null,
            image: 'grafana/loki:v1.3.0',
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
            resources: {},
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
                subPath: null,
              },
            ],
          },
        ],
        initContainers: [],
        nodeSelector: {},
        securityContext: {
          fsGroup: 10001,
          runAsGroup: 10001,
          runAsNonRoot: true,
          runAsUser: 10001,
        },
        serviceAccountName: 'loki',
        terminationGracePeriodSeconds: 4800,
        tolerations: [],
        volumes: [
          {
            name: 'config',
            secret: {
              secretName: 'loki',
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
}
