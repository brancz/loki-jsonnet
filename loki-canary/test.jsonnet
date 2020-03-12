local lokiCanary = (import 'loki-canary.libsonnet') {
  config+:: {
    name: 'loki-canary',
    namespace: 'loki',
    image: 'grafana/loki-canary:v1.3.0',
    version: '1.3.0',

    loki: {
      addr: 'loki-0.loki:3100',
    },
  },
};

[
  lokiCanary[name]
  for name in std.objectFields(lokiCanary)
]
