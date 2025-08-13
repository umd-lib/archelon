# frozen_string_literal: true

namespace :plantuml do
  task images: :environment do
    JAR_FILE = ENV.fetch('PLANTUML_JAR', nil)
    SRC_DIR = Rails.root.join('docs').to_s
    OUTPUT_DIR = Rails.root.join('docs/img').to_s
    IMAGE_FORMAT = 'svg'

    system 'java', '-jar', JAR_FILE, '-verbose', "-t#{IMAGE_FORMAT}", '-output', OUTPUT_DIR, SRC_DIR
  end
end
