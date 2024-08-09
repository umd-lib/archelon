# frozen_string_literal: true

# Message used when there is an error communicating with Plastron
class PlastronExceptionMessage < PlastronMessage
  def initialize(exception_msg)
    @exception_msg = exception_msg
  end

  def ok?
    false
  end

  def parse_errors(_resource_id)
    [{ error: @exception_msg }]
  end
end
