# frozen_string_literal: true

require 'test_helper'

class ResourcerHelperTest < ActiveSupport::TestCase
  include ResourceHelper

  def setup # rubocop:disable Metrics/MethodLength
    @item = {
      'http://fedora.info/definitions/v4/repository#created' => [{ '@value' => '2024-04-26T13:10:24.331Z', '@type' => 'http://www.w3.org/2001/XMLSchema#dateTime' }],
      'http://purl.org/dc/terms/rights' => [{ '@id' => 'http://vocab.lib.umd.edu/rightsStatement#InC-NC' }],
      'http://www.iana.org/assignments/relation/last' => [{ '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643/x/brC8J_6K' }],
      'http://pcdm.org/models#hasMember' => [{ '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643/m/AMXxF4CM' }],
      'http://www.w3.org/ns/ldp#contains' => [{ '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643/m' }, { '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643/x' }],
      'http://www.europeana.eu/schemas/edm/hasType' => [{ '@id' => 'http://vocab.lib.umd.edu/form#photographs' }],
      '@type' => ['http://fedora.info/definitions/v4/repository#Resource', 'http://www.w3.org/ns/ldp#RDFSource', 'http://fedora.info/definitions/v4/repository#Container', 'http://vocab.lib.umd.edu/access#Published', 'http://pcdm.org/models#Object', 'http://vocab.lib.umd.edu/model#Item', 'http://www.w3.org/ns/ldp#Container'],
      'http://fedora.info/definitions/v4/repository#lastModifiedBy' => [{ '@value' => 'plastron' }],
      'http://purl.org/dc/terms/identifier' => [{ '@value' => 'univarch-028986-0001' }, { '@value' => 'hdl:1903.1/1', '@type' => 'http://vocab.lib.umd.edu/datatype#handle' }, { '@value' => '2008-51', '@type' => 'http://vocab.lib.umd.edu/datatype#accessionNumber' }],
      'http://www.iana.org/assignments/relation/first' => [{ '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643/x/brC8J_6K' }],
      'http://purl.org/dc/terms/title' => [{ '@value' => 'Angel Guerra (#42), Maryland Terrapin defensive back, against Tyrone Davis (#82), University of Virginia wide receiver' }],
      'http://fedora.info/definitions/v4/repository#createdBy' => [{ '@value' => 'plastron' }],
      'http://purl.org/dc/terms/publisher' => [{ '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643#dc376873-0d58-462d-a3b7-5d22b42655fc' }],
      'http://purl.org/dc/terms/isPartOf' => [{ '@id' => 'http://vocab.lib.umd.edu/collection#0211-UA' }],
      'http://purl.org/dc/terms/creator' => [{ '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643#f003df99-400a-474e-a720-1d3596e068d0' }],
      'http://purl.org/dc/terms/bibliographicCitation' => [{ '@value' => 'Diamondback Photos, Box 17, item 1439' }],
      'http://fedora.info/definitions/v4/repository#hasParent' => [{ '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2' }],
      'http://purl.org/dc/elements/1.1/date' => [{ '@value' => '1994-11-23' }],
      'http://purl.org/dc/terms/rightsHolder' => [{ '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643#14982574-c1b4-4bb9-a94f-801a422b4637' }],
      'http://purl.org/dc/terms/type' => [{ '@id' => 'http://purl.org/dc/dcmitype/Image' }],
      'http://purl.org/dc/terms/subject' => [{ '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643#ef3035aa-85c1-45bf-b3a2-0047289942c6' }, { '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2/37/3b/87/72/373b8772-881b-4f1f-91e2-8b6b4d04b643#c9b313f2-82aa-485f-8f63-4e126cdfc5d3' }],
      'http://fedora.info/definitions/v4/repository#lastModified' => [{ '@value' => '2024-04-26T13:40:09.436Z', '@type' => 'http://www.w3.org/2001/XMLSchema#dateTime' }],
      'http://purl.org/dc/terms/description' => [{ '@value' => 'The Diamondback Photo Morgue consists of images taken for the primary University of Maryland student newspaper, The Diamondback. Photographers took multiple shots at various campus events, athletic games, and of general campus life. Some images were printed in the newspaper, others were kept on file. This collection covers the period from the early 1970s to the late 1990s.' }],
      'http://pcdm.org/models#memberOf' => [{ '@id' => 'http://fcrepo-local:8080/fcrepo/rest/dc/2021/2' }],
      'http://fedora.info/definitions/v4/repository#writable' => [{ '@value' => true }]
    }
  end

  test 'get_field_values can distinguish values by datatype' do
    #  Fields have same predicate, but different (or nil) datatypes
    identifier_field = { name: 'identifier', uri: 'http://purl.org/dc/terms/identifier', label: 'Identifier', type: :TypedLiteral, repeatable: true }
    accession_field = { name: 'accession_number', uri: 'http://purl.org/dc/terms/identifier', label: 'Accession Number', type: :TypedLiteral, datatype: 'http://vocab.lib.umd.edu/datatype#accessionNumber' }
    handle_field = { name: 'handle', uri: 'http://purl.org/dc/terms/identifier', label: 'Handle', type: :TypedLiteral, datatype: 'http://vocab.lib.umd.edu/datatype#handle' }

    identifier_result = get_field_values(@item, identifier_field)
    expected = [{ '@value' => 'univarch-028986-0001' }]
    assert_equal expected, identifier_result

    accession_result = get_field_values(@item, accession_field)
    expected = [{ '@value' => '2008-51', '@type' => 'http://vocab.lib.umd.edu/datatype#accessionNumber' }]
    assert_equal expected, accession_result

    handle_result = get_field_values(@item, handle_field)
    expected = [{ '@value' => 'hdl:1903.1/1', '@type' => 'http://vocab.lib.umd.edu/datatype#handle' }]
    assert_equal expected, handle_result
  end
end
