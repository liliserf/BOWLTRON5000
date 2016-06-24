class FrameService
  attr_accessor :player, :frame

  def initialize(player_id)
    @player = Player.find(player_id)
    @frame = Frame.new
  end

  def build!
    return frame_limit_error if frame_limit_reached
    create_new_frame_for_player
  end

  private

  def create_new_frame_for_player
    if player.frames.count >= 1
      increment_frame_number
    else
      frame.update_attribute(:frame_number, 1)
    end
    player.frames << frame
    frame
  end

  def increment_frame_number
    previous_frame_number = player.frames.last.frame_number
    frame.update_attribute(:frame_number, previous_frame_number + 1)
    frame
  end

  def frame_limit_error
    { errors: { detail: "frame limit has been reached" } }
  end

  def frame_limit_reached
    player.frames.count == 10
  end
end