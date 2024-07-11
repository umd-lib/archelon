# frozen_string_literal: true

# lib/tasks/add_public_key.rake
namespace :user do # rubocop:disable Metrics/BlockLength
  desc 'Add a public key for an existing user.'
  task :add_public_key, %i[cas_directory_id public_key] => :environment do |_t, args|
    # Given a CAS directory id and a public key string, the given public key
    # will be added for the user.
    cas_directory_id = args[:cas_directory_id]
    public_key = args[:public_key].strip
    create_public_key(cas_directory_id, public_key)
  end

  desc 'Add a public key file for an existing user.'
  task :add_public_key_file, %i[cas_directory_id public_key_file] => :environment do |_t, args|
    cas_directory_id = args[:cas_directory_id]
    public_key_file = args[:public_key_file]

    unless File.exist?(public_key_file)
      puts "Cannot read file '#{public_key_file}'"
      exit(1)
    end

    public_key = File.read(public_key_file).strip

    create_public_key(cas_directory_id, public_key)
  end

  def create_public_key(cas_directory_id, public_key)
    cas_user = retrieve_cas_user(cas_directory_id)
    verify_public_key(public_key)

    pub_key_record = PublicKey.new(key: public_key, cas_user: cas_user)
    pub_key_record.save!
    puts "Public key added for '#{pub_key_record.cas_user.cas_directory_id}'"
  end

  # Returns the CasUser associated with the given cas_directory, or exits
  # if the cas_directory_id cannot be found.
  def retrieve_cas_user(cas_directory_id)
    cas_user = CasUser.find_by(cas_directory_id: cas_directory_id)
    return cas_user if cas_user

    puts "User '#{cas_directory_id}' does not exist!"
    exit(1)
  end

  # Exits if the public key already exists in the database.
  def verify_public_key(public_key)
    public_key_record = PublicKey.find_by(key: public_key)
    return unless public_key_record

    puts "Public key already exists and belongs to '#{public_key_record.cas_user.cas_directory_id}'"
    exit(1)
  end
end
