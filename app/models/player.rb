class Player < ActiveRecord::Base
  belongs_to :game
  has_many :frames

  validates :frames, length: { maximum: 10}
end
