{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'Role',
  metadata: {
    name: 'loki',
  },
  rules: [
    {
      apiGroups: [
        'extensions',
      ],
      resourceNames: [
        'loki',
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
