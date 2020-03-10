local promtail = (import 'promtail.libsonnet') {
  config+:: {
    name: 'loki-promtail',
    namespace: 'loki',
    image: 'grafana/promtail:v1.3.0',
    version: '1.3.0',
  },
};

[
  promtail[name]
  for name in std.objectFields(promtail)
]
