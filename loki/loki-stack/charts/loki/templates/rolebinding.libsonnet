{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'RoleBinding',
  metadata: {
    name: 'loki',
  },
  roleRef: {
    apiGroup: 'rbac.authorization.k8s.io',
    kind: 'Role',
    name: 'loki',
  },
  subjects: [
    {
      kind: 'ServiceAccount',
      name: 'loki',
    },
  ],
}
