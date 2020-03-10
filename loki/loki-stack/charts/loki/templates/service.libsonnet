{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'loki',
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
    selector: {
      app: 'loki',
      release: 'loki',
    },
    type: 'ClusterIP',
  },
}
