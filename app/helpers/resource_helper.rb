# frozen_string_literal: true

module ResourceHelper
  def define_react_components(fields, item, uri) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
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
          values = types.select { |uri| access_vocab.key? uri }
          args[:value] = { '@id' => values[0] }
          args[:name] = field[:name]
        end

        args[:vocab] = (Vocabulary[field[:vocab]] || {}) if field[:vocab].present?
        args[:componentType] = field[:type] if field[:repeatable]
      end
      [field[:label], component_type, component_args]
    end
  end

  def transform(value)
    if value.is_a? Array
      value.map(&:transform_compact)
    else
      [transform_compact(value)]
    end
  end

  def transform_compact(value)
    if value.is_a? Hash
      transform_for_react(value)
    else
      # literal, no language or type
      { value: value }
    end
  end

  def transform_for_react(obj)
    if obj.key? '@value'
      # literal
      { value: obj['@value'] }.tap do |new_obj|
        new_obj[:language] = obj['@language'] if obj.key?('@language')
        new_obj[:datatype] = obj['@type'] if obj.key?('@type')
      end
    elsif obj.key? '@id'
      # URI
      { value: obj['@id'] }
    end
  end
end
