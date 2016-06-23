class Frame < ActiveRecord::Base
  belongs_to :player

  # Predicates

  def bonus_throw?
    return false unless roll_two
    frame_number == 10 && 
    roll_one + roll_two == 10
  end

  def strike?
    roll_one == 10
  end

  def spare?
    return false unless roll_two
    roll_one + roll_two == 10
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
