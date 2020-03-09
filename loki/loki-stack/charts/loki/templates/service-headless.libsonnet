{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    labels: {
      app: 'loki',
      chart: 'loki-0.25.1',
      heritage: 'Helm',
      release: 'loki',
    },
    name: 'loki-headless',
    namespace: 'default',
  },
  spec: {
    clusterIP: 'None',
    ports: [
      {
        name: 'http-metrics',
        port: 3100,
        protocol: 'TCP',
        targetPort: 'http-metrics',
      },
    ],
    selector: {
      app: 'loki',
      release: 'loki',
    },
  },
}
