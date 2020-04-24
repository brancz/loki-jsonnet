local lokiCanary = (import 'loki-canary.libsonnet') {
  config+:: {
    name: 'loki-canary',
    namespace: 'loki',
    image: 'grafana/loki-canary:1.4.1',
    version: '1.4.1',

    loki: {
      addr: 'loki-0.loki:3100',
    },
  },
};

[
  lokiCanary[name]
  for name in std.objectFields(lokiCanary)
]
