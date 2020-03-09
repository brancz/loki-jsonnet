{
  "apiVersion": "rbac.authorization.k8s.io/v1",
  "kind": "ClusterRoleBinding",
  "metadata": {
    "labels": {
      "app": "promtail",
      "chart": "promtail-0.19.2",
      "heritage": "Helm",
      "release": "loki"
    },
    "name": "loki-promtail-clusterrolebinding"
  },
  "roleRef": {
    "apiGroup": "rbac.authorization.k8s.io",
    "kind": "ClusterRole",
    "name": "loki-promtail-clusterrole"
  },
  "subjects": [
    {
      "kind": "ServiceAccount",
      "name": "loki-promtail",
      "namespace": "default"
    }
  ]
}
