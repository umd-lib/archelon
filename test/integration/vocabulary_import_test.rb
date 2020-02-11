# frozen_string_literal: true

require 'test_helper'

# Integration test for vocabulary import functionality
class VocabularyImportTest < ActiveSupport::TestCase
  def setup
    Archelon::Application.load_tasks
  end

  test 'successful import' do
    Rake::Task['vocab:import'].invoke('test/data/collections.csv', 'collections')
    vocab = Vocabulary.find_by(identifier: 'collections')
    assert_equal 100, vocab.term_count
  end

  test 'fail with missing args' do
    Rake::Task['vocab:import'].invoke
  rescue RuntimeError => e
    assert_match(/Usage:/, e.message)
  end

  test 'fail on bad column names' do
    Rake::Task['vocab:import'].invoke('test/data/collections-bad_columns.csv', 'collections2')
  rescue RuntimeError => e
    assert_match(/Required columns are:/, e.message)
  end
end
