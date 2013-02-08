class Headquarter < ActiveRecord::Base
  belongs_to :company
  attr_accessible :city
end
