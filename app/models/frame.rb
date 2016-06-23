class Frame < ActiveRecord::Base
  belongs_to :player

  # Predicates

  def bonus_throw?
    return false unless roll_two_val
    frame_number == 10 && 
    roll_one_val + roll_two_val == 10
  end

  def strike?
    roll_one_val == 10
  end

  def spare?
    return false unless roll_two_val
    roll_one_val + roll_two_val == 10
  end

  def open?
    status == "open"
  end

  def closed?
    status == "closed"
  end

  def pending?
    status == "pending"
  end
end
