# lib/tasks/sample_data.rake
namespace :solr do # rubocop:disable Metrics/BlockLength

  task :environment do
    config = YAML.safe_load(File.open(Rails.root.join('.solr_wrapper.yml')))
    SolrWrapper.default_instance_options = config
    @solr_instance = SolrWrapper.default_instance
  end

  desc 'Run Solr and Blacklight for interactive development'
  task :create_collection do
    SolrWrapper.wrap do |solr|
      solr.create(solr.config.collection_options)
      
    end
  end

  desc 'start solr server'
  task start_server: :environment do
    begin
      puts "Starting solr at #{@solr_instance.config.url}"
      @solr_instance.start
    rescue => e
      if e.message.include?("Port #{@solr_instance.port} is already being used by another process")
        puts "FAILED. Port #{@solr_instance.port} is already being used."
        puts " Did you already have solr running?"
        puts "  a) YES: Continue as you were. Solr is running."
        puts "  b) NO: Either set SOLR_OPTIONS[:port] to a different value or stop the process that's using port #{@solr_instance.port}."
      else
        raise "Failed to start solr. #{e.class}: #{e.message}"
      end
    end
  end

  desc "Put sample data into solr"
  task :rebuild_index => :environment do
    require 'yaml'
    if ENV['seed_file'].nil?
      abort "You must specify the seed_file.  Example: rake solr:rebuild_index seed_file=/path/to/seed/file"
    end
    seed_file = ENV['seed_file']
    docs = YAML.safe_load(File.open(seed_file))
    conn = Blacklight.default_index.connection
    conn.delete_by_query '*:*'
    conn.add docs
    conn.commit
  end
end
