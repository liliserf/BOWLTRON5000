class Game < ActiveRecord::Base
  has_many :players

  accepts_nested_attributes_for :players, reject_if: proc { |attributes| attributes['name'].blank? }, limit: 6

  validates :players, presence: true
end
