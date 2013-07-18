class Company < ActiveRecord::Base
  has_many :employees, dependent: :destroy
  has_one :headquarter, dependent: :destroy

  validates :name, presence: true

end
