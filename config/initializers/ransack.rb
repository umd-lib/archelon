Ransack.configure do |c|
  # See https://github.com/activerecord-hackery/ransack/pull/470/commits/c3a9110e24bdd20cb4f68b4bd5991d338326fa98
  c.search_key = 'rq'
end
