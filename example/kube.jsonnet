local loki = (import 'loki-jsonnet/loki/loki.libsonnet') {
  config+:: {
    name: 'loki',
    namespace: 'loki',
    image: 'grafana/loki:v1.3.0',
    version: '1.3.0',
  },
};

local promtail = (import 'loki-jsonnet/promtail/promtail.libsonnet') {
  config+:: {
    name: 'loki-promtail',
    namespace: 'loki',
    image: 'grafana/promtail:v1.3.0',
    version: '1.3.0',
    loki: {
      statefulSetName: loki.statefulset.metadata.name,
      serviceName: loki.service.metadata.name,
      replicas: loki.statefulset.spec.replicas,
    },
  },
};

local lokiCanaries = [
  (import 'loki-jsonnet/loki-canary/loki-canary.libsonnet') {
    config+:: {
      name: 'loki-canary-%d' % i,
      namespace: 'loki',
      image: 'grafana/loki-canary:v1.3.0',
      version: '1.3.0',

      loki: {
        addr: '%s-%d.%s:3100' % [loki.statefulset.metadata.name, i, loki.service.metadata.name],
      },
    },
  }
  for i in std.range(0, loki.statefulset.spec.replicas - 1)
];

local grafana = ((import 'grafana/grafana.libsonnet') {
                   _config+:: {
                     namespace: 'loki',

                     grafana+:: {
                       datasources: [loki.datasource],
                     },
                   },

                   grafana+: {
                     deployment+: {
                       spec+: {
                         template+: {
                           spec+: {
                             containers: [
                               if c.name == 'grafana' then c {
                                 securityContext: {},
                               } else c
                               for c in super.containers
                             ],
                           },
                         },
                       },
                     },
                   },
                 }).grafana;

[
  grafana.dashboardSources,
  grafana.dashboardDatasources,
  grafana.deployment,
  grafana.serviceAccount,
  grafana.service,
] + [
  loki[name]
  for name in std.objectFields(loki)
] + [
  promtail[name]
  for name in std.objectFields(promtail)
] + [
  lokiCanary[name]
  for lokiCanary in lokiCanaries
  for name in std.objectFields(lokiCanary)
]
