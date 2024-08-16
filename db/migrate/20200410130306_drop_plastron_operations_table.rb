class DropPlastronOperationsTable < ActiveRecord::Migration[5.2]
  def up
    drop_table :plastron_operations
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
