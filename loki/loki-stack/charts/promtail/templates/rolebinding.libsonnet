{
  "apiVersion": "rbac.authorization.k8s.io/v1",
  "kind": "RoleBinding",
  "metadata": {
    "labels": {
      "app": "promtail",
      "chart": "promtail-0.19.2",
      "heritage": "Helm",
      "release": "loki"
    },
    "name": "loki-promtail",
    "namespace": "default"
  },
  "roleRef": {
    "apiGroup": "rbac.authorization.k8s.io",
    "kind": "Role",
    "name": "loki-promtail"
  },
  "subjects": [
    {
      "kind": "ServiceAccount",
      "name": "loki-promtail"
    }
  ]
}
