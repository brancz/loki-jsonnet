{
  "apiVersion": "rbac.authorization.k8s.io/v1",
  "kind": "Role",
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
  "rules": [
    {
      "apiGroups": [
        "extensions"
      ],
      "resourceNames": [
        "loki"
      ],
      "resources": [
        "podsecuritypolicies"
      ],
      "verbs": [
        "use"
      ]
    }
  ]
}
