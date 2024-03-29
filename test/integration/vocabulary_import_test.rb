# frozen_string_literal: true

require 'test_helper'

# Integration test for vocabulary import functionality
class VocabularyImportTest < ActiveSupport::TestCase
  def setup
    Archelon::Application.load_tasks
    # Need to reenable Rake tasks for each task, as otherwise once it's run it
    # will remember the arguments
    Rake::Task['vocab:import'].reenable
    # Turn off any console output from the Rake task
    IO.any_instance.stub(:puts)
  end

  test 'successful import' do
    Rake::Task['vocab:import'].invoke('test/data/collections.csv', 'collections')
    vocab = Vocabulary.find_by(identifier: 'collections')
    assert_equal 100, vocab.term_count
  end

  test 'fail with missing args' do
    e = assert_raises(RuntimeError) do
      Rake::Task['vocab:import'].invoke
    end
    assert_match(/Usage:/, e.message)
  end

  test 'fail on bad column names' do
    e = assert_raises(RuntimeError) do
      Rake::Task['vocab:import'].invoke('test/data/collections-bad_columns.csv', 'collections2')
    end
    assert_match(/Required columns are:/, e.message)
  end

  test 'skip invalid rows' do
    Rake::Task['vocab:import'].invoke('test/data/collections-bad_rows.csv', 'collections3')
    vocab = Vocabulary.find_by(identifier: 'collections3')
    assert_equal 0, vocab.term_count
  end
end
