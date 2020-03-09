{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'ClusterRole',
  metadata: {
    labels: {
      app: 'promtail',
      chart: 'promtail-0.19.2',
      heritage: 'Helm',
      release: 'loki',
    },
    name: 'loki-promtail-clusterrole',
    namespace: 'default',
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
}
