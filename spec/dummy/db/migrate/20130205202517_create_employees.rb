class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.string :first_name
      t.string :last_name
      t.string :title
      t.references :company

      t.timestamps
    end
    add_index :employees, :company_id
  end
end
