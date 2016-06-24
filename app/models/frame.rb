class Frame < ActiveRecord::Base
  belongs_to :player
  validates_associated :player

  # Predicates Methods

  # Checks whether or not a third roll is allowed in the final frame
  def bonus_throw?
    return false unless roll_one_val && roll_two_val
    frame_number == 10 && 
    roll_one_val + roll_two_val == 10
  end

  # Checks if the frame was a strike
  def strike?
    roll_one_val && roll_one_val == 10
  end

  # Checks if the frame was a spare
  def spare?
    return false unless roll_two_val
    roll_one_val + roll_two_val == 10
  end

  # Open status means that a frame is currently in play
  # And is not a spare or strike
  def open?
    status == "open"
  end

  # Closed status means the frame is completed with final scores tallied
  def closed?
    status == "closed"
  end

  # Pending status means the frame was a strike or spare and is waiting on 
  # a final score count
  def pending?
    status == "pending"
  end
end
