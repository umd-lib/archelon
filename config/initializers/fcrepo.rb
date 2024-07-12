FCREPO_BASE_URL = ENV.fetch('FCREPO_BASE_URL', '')

FCREPO_AUTH_TOKEN = ENV.fetch('FCREPO_AUTH_TOKEN', '')

# When using Docker or Kubernetes, the fcrepo URL that is displayed,
# the "external" URL, may be different from the "internal"
# Docker/Kubernetes URL
REPO_EXTERNAL_URL = ENV.fetch('REPO_EXTERNAL_URL', '')
