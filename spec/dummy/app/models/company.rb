class Company < ActiveRecord::Base
  has_many :employees

  attr_accessible :name, :slogan
  validates :name, presence: true

end
