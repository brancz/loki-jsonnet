local loki = (import 'loki.libsonnet') {
  config+:: {
    name: 'loki',
    namespace: 'loki',
    image: 'grafana/loki:v1.3.0',
    version: '1.3.0',
  },
};

[
  loki[name]
  for name in std.objectFields(loki)
]
