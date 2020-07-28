# frozen_string_literal: true

module ResourceHelper
  def define_react_components(fields, items, uri) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    item = items[uri]
    fields.map do |field|
      component_type = :Repeatable
      values = item[field[:uri]]
      component_args = {
        name: field[:name],
        # this will group fields by their subject ...
        subjectURI: uri,
        # ... and key them by their predicate
        predicateURI: field[:uri],
        componentType: field[:type],
        values: values
      }.tap do |args|
        args[:maxValues] = 1 unless field[:repeatable]
        args[:vocab] = Vocabulary[field[:vocab]] if field[:vocab].present?

        # special handling for LabeledThing fields
        if field[:type] == :LabeledThing
          args[:values] = values&.map do |value|
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

    { value: value }.tap do |result|
      result[:label] = obj[LABEL_PREDICATE]&.first if obj[LABEL_PREDICATE]&.first
      result[:sameAs] = obj[SAME_AS_PREDICATE]&.first if obj[SAME_AS_PREDICATE]&.first
    end
  end

  def configure_access_level(args, item)
    args[:values] = item.fetch('@type', []).select { |uri| args[:vocab].key? uri }.map { |uri| { '@id' => uri } }
    args[:predicateURI] = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
  end
end
