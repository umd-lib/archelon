# frozen_string_literal: true

# Utility class for creating STOMP messages of various types

def create_stomp_message_with_no_errors(resource_id)
  stomp_message = Stomp::Message.new('')
  stomp_message.headers = {
    PlastronJobId: 'SYNCHRONOUS-435eba11-3287-4f98-9225-afe50dfcc685',
    PlastronJobState: 'update_complete'
  }
  stomp_message.body =
    "{\"type\": \"update_complete\", \"stats\": {\"updated\": [\"#{resource_id}\"], \"invalid\": {}, \"errors\": {}}}"

  stomp_message
end

def create_stomp_message_with_validation_error(resource_id)
  stomp_message = Stomp::Message.new('')
  stomp_message.headers = {
    PlastronJobId: 'SYNCHRONOUS-889ad310-f796-43f2-8608-be3b56907414',
    PlastronJobState: 'update_incomplete'
  }
  stomp_message.body =
    "{\"type\": \"update_incomplete\", \"stats\": {\"updated\": [], \"invalid\": {\"#{resource_id}\": [\"('title', 'failed', 'required', True)\"]}, \"errors\": {}}}"

  stomp_message
end

def create_stomp_message_with_other_error(resource_id)
  stomp_message = Stomp::Message.new('')
  stomp_message.headers = {
    PlastronJobId: 'SYNCHRONOUS-889ad310-f796-43f2-8608-be3b56907414',
    PlastronJobState: 'update_incomplete'
  }
  stomp_message.body =
    "{\"type\": \"update_incomplete\", \"stats\": {\"updated\": [], \"invalid\": {}, \"errors\": {\"#{resource_id}\": \"Some other error\"}}}"

  stomp_message
end
