FCREPO_AUTH_TOKEN = ENV.fetch('FCREPO_AUTH_TOKEN', '')
# When using Docker or Kubernetes, the fcrepo URL that is displayed,
# the "external" URL, may be different from the "internal"
# Docker/Kubernetes URL
# the "external" URL (e.g., https://fcrepo.lib.umd.edu/fcrepo/rest)
FCREPO_ENDPOINT = ENV['FCREPO_ENDPOINT']
# the "internal" URL (e.g., http://fcrepo-local:8080/fcrepo/rest)
FCREPO_ORIGIN = ENV.fetch('FCREPO_ORIGIN', nil)
