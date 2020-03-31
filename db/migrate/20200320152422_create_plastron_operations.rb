class CreatePlastronOperations < ActiveRecord::Migration[5.2]
  def change
    create_table :plastron_operations do |t|
      t.string :status
      t.integer :progress
      t.timestamp :started
      t.timestamp :completed
      t.string :request_message
      t.string :response_message

      t.timestamps
    end

    add_reference :export_jobs, :plastron_operation

    # bootstrap existing export jobs with (synthesized) Plastron operations
    ExportJob.where(plastron_operation_id: nil).find_each do |job|
      status = job.status == 'Ready' ? :done : job.status
      progress = job.status == 'Ready' ? 100 : 0
      job.plastron_operation = PlastronOperation.new.tap do |op|
        op.started = job.created_at
        op.completed = job.updated_at unless ['Pending', 'In Progress'].include? job.status
        op.status = status
        op.progress = progress
      end
      job.save!
    end
  end
end
