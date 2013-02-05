class Employee < ActiveRecord::Base
  belongs_to :company
  attr_accessible :first_name, :last_name, :title, :company_id
end
