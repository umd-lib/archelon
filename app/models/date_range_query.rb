# frozen_string_literal: true

# date range query
class DateRangeQuery
  def initialize(begin_date, end_date)
    @begin_date = begin_date
    @end_date = end_date
  end

  def query
    @query ||=
      if @begin_date.present? && @end_date.present?
        "[#{@begin_date} TO #{@end_date}]"
      elsif @begin_date.present?
        @begin_date
      elsif @end_date.present?
        "[* TO #{@end_date}]"
      end
  end

  def fq(field_name, operation = 'Intersects')
    "{!field f=#{field_name} op=#{operation}}#{query}"
  end
end
