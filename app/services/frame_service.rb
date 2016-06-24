class FrameService
  attr_accessor :player, :frame

  def initialize(player_id, pins_down)
    @player = Player.find(player_id)
    @pins_down = pins_down
  end

  def update_player_frames!
    find_or_create_current_frame
    update_roll!
  end

  private

  def find_or_create_current_frame
    add_frame unless find_current_frame
  end

  def find_current_frame
    if current_frame_exists? || final_frame_with_bonus?
      @frame = player.frames.last
    end
    @frame
  end

  def add_frame
    return frame_limit_error if frame_limit_reached

    @frame = Frame.new
    if player.frames.count >= 1
      increment_frame_number
    else
      @frame.update_attribute(:frame_number, 1)
    end
    @frame.save
    player.frames << @frame
    @frame
  end

  def increment_frame_number
    previous_frame_number = player.frames.last.frame_number
    @frame.frame_number = previous_frame_number + 1
    @frame.save
    @frame
  end

  def current_frame_exists?
    player.frames.last && player.frames.last.open?
  end

  def final_frame_with_bonus?
    player.frames.last && 
    player.frames.last.frame_number == 10 && 
    player.frames.last.pending?
  end

  def frame_limit_error
    { errors: { detail: "frame limit has been reached" } }
  end

  def frame_limit_reached
    player.frames.count == 10
  end

  def update_roll!
    roll_svc = RollService.new(
      player: player,
      pins_down: @pins_down,
      frame: player.frames.last
    )
    roll_svc.add_roll!
  end
end