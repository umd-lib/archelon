# frozen_string_literal: true

require 'boathook'

namespace :docker do
  Boathook::DockerTasks.new do |task|
    task.version = Archelon::VERSION
    task.image_specs = [
      { name: 'docker.lib.umd.edu/archelon' },
      { name: 'docker.lib.umd.edu/archelon-sftp', dockerfile: 'Dockerfile.sftp' }
    ]
  end
end
