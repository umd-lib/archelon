# frozen_string_literal: true

namespace :plantuml do
  task images: :environment do
    jar_file = ENV.fetch('PLANTUML_JAR', nil)
    src_dir = Rails.root.join('docs').to_s
    output_dir = Rails.root.join('docs/img').to_s
    image_format = 'svg'

    system 'java', '-jar', jar_file, '-verbose', "-t#{image_format}", '-output', output_dir, src_dir
  end
end
