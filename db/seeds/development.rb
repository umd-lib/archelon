# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# create a standard access vocabulary
access_vocab = Vocabulary.find_or_create_by identifier: 'access'
Type.find_or_create_by identifier: 'Public', vocabulary: access_vocab
Type.find_or_create_by identifier: 'Campus', vocabulary: access_vocab

# create a standard datatype vocabulary
datatype_vocab = Vocabulary.find_or_create_by identifier: 'datatype'
Datatype.find_or_create_by identifier: 'accessionNumber', vocabulary: datatype_vocab
