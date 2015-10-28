class CreateDogs < ActiveRecord::Migration
  def change
    create_table :dogs do |t|
      t.string :name
      t.string :breed
      t.timestamps
      t.deleted_at, :datetime
    end
    add_index :dogs, :deleted_at
  end
end
