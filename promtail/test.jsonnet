local promtail = (import 'promtail.libsonnet') {
  config+:: {
    name: 'loki-promtail',
    namespace: 'loki',
    image: 'grafana/promtail:1.4.1',
    version: '1.4.1',

    loki+: {
      replicas: 1,
      statefulSetName: 'loki',
      serviceName: 'loki',
    },
  },
};

[
  promtail[name]
  for name in std.objectFields(promtail)
]
