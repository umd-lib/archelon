# frozen_string_literal: true

module ResourceHelper
  # generate a lookup hash of (predicate, datatype) => fieldname
  def uri_to_fieldname(fields)
    Hash[fields.map { |field| [[field[:uri], field[:datatype]], field[:name]] }]
  end

  def get_field_values(fields, item, predicate_uri)
    # for fields with a particular datatype, check the value type as well as the predicate URI
    (item[predicate_uri] || []).select do |value|
      uri_to_fieldname(fields).include?([predicate_uri, value['@type']])
    end
  end

  def define_react_components(fields, items, uri) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    item = items[uri]
    fields.map do |field|
      component_type = :Repeatable
      component_args = {
        name: field[:name],
        # this will group fields by their subject ...
        subjectURI: uri,
        # ... and key them by their predicate
        predicateURI: field[:uri],
        componentType: field[:type],
        values: get_field_values(fields, item, field[:uri])
      }.tap do |args|
        args[:maxValues] = 1 unless field[:repeatable]
        args[:vocab] = Vocabulary[field[:vocab]] if field[:vocab].present?

        # special handling for LabeledThing fields
        if field[:type] == :LabeledThing
          args[:values] = args[:values]&.map do |value|
            get_labeled_thing_value(value, items)
          end
        end

        # special handling for the access level field
        configure_access_level(args, item) if field[:name] == 'access'
      end
      [field[:label], component_type, component_args]
    end
  end

  def get_labeled_thing_value(value, items)
    target_uri = value.fetch('@id', nil)
    return value unless target_uri

    obj = items[target_uri]
    label = obj&.fetch(LABEL_PREDICATE, nil)&.first
    same_as = obj&.fetch(SAME_AS_PREDICATE, nil)&.first

    { value: value }.tap do |v|
      v[:label] = label if label
      v[:sameAs] = same_as if same_as
    end
  end

  def configure_access_level(args, item)
    args[:values] = item.fetch('@type', []).select { |uri| args[:vocab].key? uri }.map { |uri| { '@id' => uri } }
    args[:predicateURI] = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
  end
end
