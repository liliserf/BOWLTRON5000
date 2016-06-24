class RollService

  attr_accessor :player, :pins_down, :frame

  def initialize(player:, pins_down:, frame:)
    @player = player
    @pins_down = pins_down
    @frame = frame
  end

  def add_roll!
    return invalid_pins unless valid_roll?
    update_roll_value
    update_score!
  end

  private

  # If roll_one_val is not assigned:
  # update roll_one_val with pins_down and set the frame status to pending
  # if the frame was a strike
  # 
  # If the frame exists and has a roll_one_val, but was not a strike and
  # does not have a roll_two_val:
  # update roll_two_val with pins_down and set the frame status to pending if
  # it was a spare, or closed if it was a regular frame
  # 
  # If the frame has a roll_one_val and a roll_two_val:
  # check if the frame earned a bonus roll. 
  #   if it did, assign pins down to roll_three_val and close frame
  # 
  # returns the updated Frame object
  def update_roll_value

    return assign_roll_values_for_final_frame if frame.frame_number == 10

    if !frame.roll_one_val
      frame.roll_one_val = pins_down
      set_frame_to_pending! if frame.strike?
    elsif frame.roll_one_val && !frame.strike? && !frame.roll_two_val
      frame.roll_two_val = pins_down
      frame.spare? ? set_frame_to_pending! : finalize_frame!
    end
    frame.save!
  end

  def assign_roll_values_for_final_frame
    if !frame.roll_one_val
      frame.roll_one_val = pins_down
      set_frame_to_pending! if frame.strike?
    elsif !frame.roll_two_val
      frame.roll_two_val = pins_down
      strike_or_spare? && frame.roll_two_val != 0 ? set_frame_to_pending! : finalize_frame!
    else frame.bonus_throw?
      frame.roll_three_val = pins_down
    end
    frame.save!
  end

  def strike_or_spare?
    frame.spare? || frame.strike?
  end

  def finalize_frame!
    frame.update_attributes(status: "closed")
  end

  def set_frame_to_pending!
    frame.update_attributes(status: "pending")
  end

  def valid_roll?
    if !frame.roll_one_val && pins_down <= 10 && pins_down >= 0
      return true
    elsif frame.roll_one_val && !frame.roll_two_val && pins_down <= 10 - frame.roll_one_val
      return true
    elsif frame.bonus_throw? || frame.frame_number == 10 && frame.roll_one_val && frame.roll_one_val <= 10
      return true
    else
      return false
    end
  end

  def invalid_pins
    { errors: "invalid pins" } 
  end

  def update_score!
    scoring_svc = ScoringService.new(player)
    scoring_svc.score!
  end
end