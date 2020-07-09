# frozen_string_literal: true

# Content model definitions
module ContentModels # rubocop:disable Metrics/ModuleLength
  ITEM = {
    required: [
      {
        name: 'object_type',
        uri: 'http://purl.org/dc/terms/type',
        label: 'Object Type',
        type: :ControlledURIRef
      },
      {
        name: 'identifier',
        uri: 'http://purl.org/dc/terms/identifier',
        label: 'Identifier',
        type: :TypedLiteral,
        repeatable: true
      },
      {
        name: 'rights',
        uri: 'http://purl.org/dc/terms/rights',
        label: 'Rights Statement',
        type: :ControlledURIRef,
        vocab: 'rights'
      },
      {
        name: 'title',
        uri: 'http://purl.org/dc/terms/title',
        label: 'Title',
        type: :PlainLiteral,
        repeatable: true
      },
      {
        name: 'access',
        label: 'Access Level',
        type: :ControlledURIRef,
        vocab: 'access'
      }
    ],
    recommended: [
      {
        name: 'format',
        uri: 'http://www.europeana.eu/schemas/edm/hasType',
        label: 'Format',
        type: :ControlledURIRef,
        vocab: 'form',
        repeatable: true
      },
      {
        name: 'archival_collection',
        uri: 'http://purl.org/dc/terms/isPartOf',
        label: 'Archival Collection',
        type: :ControlledURIRef,
        vocab: 'collection'
      },
      {
        name: 'date',
        uri: 'http://purl.org/dc/elements/1.1/date',
        label: 'Date',
        type: :TypedLiteral
      },
      {
        name: 'description',
        uri: 'http://purl.org/dc/terms/description',
        label: 'Description',
        type: :PlainLiteral
      }
    ],
    optional: [
      {
        name: 'alternate_title',
        uri: 'http://purl.org/dc/terms/alternative',
        label: 'Alternate Title',
        type: :PlainLiteral,
        repeatable: true
      },
      {
        name: 'creator',
        uri: 'http://purl.org/dc/terms/creator',
        label: 'Creator',
        type: :LabeledThing,
        repeatable: true
      },
      {
        name: 'contributor',
        uri: 'http://purl.org/dc/terms/contributor',
        label: 'Contributor',
        type: :LabeledThing,
        repeatable: true
      },
      {
        name: 'publisher',
        uri: 'http://purl.org/dc/terms/publisher',
        label: 'Publisher',
        type: :LabeledThing,
        repeatable: true
      },
      {
        name: 'location',
        uri: 'http://purl.org/dc/terms/spatial',
        label: 'Location',
        type: :LabeledThing,
        repeatable: true
      },
      {
        name: 'extent',
        uri: 'http://purl.org/dc/terms/extent',
        label: 'Extent',
        type: :PlainLiteral,
        repeatable: true
      },
      {
        name: 'subject',
        uri: 'http://purl.org/dc/terms/subject',
        label: 'Subject',
        type: :LabeledThing,
        repeatable: true
      },
      {
        name: 'language',
        uri: 'http://purl.org/dc/elements/1.1/language',
        label: 'Language',
        type: :TypedLiteral,
        repeatable: true
      },
      {
        name: 'rights_holder',
        uri: 'http://purl.org/dc/terms/rightsHolder',
        label: 'Rights Holder',
        type: :LabeledThing,
        repeatable: true
      },
      {
        name: 'bibliographic_citation',
        uri: 'http://purl.org/dc/terms/bibliographicCitation',
        label: 'Collection Information',
        type: :PlainLiteral
      },
      {
        name: 'accession_number',
        uri: 'http://purl.org/dc/terms/identifier',
        label: 'Accession Number',
        type: :TypedLiteral
      }
    ]
  }.freeze

  LABELED_THING = {
    required: [
      {
        name: 'Label',
        uri: 'http://www.w3.org/2000/01/rdf-schema#label',
        label: 'Label',
        type: :PlainLiteral
      },
      {
        name: 'same_as',
        uri: 'http://www.w3.org/2002/07/owl#sameAs',
        label: 'URI',
        type: :URIRef
      }
    ]
  }.freeze

  LETTER = {
    required: [
      {
        name: 'identifier',
        uri: 'http://purl.org/dc/terms/identifier',
        label: 'Identifier',
        type: :TypedLiteral,
        repeatable: true
      },
      {
        name: 'rights',
        uri: 'http://purl.org/dc/terms/rights',
        label: 'Rights Statement',
        type: :URIRef
      },
      {
        name: 'title',
        uri: 'http://purl.org/dc/terms/title',
        label: 'Title',
        type: :PlainLiteral
      },
      {
        name: 'access',
        label: 'Access Level',
        type: :ControlledURIRef,
        vocab: 'access'
      },
      {
        name: 'type',
        uri: 'http://www.europeana.eu/schemas/edm/hasType',
        label: 'Resource Type',
        type: :PlainLiteral
      },
      {
        name: 'part_of',
        uri: 'http://purl.org/dc/terms/isPartOf',
        label: 'Archival Collection',
        type: :LabeledThing
      },
      {
        name: 'date',
        uri: 'http://purl.org/dc/elements/1.1/date',
        label: 'Date',
        type: :TypedLiteral
      },
      {
        name: 'description',
        uri: 'http://purl.org/dc/terms/description',
        label: 'Description',
        type: :PlainLiteral
      },
      {
        name: 'author',
        uri: 'http://id.loc.gov/vocabulary/relators/aut',
        label: 'Author',
        type: :LabeledThing,
        repeatable: true
      },
      {
        name: 'recipient',
        uri: 'http://purl.org/ontology/bibo/recipient',
        label: 'Recipient',
        type: :LabeledThing,
        repeatable: true
      },
      {
        name: 'place',
        uri: 'http://purl.org/dc/terms/spatial',
        label: 'Location',
        type: :LabeledThing
      },
      {
        name: 'extent',
        uri: 'http://purl.org/dc/terms/extent',
        label: 'Extent',
        type: :PlainLiteral
      },
      {
        name: 'subject',
        uri: 'http://purl.org/dc/terms/subject',
        label: 'Subject',
        type: :LabeledThing
      },
      {
        name: 'language',
        uri: 'http://purl.org/dc/elements/1.1/language',
        label: 'Language',
        type: :TypedLiteral
      },
      {
        name: 'rights_holder',
        uri: 'http://purl.org/dc/terms/rightsHolder',
        label: 'Rights Holder',
        type: :PlainLiteral
      },
      {
        name: 'bibliographic_citation',
        uri: 'http://purl.org/dc/terms/bibliographicCitation',
        label: 'Collection Information',
        type: :PlainLiteral
      }
    ],
    recommended: [],
    optional: []
  }.freeze

  POSTER = {
    required: [
      {
        name: 'identifier',
        uri: 'http://purl.org/dc/terms/identifier',
        label: 'Identifier',
        type: :TypedLiteral
      },
      {
        name: 'rights',
        uri: 'http://purl.org/dc/terms/rights',
        label: 'Rights Statement',
        type: :URIRef
      },
      {
        name: 'title',
        uri: 'http://purl.org/dc/terms/title',
        label: 'Title',
        type: :PlainLiteral,
        repeatable: true
      },
      {
        name: 'access',
        label: 'Access Level',
        type: :ControlledURIRef,
        vocab: 'access'
      },
      {
        name: 'format',
        uri: 'http://purl.org/dc/elements/1.1/format',
        label: 'Resource Type',
        type: :PlainLiteral
      },
      {
        name: 'part_of',
        uri: 'http://purl.org/dc/terms/isPartOf',
        label: 'Collection',
        type: :PlainLiteral,
        repeatable: true
      },
      {
        name: 'publisher',
        uri: 'http://purl.org/dc/elements/1.1/publisher',
        label: 'Publisher',
        type: :PlainLiteral,
        repeatable: true
      },
      {
        name: 'date',
        uri: 'http://purl.org/dc/elements/1.1/date',
        label: 'Date',
        type: :TypedLiteral
      },
      {
        name: 'description',
        uri: 'http://purl.org/dc/terms/description',
        label: 'Description',
        type: :PlainLiteral
      },
      {
        name: 'location',
        uri: 'http://purl.org/dc/elements/1.1/coverage',
        label: 'Location',
        type: :PlainLiteral,
        repeatable: true
      },
      {
        name: 'latitude',
        uri: 'http://www.w3.org/2003/01/geo/wgs84_pos#lat',
        label: 'Latitude',
        type: :TypedLiteral
      },
      {
        name: 'longitude',
        uri: 'http://www.w3.org/2003/01/geo/wgs84_pos#long',
        label: 'Longitude',
        type: :TypedLiteral
      },
      {
        name: 'extent',
        uri: 'http://purl.org/dc/terms/extent',
        label: 'Extent',
        type: :PlainLiteral
      },
      {
        name: 'subject',
        uri: 'http://purl.org/dc/elements/1.1/subject',
        label: 'Subject',
        type: :PlainLiteral
      },
      {
        name: 'language',
        uri: 'http://purl.org/dc/elements/1.1/language',
        label: 'Language',
        type: :TypedLiteral
      },
      {
        name: 'locator',
        uri: 'http://purl.org/ontology/bibo/locator',
        label: 'Identifier/Call Number',
        type: :TypedLiteral
      },
      {
        name: 'issue',
        uri: 'http://purl.org/ontology/bibo/issue',
        label: 'Issue',
        type: :TypedLiteral
      }
    ],
    recommended: [],
    optional: [
      {
        name: 'alternate_title',
        uri: 'http://purl.org/dc/terms/alternative',
        label: 'Alternate Title',
        type: :PlainLiteral,
        repeatable: true
      }
    ]

  }.freeze

  NEWSPAPER = {
    required: [
      {
        name: 'title',
        uri: 'http://purl.org/dc/terms/title',
        label: 'Title',
        type: :PlainLiteral,
        repeatable: true
      },
      {
        name: 'access',
        label: 'Access Level',
        type: :ControlledURIRef,
        vocab: 'access'
      },
      {
        name: 'date',
        uri: 'http://purl.org/dc/elements/1.1/date',
        label: 'Date',
        type: :TypedLiteral
      },
      {
        name: 'volume',
        uri: 'http://purl.org/ontology/bibo/volume',
        label: 'Volume',
        type: :TypedLiteral
      },
      {
        name: 'issue',
        uri: 'http://purl.org/ontology/bibo/issue',
        label: 'Issue',
        type: :TypedLiteral
      },
      {
        name: 'edition',
        uri: 'http://purl.org/ontology/bibo/edition',
        label: 'Edition',
        type: :TypedLiteral
      }
    ],
    recommended: [],
    optional: []
  }.freeze
end
