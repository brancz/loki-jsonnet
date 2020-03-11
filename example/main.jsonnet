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


local grafana = ((import 'grafana/grafana.libsonnet') {
                   _config+:: {
                     namespace: 'loki',

                     grafana+:: {
                       datasources: [loki.datasource],
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
]
