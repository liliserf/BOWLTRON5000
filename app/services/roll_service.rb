class RollService

  attr_accessor :player, :pins_down, :frame

  # Initializes with Player object, number of pins down, and current frame
  def initialize(player:, pins_down:, frame:)
    @player = player
    @pins_down = pins_down
    @frame = frame
  end

  # Checks if the roll is valid in the context of the current frame.
  # updates roll value
  # calls the Scoring Service
  def add_roll!
    return invalid_pins unless valid_roll?
    update_roll_value
    update_score!
  end

  private

  # If it's the final frame, goes to special roll assignment logic.
  # 
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

  # If this is the first roll of the final frame:
  # Set the roll value to pins_down
  #   If it's a strike, set the status of the frame to pending
  # 
  # If this is the second roll of the final frame:
  # Set the roll value to pins down
  #   If it's a spare, set the status of the frame to pending
  #   If it's not a spare, set frame status to closed
  # 
  # If it's the bonus roll:
  # Add the third roll to number of pins down
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

  # Convenience check for strike or spare
  def strike_or_spare?
    frame.spare? || frame.strike?
  end

  # Convenience method to change status to closed
  def finalize_frame!
    frame.update_attributes(status: "closed")
  end

  # Convenience method to change status to pending
  def set_frame_to_pending!
    frame.update_attributes(status: "pending")
  end

  # Checks for valid roll within context of frame
  # True if this is the first roll and standard valid roll
  # True if this is the second roll and if the first two rolls combined do not exceed 10 points
  # True if it's the bonus roll of the final frame
  # Otherwise, false
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

  # Output for invalid roll
  def invalid_pins
    { errors: "invalid pins" } 
  end

  # Creates the scoring service to score the current and previous frames
  def update_score!
    scoring_svc = ScoringService.new(player)
    scoring_svc.score!
  end
end