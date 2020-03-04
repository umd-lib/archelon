#json.extract! vocabulary, :id, :created_at, :updated_at
#json.url vocabulary_url(vocabulary, format: :json)

  json.set! '@id', vocabulary.uri
  json.set! '@graph', vocabulary.individuals do |i|
    json.set! '@id', i.uri
    json.label i.label
    json.sameAs i.same_as unless i.same_as.empty?
  end
