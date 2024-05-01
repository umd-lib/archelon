# frozen_string_literal: true

require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper
  include ResourceHelper

  def setup # rubocop:disable Metrics/MethodLength
    ENV['HANDLE_HTTP_PROXY_BASE'] = 'https://hdl.handle.net/'

    @item_content_model = CONTENT_MODELS[:Item]

    @sample_items = {
      'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643' => {
        'http://fedora.info/definitions/v4/repository#created' => [{ '@value' => '2024-04-26T13:10:24.331Z', '@type' => 'http://www.w3.org/2001/XMLSchema#dateTime' }],
        'http://purl.org/dc/terms/rights' => [{ '@id' => 'http://vocab.lib.umd.edu/rightsStatement#InC-NC' }],
        'http://www.iana.org/assignments/relation/last' => [{ '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643/x/brC8J_6K' }],
        'http://pcdm.org/models#hasMember' => [{ '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643/m/AMXxF4CM' }],
        'http://www.w3.org/ns/ldp#contains' => [{ '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643/m' }, { '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643/x' }],
        'http://www.europeana.eu/schemas/edm/hasType' => [{ '@id' => 'http://vocab.lib.umd.edu/form#photographs' }],
        '@type' => ['http://fedora.info/definitions/v4/repository#Resource', 'http://www.w3.org/ns/ldp#RDFSource', 'http://fedora.info/definitions/v4/repository#Container', 'http://vocab.lib.umd.edu/access#Campus', 'http://vocab.lib.umd.edu/access#Published', 'http://pcdm.org/models#Object', 'http://vocab.lib.umd.edu/model#Item', 'http://www.w3.org/ns/ldp#Container'],
        'http://fedora.info/definitions/v4/repository#lastModifiedBy' => [{ '@value' => 'plastron' }],
        'http://purl.org/dc/terms/identifier' => [{ '@value' => 'univarch-028986-0001' }, { '@value' => 'hdl:1903.1/1', '@type' => 'http://vocab.lib.umd.edu/datatype#handle' }, { '@value' => '2008-51', '@type' => 'http://vocab.lib.umd.edu/datatype#accessionNumber' }],
        'http://www.iana.org/assignments/relation/first' => [{ '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643/x/brC8J_6K' }],
        'http://purl.org/dc/terms/title' => [{ '@value' => 'Sample Title' }],
        'http://fedora.info/definitions/v4/repository#createdBy' => [{ '@value' => 'plastron' }],
        'http://purl.org/dc/terms/publisher' => [{ '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643#dc376873-0d58-462d-a3b7-5d22b42655fc' }],
        'http://purl.org/dc/terms/isPartOf' => [{ '@id' => 'http://vocab.lib.umd.edu/collection#0211-UA' }],
        'http://purl.org/dc/terms/creator' => [{ '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643#f003df99-400a-474e-a720-1d3596e068d0' }],
        'http://purl.org/dc/terms/bibliographicCitation' => [{ '@value' => 'Sample Bibliographic Citation' }],
        'http://fedora.info/definitions/v4/repository#hasParent' => [{ '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2' }],
        'http://purl.org/dc/elements/1.1/date' => [{ '@value' => '1994-11-23' }],
        'http://purl.org/dc/terms/rightsHolder' => [{ '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643#14982574-c1b4-4bb9-a94f-801a422b4637' }],
        'http://fedora.info/definitions/v4/repository#lastModified' => [{ '@value' => '2024-04-26T19:09:47.092Z', '@type' => 'http://www.w3.org/2001/XMLSchema#dateTime' }],
        'http://purl.org/dc/terms/type' => [{ '@id' => 'http://purl.org/dc/dcmitype/Image' }],
        'http://purl.org/dc/terms/subject' => [{ '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643#ef3035aa-85c1-45bf-b3a2-0047289942c6' }, { '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643#c9b313f2-82aa-485f-8f63-4e126cdfc5d3' }],
        'http://purl.org/dc/terms/description' => [{ '@value' => 'Sample Description' }],
        'http://pcdm.org/models#memberOf' => [{ '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2' }],
        'http://fedora.info/definitions/v4/repository#writable' => [{ '@value' => true }],

        'http://purl.org/dc/terms/alternative' => [{ '@value' => 'Sample Alternate Title', '@language' => 'en' }],
        'http://purl.org/dc/terms/contributor' => [{ '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643#492870b8-525c-4308-9e42-7aa6e974cbf0' }],
        'http://purl.org/dc/terms/spatial' => [{ '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643#4b959803-b739-4425-ae0b-68500e249fd8' }],
        'http://purl.org/dc/terms/extent' => [{ '@value' => 'Sample Extent', '@language' => 'en' }],
        'http://purl.org/dc/elements/1.1/language' => [{ '@value' => 'en' }],
        'http://www.openarchives.org/ore/terms/isAggregatedBy' => [{ '@id' => 'http://vocab.lib.umd.edu/set#test' }]
      },

      'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643#14982574-c1b4-4bb9-a94f-801a422b4637' => { 'http://www.w3.org/2000/01/rdf-schema#label' => [{ '@value' => 'Sample Rights Holder' }] },
      'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643#c9b313f2-82aa-485f-8f63-4e126cdfc5d3' => { 'http://www.w3.org/2000/01/rdf-schema#label' => [{ '@value' => 'Sample Subject 2' }] },
      'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643#dc376873-0d58-462d-a3b7-5d22b42655fc' => { 'http://www.w3.org/2000/01/rdf-schema#label' => [{ '@value' => 'Sample Publisher' }] },
      'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643#ef3035aa-85c1-45bf-b3a2-0047289942c6' => { 'http://www.w3.org/2000/01/rdf-schema#label' => [{ '@value' => 'Sample Subject 1' }] },
      'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643#f003df99-400a-474e-a720-1d3596e068d0' => { 'http://www.w3.org/2000/01/rdf-schema#label' => [{ '@value' => 'Sample Creator' }] },

      'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643#492870b8-525c-4308-9e42-7aa6e974cbf0' => { 'http://www.w3.org/2000/01/rdf-schema#label' => [{ '@value' => 'Sample Contributor', '@language' => 'en' }] },
      'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643#4b959803-b739-4425-ae0b-68500e249fd8' => { 'http://www.w3.org/2002/07/owl#sameAs' => [{ '@id' => 'http://sws.geonames.org/5000306' }], 'http://www.w3.org/2000/01/rdf-schema#label' => [{ '@value' => 'Sample Location', '@language' => 'en' }] }
    }

    @sample_item_id = 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643'
    @sample_item = @sample_items[@sample_item_id]

    @fields = {
      object_type: { name: 'object_type', uri: 'http://purl.org/dc/terms/type', label: 'Object Type', type: :ControlledURIRef },
      identifier: { name: 'identifier', uri: 'http://purl.org/dc/terms/identifier', label: 'Identifier', type: :TypedLiteral, repeatable: true },
      rights: { name: 'rights', uri: 'http://purl.org/dc/terms/rights', label: 'Rights Statement', type: :ControlledURIRef, vocab: 'rightsStatement' },
      title: { name: 'title', uri: 'http://purl.org/dc/terms/title', label: 'Title', type: :PlainLiteral, repeatable: true },
      access: { name: 'access', label: 'Access Level', type: :ControlledURIRef, vocab: 'access', terms: ['Public', 'Campus'] }, # rubocop:disable Style/WordArray
      format: { name: 'format', uri: 'http://www.europeana.eu/schemas/edm/hasType', label: 'Format', type: :ControlledURIRef, vocab: 'form', repeatable: true },
      creator: { name: 'creator', uri: 'http://purl.org/dc/terms/creator', label: 'Creator', type: :LabeledThing, repeatable: true },
      location: { name: 'location', uri: 'http://purl.org/dc/terms/spatial', label: 'Location', type: :LabeledThing, repeatable: true },
      handle: { name: 'handle', uri: 'http://purl.org/dc/terms/identifier', label: 'Handle', type: :TypedLiteral, datatype: 'http://vocab.lib.umd.edu/datatype#handle' }
    }
  end

  test 'display_node' do
    expected = [
      # object_type - :ControlledURIRef, no vocabulary
      [@fields[:object_type], '<a href="http://purl.org/dc/dcmitype/Image">http://purl.org/dc/dcmitype/Image</a>'],
      # identifier - :TypedLiteral
      [@fields[:identifier], '<span>univarch-028986-0001</span>'],
      # rights - :ControlledURIRef, "rightsStatement" vocabulary, "same as" entry
      [@fields[:rights], '<span>In Copyright - Non-Commercial Use Permitted</span> → <a href="http://rightsstatements.org/vocab/InC-NC/1.0/">http://rightsstatements.org/vocab/InC-NC/1.0/</a>'],
      # title - :PlainLiteral
      [@fields[:title], '<span>Sample Title</span>'],
      # access - :ControlledURIRef, "access" vocabulary, defined terms
      [@fields[:access], '<span>Campus</span>'],
      # format - :ControlledURIRef, "form" vocabulary
      [@fields[:format], '<span>Photographs</span> → <a href="http://id.loc.gov/authorities/genreForms/gf2017027249">http://id.loc.gov/authorities/genreForms/gf2017027249</a>'],
      # creator - :LabeledThing
      [@fields[:creator], '<span><span>Sample Creator</span></span>'],
      # location - :LabeledThing, "same as" entry
      [@fields[:location], '<span>Sample Location</span> <span class="badge badge-light" style="background: #ddd; color: #333">en</span> → <a href="http://sws.geonames.org/5000306">http://sws.geonames.org/5000306</a>'],
      # handle - :TypedLiteral, "datatype" entry
      [@fields[:handle], '<span>1903.1/1</span> - <a href="https://hdl.handle.net/1903.1/1">https://hdl.handle.net/1903.1/1</a>']
    ]

    expected.each do |expect|
      field, expected_value = *expect

      stub_vocabulary_server(field)
      item_values = get_item_values(field, @sample_item)

      node = item_values.first
      assert_equal expected_value, display_node(node, field, @sample_items), "Unexpected value returned for '#{field[:name]}' field"
    end
  end

  test 'display_handle when HANDLE_HTTP_PROXY_BASE is empty' do
    item_values = get_item_values(@fields[:handle], @sample_item)
    node = item_values.first
    ENV['HANDLE_HTTP_PROXY_BASE'] = ''

    content = display_handle(node)
    expected = '<span>1903.1/1</span>'
    assert_equal expected, content
  end

  test 'display_handle when HANDLE_HTTP_PROXY_BASE is populated' do
    item_values = get_item_values(@fields[:handle], @sample_item)
    node = item_values.first
    ENV['HANDLE_HTTP_PROXY_BASE'] = 'https://hdl.handle.net/'

    content = display_handle(node)
    expected = '<span>1903.1/1</span> - <a href="https://hdl.handle.net/1903.1/1">https://hdl.handle.net/1903.1/1</a>'
    assert_equal expected, content
  end

  # Helper methods

  # Stubs the call to the vocabulary server, if used by the field.
  # Replaces the call by retrieving the appropriate vocabulary fixture file.
  def stub_vocabulary_server(field)
    return unless field[:vocab]

    # Stub the call to the vocabulary server, using a sample vocabulary
    # from the file fixtures instead.
    json_fixture_file = "sample_vocabularies/#{field[:vocab]}.json"
    stub_request(:get, /.*/)
      .to_return(status: 200, body: file_fixture(json_fixture_file).read, headers: {})
  end

  # Return the actual values from the item for the given field.
  # This method duplicates the logic in the
  # "app/views/catalog/_show_default.html.erb" file
  def get_item_values(field, item) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    if field[:name] == 'access'
      vocab = VocabularyService.get_vocabulary(field[:vocab])
      if field.key? :terms # rubocop:disable Style/ConditionalAssignment
        terms = field[:terms].map { |term| vocab.uri + term }
      else
        terms = vocab.terms.map { |term| term.uri } # rubocop:disable Style/SymbolProc
      end

      item_values = item.fetch('@type', []).select { |uri| terms.include? uri }.map { |uri| { '@id' => uri } }
    else
      item_values = get_field_values(item, field)
    end
    item_values
  end
end
