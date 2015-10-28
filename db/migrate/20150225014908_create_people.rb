class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :first_name
      t.string :last_name
      t.timestamps
      t.deleted_at, :datetime
    end
    add_index :people, :deleted_at
  end
end
