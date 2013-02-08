class Company < ActiveRecord::Base
  has_many :employees, dependent: :destroy
  has_one :headquarter, dependent: :destroy

  attr_accessible :name, :slogan
  validates :name, presence: true

end
