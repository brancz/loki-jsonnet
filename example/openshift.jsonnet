local loki = (import 'common.libsonnet') {
  promtail+:: (import 'loki-jsonnet/promtail/promtail.libsonnet').withPrivilegedSecurityContextConstraint {
    configmap+: {
      config+:: {
        scrape_configs: [
          c {
            pipeline_stages: [{
              cri: {},
            }],
          }
          for c in super.scrape_configs
        ],
      },
    },
  },
};

loki.manifests
