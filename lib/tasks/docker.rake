# frozen_string_literal: true

namespace :docker do
  task :build do
    images.each { |image| build_image(**image) }
  end

  task :push do
    images.each { |image| push_image(tag: image[:tag]) }
  end
end

def build_image(tag:, dockerfile: 'Dockerfile', context: '.')
  puts "Building #{tag} (dockerfile: #{dockerfile}, context: #{context})"
  system 'docker', 'build', '-t', tag, '-f', dockerfile, context
end

def push_image(tag:)
  puts "Pushing #{tag}"
  system 'docker', 'push', tag
end

def images
  [
    { tag: "docker.lib.umd.edu/archelon:#{version_number}" },
    { tag: "docker.lib.umd.edu/archelon-sftp:#{version_number}", dockerfile: 'Dockerfile.sftp' }
  ]
end

# Use "latest" for any development version (identified by the presence
# of "dev" in the version number). Otherwise, just use the Archelon::VERSION.
def version_number
  return 'latest' if Archelon::VERSION.include? 'dev'

  Archelon::VERSION
end
