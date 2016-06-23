class FrameService
  attr_accessor :player, :frame

  def initialize(player)
    @player = player
    @frame = Frame.new
  end

  def build!
    if player.frames.count == 10
      frame_limit_reached
    else
      frame = create_new_frame
      frame.save
      player.frames << frame
      frame
    end
  end

  private

  def create_new_frame
    if player.frames.count >= 1
      increment_frame_number
    else
      frame.update_attribute(:frame_number, 1)
      frame
    end
  end

  def increment_frame_number
    previous_frame_number = player.frames.last.frame_number
    frame.update_attribute(:frame_number, previous_frame_number + 1)
    frame
  end

  def frame_limit_reached
    { errors: { detail: "frame limit has been reached" } }
  end
end