['all', Rails.env].each do |seed|
  seed_file = "#{Rails.root}/db/seeds/#{seed}.rb"
  next unless File.exist?(seed_file)

  # rubocop:disable Rails/Output
  puts "*** Loading #{seed} seed data"
  # rubocop:enable Rails/Output
  require seed_file
end
