class ScoringService
  attr_accessor :player, :current_frame

  # Initializes with player object and finds the player's current frame
  def initialize(player)
    @player = player
    @current_frame = player.frames.last
  end

  # Scores the current frame.
  # Updates scores of previous pending frames.
  # Updates player's current running total
  # returns the player
  def score!
    score_current_frame
    update_previous_frames
    update_running_total
    return player
  end

  private

  # Go to special scoring logic if it's the final frame
  # 
  # If the frame has just been completed with either 2 regular rolls or a spare
  # update the current_frame score to include roll_two_val.
  # 
  # If the current_frame is still on the first roll,
  # update the frame score with roll one
  def score_current_frame
    current_frame.reload
    return score_final_frame if current_frame.frame_number == 10
    if current_frame.closed? || current_frame.spare?
      current_frame.score += current_frame.roll_two_val
    elsif !current_frame.roll_two_val
      current_frame.score = current_frame.roll_one_val
    end
    current_frame.save
  end

  # Updates a player's running total
  # Resets total to 0 to add up all currently scored frames
  # returns the player object
  def update_running_total
    player.running_total = 0
    player.frames.each do |frame|
      frame.reload
      player.running_total += frame.score
    end
    player if player.save
  end

  # Fetches the frames currently marked as pending from the previous frame and two frames ago
  # iterates through the frames to update the scores
  # 
  # If it's the 9th frame, and this is the bonus roll fo the final frame:
  # Close the frame without adding additional points.
  # 
  # If the previous frame or two frames ago was a strike
  # Update with the strike logic
  # 
  # If the previous frame was a spare
  # Update with spare scoring logic
  # And save the frame
  def update_previous_frames
    frames = find_frames_to_update

    frames.each do |frame|
      if frame.frame_number == 9 && current_frame.roll_three_val
        close!(frame)
      elsif (frame.frame_number == previous_frame_number || two_frames_ago) && frame.strike?
        score_strike!(frame)
      elsif frame.frame_number == previous_frame_number && frame.spare?
        score_spare!(frame)
      end
      frame.save
    end
  end

  # If the current frame is on the first roll:
  # Add the current roll score to the strike score

  # If the current frame is on the second roll:
  # Add the second roll to the strike frame's score and
  # Update the status to closed

  # If the current frame is a strike 2 frames ago was a strike:
  # Add the current roll_one_val to the past strike

  # Else (if the current frame is a strike and the previous frame was a strike):
  # Add one to the previous frame score
  def score_strike!(frame)
    if current_frame.open?
      frame.score += current_frame.roll_one_val
      close!(frame) if frame.frame_number == two_frames_ago
    elsif current_frame.closed? || (current_frame.roll_two_val && current_frame.spare?)
      frame.score += current_frame.roll_two_val
      close!(frame)
    elsif current_frame.strike? && frame.frame_number == two_frames_ago
      frame.score += current_frame.roll_one_val
      close!(frame)
    else
      frame.score += current_frame.roll_one_val  
    end
    frame.save
  end

  # If this is the first roll and has not been scored yet:
  # Add the first roll to the frame score.
  # 
  # If this is the second roll and has not been updated yet:
  # Add the second roll to the score
  # 
  # If this is the final roll and the previous rolls were a strike or spare:
  # Add the third roll to the score and close the frame
  def score_final_frame
    return game_complete if current_frame.closed?

    if current_frame.roll_one_val && current_frame.score == 0
      current_frame.score = current_frame.roll_one_val
    elsif current_frame.roll_two_val && !current_frame.roll_three_val
      current_frame.score += current_frame.roll_two_val
    elsif current_frame.roll_three_val && current_frame.pending?
      current_frame.score += current_frame.roll_three_val
      close!(current_frame)
    end
    current_frame.save
  end

  # Finds all frames that are pending aside from current frame
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
    close!(frame)
    frame.save
  end

  def close!(frame)  
    frame.status = "closed"
    frame.save
  end

  def game_complete
    { errors: { detail: "roll limit has been reached" } }
  end
end
