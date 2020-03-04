# frozen_string_literal: true

require 'csv'

def check_import_headers(data)
  # check for the correct keys in the CSV file header
  required_keys = %i[identifier label uri]
  required_columns_message = "Required columns are: #{required_keys.join(', ')}"
  all_keys_present = required_keys.all? { |key| data.headers&.include? key }
  raise(required_columns_message) unless all_keys_present
end

def report_import_errors(individual, filename, line)
  puts "FAILED import from #{filename}:#{line}"
  individual.errors.each do |field, error|
    puts "  #{field}: #{error}"
  end
end

namespace :vocab do
  desc 'Import a vocabulary from a CSV file'
  task :import, %i[filename vocab_identifier] => :environment do |task, args|
    # check for correct arguments
    usage_message = "Usage: #{task.name}[#{task.arg_names.join(',')}]"
    args.filename && args.vocab_identifier || raise(usage_message)

    data = CSV.table(args.filename)
    check_import_headers(data)

    vocabulary = Vocabulary.find_or_create_by(identifier: args.vocab_identifier)

    import_count = 0
    data.each_with_index do |row, index|
      individual = Individual.new(
        vocabulary: vocabulary,
        identifier: row[:identifier],
        label: row[:label],
        same_as: row[:uri]
      )
      if individual.save
        import_count += 1
      else
        report_import_errors(individual, args.filename, index + 2)
      end
    end
    vocabulary.publish_rdf :all
    puts "Imported #{import_count} terms from #{args.filename} into #{args.vocab_identifier}"
  end
end
