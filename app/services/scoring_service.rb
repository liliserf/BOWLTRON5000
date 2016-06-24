class ScoringService
  attr_accessor :player, :current_frame

  def initialize(player)
    @player = player
    @current_frame = player.frames.last
  end

  def score!
    score_current_frame
    update_previous_frames
    update_running_total
  end

  private

  # If the frame has just been completed with either 2 regular rolls or a spare
  # update the current_frame score to include roll_two_val.

  # If the current_frame does not yet have a roll_two_val, 
  # update the frame score with roll one
  def score_current_frame
    return score_final_frame if current_frame.frame_number == 10
    
    if current_frame.closed? || current_frame.spare?
      current_frame.score += current_frame.roll_two_val
    elsif !current_frame.roll_two_val
      current_frame.score = current_frame.roll_one_val
    end
    current_frame.save
  end

  def update_running_total
    player.running_total = 0
    player.frames.each do |frame|
      frame.reload
      player.running_total += frame.score
    end
    player.save
    player
  end

  def update_previous_frames
    frames = find_frames_to_update

    frames.each do |frame|
      if (frame.frame_number == previous_frame_number || two_frames_ago) && frame.strike?
        score_strike!(frame)
      elsif frame.frame_number == previous_frame_number && frame.spare?
        score_spare!(frame)
      end
      frame.save
    end
  end

  def score_final_frame
    if current_frame.roll_one_val && current_frame.score == 0
      current_frame.score = current_frame.roll_one_val
    elsif current_frame.roll_two_val && !current_frame.roll_three_val
      current_frame.score += current_frame.roll_two_val
    elsif current_frame.roll_three_val
      current_frame.score += current_frame.roll_three_val
      close(current_frame)
    end
    current_frame.save
  end

  def score_bonus_roll
    current_frame.score += current_frame.roll_three_val      
    close(current_frame)
    current_frame.save
  end

  def find_frames_to_update
    player.frames.where(status: "pending").where.not(id: current_frame.id)
  end

  def previous_frame_number
    current_frame.frame_number - 1
  end

  def two_frames_ago
    current_frame.frame_number - 2
  end

  def score_spare!(frame)
    frame.score += current_frame.roll_one_val
    close(frame)
    frame.save
  end

  # If the current frame is on the first roll:
  # Add the current roll score to the strike score

  # If the current frame is on the second roll:
  # Add the second roll to the strike frame's score and
  # Update the status to closed

  # If the current frame is a strike 2 frames ago was a strike:
  # Add the current roll_one_val to the pas strike

  # Else (if the current frame is a strike and the previous frame was a strike):
  # Add one to the previous frame score
  def score_strike!(frame)
    if current_frame.open?
      frame.score += current_frame.roll_one_val
      close(frame) if frame.frame_number == two_frames_ago
    elsif current_frame.closed? || (current_frame.roll_two_val && current_frame.spare?)
      frame.score += current_frame.roll_two_val
      close(frame)
    elsif current_frame.strike? && frame.frame_number == two_frames_ago
      frame.score += current_frame.roll_one_val
      close(frame)
    else
      frame.score += current_frame.roll_one_val  
    end
    frame.save
  end

  def close(frame)
    frame.status = "closed"
    frame.save
  end

end
