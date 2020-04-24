local loki = (import 'loki.libsonnet') {
  config+:: {
    name: 'loki',
    namespace: 'loki',
    image: 'grafana/loki:1.4.1',
    version: '1.4.1',
  },
};

[
  loki[name]
  for name in std.objectFields(loki)
]
