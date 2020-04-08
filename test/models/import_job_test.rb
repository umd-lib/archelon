# frozen_string_literal: true

require 'test_helper'

class ImportJobTest < ActiveSupport::TestCase
  test 'PlastronOperation is deleted when ImportJob is deleted' do
    import_job = import_jobs(:one)
    assert_not_nil(import_job.plastron_operation)

    assert_difference('ImportJob.count', -1) do
      assert_difference('PlastronOperation.count', -1) do
        import_job.destroy!
      end
    end
  end

  test 'ImportJob is not deleted when PlastronOperation is deleted' do
    # Not sure if this is really the desired behavior. Ordinarily would
    # expect a one-to-one relationship between ImportJob and it's
    # associated PlastronOperation, so that deleting one deletes the other.
    # Suspect it was done this way so that PlastronOperation would not
    # need to deal with polymorphism between ExportJob/ImportJob in
    # a "has_one" relationship.
    plastron_op = plastron_operations(:import_op1)

    assert_no_difference('ImportJob.count') do
      assert_difference('PlastronOperation.count', -1) do
        plastron_op.destroy!
      end
    end
  end
end
