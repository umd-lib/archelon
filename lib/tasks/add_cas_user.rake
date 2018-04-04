# lib/tasks/add_cas_user.rake
namespace :db do # rubocop: disable Metrics/BlockLength
  desc 'Add a casuser'
  task :add_cas_user, %i[cas_directory_id full_name] => :environment do |_t, args|
    cas_directory_id = args[:cas_directory_id]

    if !CasUser.find_by(cas_directory_id: cas_directory_id)
      CasUser.create!(cas_directory_id: args[:cas_directory_id], name: args[:full_name])
      puts "CasUser '#{cas_directory_id}' created!"
    else
      puts "CasUser '#{cas_directory_id}' already exists!"
    end
  end

  desc 'Add a casuser as admin'
  task :add_admin_cas_user, %i[cas_directory_id full_name] => :environment do |_t, args|
    cas_directory_id = args[:cas_directory_id]

    if !CasUser.find_by(cas_directory_id: cas_directory_id)
      CasUser.create!(cas_directory_id: args[:cas_directory_id], name: args[:full_name], admin: true)
      puts "CasUser '#{cas_directory_id}' created!"
    else
      puts "CasUser '#{cas_directory_id}' already exists!"
      unless CasUser.find_by(cas_directory_id: cas_directory_id).admin?
        user = CasUser.find_by(cas_directory_id: cas_directory_id)
        user.admin = true
        user.save
        puts 'Granted admin privilege!'
      end
    end
  end
end
