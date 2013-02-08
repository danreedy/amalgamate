class AddPubliclyTradedToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :publicly_traded, :boolean
  end
end
