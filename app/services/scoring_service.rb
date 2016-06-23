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
      player.running_total += frame.score
    end
    player.save
    player.running_total
  end

  def update_previous_frames
    frames = find_frames_to_update
    frames.each do |frame|
      if frame == previous_frame && frame.strike?
        score_strike!(frame)
      elsif frame == previous_frame && frame.spare?
        score_spare!(frame)
      elsif frame == two_frames_ago? && frame.strike?
        score_strike!(frame)
      end
      frame.save
      frame.reload
    end
  end

  def score_final_frame
    if current_frame.first_roll?
      current_frame.score = current_frame.roll_one_val
    elsif current_frame.second_roll?
      current_frame.score += current_frame.roll_two_val
    elsif current_frame.third_roll?
      current_frame.score += current_frame.roll_three_val
    end
    current_frame.save
  end

  def score_bonus_roll
    current_frame.score += current_frame.roll_three_val      
    current_frame.status = "closed"
    current_frame.save
  end

  def find_frames_to_update
    player.frames.where(status: "pending")
  end

  def previous_frame
    Frame.find_by(frame_number: current_frame.frame_number - 1)
  end

  def two_frames_ago?
    Frame.find_by(frame_number: current_frame.frame_number - 2)
  end

  def score_spare!(frame)
    frame.score += current_frame.roll_one_val
    frame.status = "closed"
    frame.save
  end

  def score_strike!(frame)
    if current_frame.open?
      frame.score += current_frame.roll_one_val
    elsif current_frame.closed? || (current_frame.roll_two_val && current_frame.spare?)
      frame.score += current_frame.roll_two_val
      frame.status = "closed"
    elsif current_frame.pending? && current_frame.strike? && frame == two_frames_ago?
      frame.score += current_frame.roll_one_val
      frame.status = "closed"
    else
      frame.score += current_frame.roll_one_val  
    end
  end
end
