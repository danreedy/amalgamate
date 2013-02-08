class CreateHeadquarters < ActiveRecord::Migration
  def change
    create_table :headquarters do |t|
      t.references :company
      t.string :city

      t.timestamps
    end
    add_index :headquarters, :company_id
  end
end
