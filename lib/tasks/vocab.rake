# frozen_string_literal: true

require 'csv'

namespace :vocab do
  desc 'Import a vocabulary from a CSV file'
  task :import, %i[filename vocab_identifier] => :environment do |task, args|
    # check for correct arguments
    usage_message = "Usage: #{task.name}[#{task.arg_names.join(',')}]"
    args.filename && args.vocab_identifier || raise(usage_message)

    data = CSV.table(args.filename)

    # check for the correct keys
    required_keys = %i[identifier label uri]
    required_columns_message = "Required columns are: #{required_keys.join(', ')}"
    all_keys_present = required_keys.all? { |key| data.headers&.include? key }
    raise(required_columns_message) unless all_keys_present

    vocabulary = Vocabulary.find_or_create_by(identifier: args.vocab_identifier)

    data.each do |row|
      individual = Individual.new(
        vocabulary: vocabulary,
        identifier: row[:identifier],
        label: row[:label],
        same_as: row[:uri]
      )
      next if individual.save

      individual.errors.each do |field, error|
        puts row[field]
        puts "#{field}: #{error}"
      end
      exit
    end
  end
end
