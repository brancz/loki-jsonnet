{
  "apiVersion": "rbac.authorization.k8s.io/v1",
  "kind": "RoleBinding",
  "metadata": {
    "labels": {
      "app": "loki",
      "chart": "loki-0.25.1",
      "heritage": "Helm",
      "release": "loki"
    },
    "name": "loki",
    "namespace": "default"
  },
  "roleRef": {
    "apiGroup": "rbac.authorization.k8s.io",
    "kind": "Role",
    "name": "loki"
  },
  "subjects": [
    {
      "kind": "ServiceAccount",
      "name": "loki"
    }
  ]
}
