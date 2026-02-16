# frozen_string_literal: true

class DropMascots < ActiveRecord::Migration[8.0]
  def up
    drop_table :mascots, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
