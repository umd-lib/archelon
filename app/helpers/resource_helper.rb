# frozen_string_literal: true

module ResourceHelper
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def define_react_components(fields, item, uri)
    fields.map do |field|
      component_type = field[:repeatable] ? 'Repeatable' : field[:type]
      values = item[field[:uri]]
      component_args = {
        # this will group fields by their subject ...
        paramPrefix: uri,
        # ... and key them by their predicate
        name: field[:uri]
      }.tap do |args|
        if field[:repeatable]
          args[:values] = values
        else
          # TODO: what do we do when there is more than value in a non-repeatable field?
          args[:value] = values ? (values[0] || {}) : {}
        end

        # special case for access level
        if field[:name] == 'access'
          access_vocab = Vocabulary['access']
          types = item['@type']
          values = types.select { |type_uri| access_vocab.key? type_uri }
          args[:value] = { '@id' => values[0] }
          args[:name] = field[:name]
        end

        args[:vocab] = (Vocabulary[field[:vocab]] || {}) if field[:vocab].present?
        args[:componentType] = field[:type] if field[:repeatable]
      end
      [field[:label], component_type, component_args]
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
