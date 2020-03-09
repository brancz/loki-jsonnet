{
  apiVersion: 'policy/v1beta1',
  kind: 'PodSecurityPolicy',
  metadata: {
    labels: {
      app: 'promtail',
      chart: 'promtail-0.19.2',
      heritage: 'Helm',
      release: 'loki',
    },
    name: 'loki-promtail',
    namespace: 'default',
  },
  spec: {
    allowPrivilegeEscalation: false,
    fsGroup: {
      rule: 'RunAsAny',
    },
    hostIPC: false,
    hostNetwork: false,
    hostPID: false,
    privileged: false,
    readOnlyRootFilesystem: true,
    requiredDropCapabilities: [
      'ALL',
    ],
    runAsUser: {
      rule: 'RunAsAny',
    },
    seLinux: {
      rule: 'RunAsAny',
    },
    supplementalGroups: {
      rule: 'RunAsAny',
    },
    volumes: [
      'secret',
      'configMap',
      'hostPath',
    ],
  },
}
