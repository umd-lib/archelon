# frozen_string_literal: true

module ResourceHelper
  def define_react_components(fields, item) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    fields.map do |field|
      component_type = field[:repeatable] ? 'Repeatable' : field[:type]
      component_args = { paramPrefix: 'resource', name: field[:name] }.tap do |args|
        if field[:repeatable]
          args[:values] = transform(item[field[:name]])
        else
          transform(item[field[:name]]).each { |arg| args.merge!(arg) }
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
