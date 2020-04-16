VOCAB_CONFIG = Archelon::Application.config_for :vocabularies

ACCESS_VOCAB = Vocabulary.find_by identifier: VOCAB_CONFIG['access_vocab_identifier']
