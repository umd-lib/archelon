# frozen_string_literal: true

# lib/tasks/sample_data.rake
namespace :db do # rubocop:disable Metrics/BlockLength
  desc 'Drop, create, migrate, seed and populate sample data'
  task reset_with_sample_data: %i[drop reset seed populate_sample_data] do
    puts 'Ready to go!'
  end

  desc 'Populates the database with sample data'
  task populate_sample_data: :environment do # rubocop:disable Metrics/BlockLength
    num_cas_users = 10
    num_cas_users.times do
      cas_user = CasUser.new
      cas_user.cas_directory_id = Faker::Internet.user_name
      cas_user.name = Faker::Name.name
      cas_user.user_type = Random.rand > 0.7 ? 'admin' : 'user'
      cas_user.save!
    end

    num_download_urls = 50
    cas_users = CasUser.limit(num_cas_users)
    num_download_urls.times do
      download_url = DownloadUrl.new
      download_url.url = Faker::Internet.url('example.com')
      download_url.title = Faker::File.file_name + ' - ' + Faker::Lorem.words(4).join
      download_url.notes = Faker::Lorem.paragraph(2)
      download_url.mime_type = Faker::File.mime_type
      download_url.creator = cas_users[Random.rand(num_cas_users)].cas_directory_id
      download_url.created_at = Faker::Time.between(14.days.ago, Time.zone.now)
      download_url.updated_at = Faker::Time.between(download_url.created_at, Time.zone.now)
      download_url.expires_at = download_url.created_at + 7.days
      download_url.enabled = true if Random.rand > 0.8
      unless download_url.enabled
        download_url.accessed_at = Faker::Time.between(download_url.created_at, Time.zone.now)
        download_url.download_completed_at = Faker::Time.between(download_url.accessed_at, Time.zone.now)
        download_url.request_ip = Faker::Internet.ip_v4_address
        download_url.request_user_agent = Faker::Internet.user_agent
        download_url.enabled = false
      end
      download_url.save!
    end

    num_export_jobs = 25
    num_export_jobs.times do
      cas_user = cas_users[Random.rand(num_cas_users)]
      timestamp = Faker::Time.between(14.days.ago, Time.zone.now)
      job_name = "#{cas_user.cas_directory_id}-#{timestamp.iso8601}"
      item_count = Random.rand(10)

      export_job = ExportJob.new
      export_job.name = job_name
      export_job.cas_user = cas_user
      export_job.timestamp = timestamp
      export_job.item_count = item_count
      export_job.format = 'CSV'
      export_job.progress = Random.rand(100) if export_job.stalled?
      export_job.save!
    end
  end
end
