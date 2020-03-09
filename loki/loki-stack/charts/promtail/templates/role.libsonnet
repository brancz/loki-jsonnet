{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'Role',
  metadata: {
    labels: {
      app: 'promtail',
      chart: 'promtail-0.19.2',
      heritage: 'Helm',
      release: 'loki',
    },
    name: 'loki-promtail',
    namespace: 'default',
  },
  rules: [
    {
      apiGroups: [
        'extensions',
      ],
      resourceNames: [
        'loki-promtail',
      ],
      resources: [
        'podsecuritypolicies',
      ],
      verbs: [
        'use',
      ],
    },
  ],
}
