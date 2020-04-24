local version = '1.4.1';

{
  local loki = self,

  loki:: (import 'loki-jsonnet/loki/loki.libsonnet') {
    config+:: {
      name: 'loki',
      namespace: 'loki',
      image: 'grafana/loki:' + version,
      version: version,
    },
  },
  promtail:: (import 'loki-jsonnet/promtail/promtail.libsonnet') {
    config+:: {
      name: 'loki-promtail',
      namespace: 'loki',
      image: 'grafana/promtail:' + version,
      version: version,
      loki: {
        statefulSetName: loki.loki.statefulset.metadata.name,
        serviceName: loki.loki.service.metadata.name,
        replicas: loki.loki.statefulset.spec.replicas,
      },
    },
  },

  lokiCanaries:: [
    (import 'loki-jsonnet/loki-canary/loki-canary.libsonnet') {
      config+:: {
        name: 'loki-canary-%d' % i,
        namespace: 'loki',
        image: 'grafana/loki-canary:' + version,
        version: version,

        loki: {
          addr: '%s-%d.%s:3100' % [loki.loki.statefulset.metadata.name, i, loki.loki.service.metadata.name],
        },
      },
    }
    for i in std.range(0, loki.loki.statefulset.spec.replicas - 1)
  ],

  grafana:: ((import 'grafana/grafana.libsonnet') {
               _config+:: {
                 namespace: 'loki',

                 grafana+:: {
                   datasources: [loki.loki.datasource],
                 },
               },

               grafana+: {
                 deployment+: {
                   spec+: {
                     template+: {
                       spec+: {
                         securityContext: {},
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
             }).grafana,


  manifests:: [
    loki.grafana.dashboardSources,
    loki.grafana.dashboardDatasources,
    loki.grafana.deployment,
    loki.grafana.serviceAccount,
    loki.grafana.service,
  ] + [
    loki.loki[name]
    for name in std.objectFields(loki.loki)
  ] + [
    loki.promtail[name]
    for name in std.objectFields(loki.promtail)
  ] + [
    lokiCanary[name]
    for lokiCanary in loki.lokiCanaries
    for name in std.objectFields(lokiCanary)
  ],
}
